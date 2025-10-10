import io
from typing import List, Dict, Any, Optional, Tuple

from fastapi import FastAPI, Request, Query
from fastapi.middleware.cors import CORSMiddleware
from PIL import Image
from transformers import pipeline
import requests
import torch
import os
import time
import csv

app = FastAPI(title="Eatly Vision Proxy")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def root():
    return {"status": "ok"}

@app.get("/healthz")
def healthz():
    return {"status": "ok"}

DEVICE_KW = {"device": 0} if torch.cuda.is_available() else {}

detector = pipeline(
    task="zero-shot-object-detection",
    model="google/owlvit-base-patch32",
    **DEVICE_KW,
)
classifier = pipeline(
    task="image-classification",
    model="nateraw/food",
    **DEVICE_KW,
)

DETECTION_LABELS: List[str] = [
    "apple pie", "baby back ribs", "baklava", "burger", "burrito", "caesar salad",
    "cake", "chicken curry", "chicken wings", "churros", "cup cakes", "donuts",
    "falafel", "french fries", "fried rice", "grilled cheese sandwich", "gyoza",
    "hot dog", "hummus", "ice cream", "lasagna", "omelette", "paella", "pancakes",
    "pizza", "ramen", "risotto", "samosa", "spaghetti bolognese", "steak", "sushi",
    "tacos", "tiramisu", "waffles", "roast chicken", "grilled fish", "salad",

    "tomato", "lemon", "rice", "bread", "lettuce", "onion", "pepper"
]

INGREDIENT_LABELS = {
    "tomato", "lemon", "rice", "bread", "lettuce", "onion", "pepper",
    "cucumber", "parsley", "olive", "cheese", "yogurt", "garlic"
}

NORMALIZE_MAP = {
    "grilled_salmon": ["salmon", "grilled salmon", "fish"],
    "grilled_fish": ["grilled fish", "fish"],
    "roast chicken": ["roasted chicken", "chicken"],
    "spaghetti bolognese": ["spaghetti", "pasta"],
}

def generate_off_queries(name: str) -> list[str]:
    base = name.replace("_", " ").strip()
    variants = [base]

    for adj in ["grilled", "roasted", "fried", "baked"]:
        if base.startswith(adj + " "):
            variants.append(base[len(adj)+1:])

    if name in NORMALIZE_MAP:
        variants.extend(NORMALIZE_MAP[name])

    if base.endswith("es"):
        variants.append(base[:-2])
    if base.endswith("s") and len(base) > 3:
        variants.append(base[:-1])

    uniq = []
    for v in variants:
        if v not in uniq:
            uniq.append(v)
    return uniq

def make_grid_boxes(w: int, h: int, rows: int = 2, cols: int = 2) -> List[Dict[str, float]]:
    boxes: List[Dict[str, float]] = []
    cell_w = w / cols
    cell_h = h / rows
    for r in range(rows):
        for c in range(cols):
            xmin = int(c * cell_w)
            ymin = int(r * cell_h)
            xmax = int(min(w, (c + 1) * cell_w))
            ymax = int(min(h, (r + 1) * cell_h))
            boxes.append({"xmin": xmin, "ymin": ymin, "xmax": xmax, "ymax": ymax})
    return boxes

def ingredient_pass(img: Image.Image, w: int, h: int) -> List[Dict[str, Any]]:

    dets2 = detector(img, candidate_labels=list(INGREDIENT_LABELS), threshold=0.08)
    items: List[Dict[str, Any]] = []
    for d in dets2:
        box = d["box"]
        name = d.get("label") or ""
        score = float(d["score"])
        poly = to_normalized_polygon(box, w, h)
        items.append({"name": name, "score": score, "polygon": poly})
    return items

def dedup_by_name(objs: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    best_by_name: Dict[str, Dict[str, Any]] = {}
    for o in objs:
        name = o.get("name", "")
        if name not in best_by_name or o.get("score", 0.0) > best_by_name[name].get("score", 0.0):
            best_by_name[name] = o
    return list(best_by_name.values())

def nms_boxes(boxes: List[Dict[str, float]], scores: List[float], iou_thresh: float = 0.3) -> List[int]:

    import numpy as np
    if len(boxes) == 0:
        return []
    b = np.array([[bx["xmin"], bx["ymin"], bx["xmax"], bx["ymax"]] for bx in boxes], dtype=float)
    s = np.array(scores, dtype=float)
    x1, y1, x2, y2 = b[:, 0], b[:, 1], b[:, 2], b[:, 3]
    areas = (x2 - x1 + 1) * (y2 - y1 + 1)
    order = s.argsort()[::-1]
    keep = []
    while order.size > 0:
        i = order[0]
        keep.append(int(i))
        xx1 = np.maximum(x1[i], x1[order[1:]])
        yy1 = np.maximum(y1[i], y1[order[1:]])
        xx2 = np.minimum(x2[i], x2[order[1:]])
        yy2 = np.minimum(y2[i], y2[order[1:]])
        w = np.maximum(0.0, xx2 - xx1 + 1)
        h = np.maximum(0.0, yy2 - yy1 + 1)
        inter = w * h
        iou = inter / (areas[i] + areas[order[1:]] - inter + 1e-6)
        inds = np.where(iou <= iou_thresh)[0]
        order = order[inds + 1]
    return keep

def to_normalized_polygon(box: Dict[str, float], w: int, h: int) -> List[Dict[str, float]]:
    x1, y1, x2, y2 = box["xmin"], box["ymin"], box["xmax"], box["ymax"]
    x1n, y1n = max(0.0, x1 / w), max(0.0, y1 / h)
    x2n, y2n = min(1.0, x2 / w), min(1.0, y2 / h)
    return [
        {"x": x1n, "y": y1n},
        {"x": x2n, "y": y1n},
        {"x": x2n, "y": y2n},
        {"x": x1n, "y": y2n},
    ]

def off_nutrition_lookup(name: str) -> Dict[str, Any] | None:
    """Open Food Facts'tan basit besin aramasÄ± (100g baÅŸÄ±na)."""
    try:
        url = "https://world.openfoodfacts.org/cgi/search.pl"

        for q in generate_off_queries(name):
            params = {
                "search_terms": q,
                "search_simple": 1,
                "action": "process",
                "json": 1,
                "page_size": 1,
            }
            r = requests.get(
                url,
                params=params,
                timeout=8,
                headers={"User-Agent": "eatly-backend/1.0 (https://huggingface.co/spaces/hardrada/eatly-backend)"},
            )
            r.raise_for_status()
            data = r.json()
            prods = data.get("products", [])
            if not prods:
                continue
            p = prods[0]
            break
        else:
            return None
        nutr = p.get("nutriments", {})

        def g(key: str):
            return nutr.get(f"{key}_100g")

        kcal_val = g("energy-kcal")
        if kcal_val is None and nutr.get("energy") is not None:

            try:
                kcal_val = float(nutr.get("energy")) / 4.184
            except Exception:
                kcal_val = None

        return {
            "source": "openfoodfacts",
            "per_100g": {
                "kcal": kcal_val,
                "protein_g": g("proteins"),
                "carb_g": g("carbohydrates"),
                "fat_g": g("fat"),
            },
            "name": p.get("product_name") or name.replace("_", " "),
        }
    except Exception:
        return None

def usda_nutrition_lookup(name: str) -> Optional[Dict[str, Any]]:
    try:
        api_key = os.getenv("USDA_API_KEY", "").strip()
        if not api_key:
            return None
        url = "https://api.nal.usda.gov/fdc/v1/foods/search"
        for q in generate_off_queries(name):
            params = {"query": q, "pageSize": 1, "api_key": api_key}
            r = requests.get(url, params=params, timeout=8)
            r.raise_for_status()
            data = r.json()
            foods = data.get("foods", [])
            if not foods:
                continue
            f = foods[0]
            nutrients = f.get("foodNutrients", [])
            kcal = None
            protein = None
            carb = None
            fat = None
            for n in nutrients:
                nname = (n.get("nutrientName") or "").lower()
                unit = (n.get("unitName") or "").lower()
                val = n.get("value")
                if val is None:
                    continue
                if "energy" in nname and (unit == "kcal" or unit == "kcal/100g" or unit == "kcal_kcal"):
                    kcal = float(val)
                elif nname.startswith("protein") and unit == "g":
                    protein = float(val)
                elif nname.startswith("carbohydrate") and unit == "g":
                    carb = float(val)
                elif ("fat" in nname or "lipid" in nname) and unit == "g":
                    fat = float(val)
            return {
                "source": "usda",
                "per_100g": {
                    "kcal": kcal,
                    "protein_g": protein,
                    "carb_g": carb,
                    "fat_g": fat,
                },
                "name": f.get("description") or name,
            }
        return None
    except Exception:
        return None

_turkomp_loaded = False
_turkomp_rows: List[Dict[str, str]] = []

def _load_turkomp_if_any():
    global _turkomp_loaded, _turkomp_rows
    if _turkomp_loaded:
        return
    _turkomp_loaded = True
    csv_paths = [
        os.getenv("TURKOMP_CSV", "").strip(),
        "/app/data/turkomp.csv",
        "/data/turkomp.csv",
    ]
    path = next((p for p in csv_paths if p and os.path.exists(p)), None)
    if not path:
        return
    try:
        with open(path, "r", encoding="utf-8") as f:
            reader = csv.DictReader(f)
            _turkomp_rows = list(reader)
    except Exception:
        _turkomp_rows = []

def _extract_turkomp_fields(row: Dict[str, str]) -> Optional[Tuple[str, Optional[float], Optional[float], Optional[float], Optional[float]]]:

    name_keys = ["name", "yiyecek", "besin", "food", "ad", "Yiyecek AdÄ±"]
    kcal_keys = ["kcal", "enerji (kcal)", "enerji_kcal", "energy_kcal"]
    prot_keys = ["protein_g", "protein (g)", "protein", "protein_g/100g"]
    carb_keys = ["carb_g", "karbonhidrat (g)", "carbohydrate", "carbohydrate_g"]
    fat_keys = ["fat_g", "yaÄŸ (g)", "fat", "total_fat_g"]
    def pick(keys):
        for k in keys:
            if k in row:
                return row.get(k)

        for k in keys:
            for rk in row.keys():
                if rk.strip().lower() == k.strip().lower():
                    return row.get(rk)
        return None
    name = pick(name_keys)
    if not name:
        return None
    def to_float(x):
        try:
            if x is None or x == "":
                return None
            return float(str(x).replace(",", "."))
        except Exception:
            return None
    kcal = to_float(pick(kcal_keys))
    protein = to_float(pick(prot_keys))
    carb = to_float(pick(carb_keys))
    fat = to_float(pick(fat_keys))
    return name, kcal, protein, carb, fat

def turkomp_nutrition_lookup(name: str) -> Optional[Dict[str, Any]]:
    _load_turkomp_if_any()
    if not _turkomp_rows:
        return None
    target = name.replace("_", " ").strip().lower()
    best: Optional[Dict[str, Any]] = None
    for row in _turkomp_rows:
        parsed = _extract_turkomp_fields(row)
        if not parsed:
            continue
        rname, kcal, protein, carb, fat = parsed
        low = (rname or "").strip().lower()
        if low == target or target in low:
            best = {
                "source": "turkomp",
                "per_100g": {
                    "kcal": kcal,
                    "protein_g": protein,
                    "carb_g": carb,
                    "fat_g": fat,
                },
                "name": rname,
            }
            break
    return best

_NUTR_CACHE: Dict[str, Tuple[float, Dict[str, Any]]] = {}
_NUTR_TTL_SEC = 24 * 3600

def get_nutrition(name: str) -> Optional[Dict[str, Any]]:
    key = name.strip().lower().replace("_", " ")
    now = time.time()
    cached = _NUTR_CACHE.get(key)
    if cached and (now - cached[0] < _NUTR_TTL_SEC):
        return cached[1]

    res = off_nutrition_lookup(name)

    if not res:
        res = usda_nutrition_lookup(name)

    if not res:
        res = turkomp_nutrition_lookup(name)

    if res:
        _NUTR_CACHE[key] = (now, res)
    return res

@app.post("/api/vision/analyze")
async def analyze(request: Request, features: str = Query("labels,objects"), threshold: float = 0.05):
    img_bytes = await request.body()
    img = Image.open(io.BytesIO(img_bytes)).convert("RGB")
    w, h = img.size

    dets = detector(img, candidate_labels=DETECTION_LABELS, threshold=threshold)

    objects: List[Dict[str, Any]] = []
    labels_counter: Dict[str, float] = {}

    tmp_boxes, tmp_scores, tmp_payload = [], [], []
    for d in dets:
        box = d["box"]
        det_score = float(d["score"])
        det_label = d.get("label") or ""
        crop = img.crop((box["xmin"], box["ymin"], box["xmax"], box["ymax"]))
        cls = classifier(crop, top_k=3)

        top_best = max(cls, key=lambda x: x["score"]) if cls else {"label": det_label, "score": det_score}
        name = det_label if det_label in INGREDIENT_LABELS else top_best["label"]
        cls_score = float(top_best["score"]) if cls else det_score
        avg_score = float(min(1.0, (det_score + cls_score) / 2.0))
        tmp_boxes.append(box)
        tmp_scores.append(avg_score)
        tmp_payload.append((name, avg_score))

    keep_idx = nms_boxes(tmp_boxes, tmp_scores, iou_thresh=0.5)
    for idx in keep_idx[:8]:
        box = tmp_boxes[idx]
        name, avg_score = tmp_payload[idx]
        poly = to_normalized_polygon(box, w, h)
        objects.append({"name": name, "score": avg_score, "polygon": poly})
        labels_counter[name] = max(labels_counter.get(name, 0.0), avg_score)

    labels = [
        {"description": k, "score": v}
        for k, v in sorted(labels_counter.items(), key=lambda x: -x[1])
    ][:5]

    if not objects:
        cls_full = classifier(img, top_k=3)
        for item in cls_full:
            labels_counter[item["label"]] = max(labels_counter.get(item["label"], 0.0), float(item["score"]))
        labels = [
            {"description": k, "score": v}
            for k, v in sorted(labels_counter.items(), key=lambda x: -x[1])
        ][:5]

    if len(objects) <= 1:
        grid_boxes = make_grid_boxes(w, h, rows=3, cols=3)
        for gb in grid_boxes:
            crop = img.crop((gb["xmin"], gb["ymin"], gb["xmax"], gb["ymax"]))
            cls_g = classifier(crop, top_k=3)
            topg = max(cls_g, key=lambda x: x["score"]) if cls_g else None
            if not topg:
                continue
            g_name = topg["label"]
            g_score = float(topg["score"])
            if g_score < 0.40:
                continue
            poly = to_normalized_polygon(gb, w, h)
            objects.append({"name": g_name, "score": g_score, "polygon": poly})
            labels_counter[g_name] = max(labels_counter.get(g_name, 0.0), g_score)

        ingr_objs = ingredient_pass(img, w, h)
        for o in ingr_objs:
            labels_counter[o["name"]] = max(labels_counter.get(o["name"], 0.0), o["score"])
        objects = dedup_by_name(objects + ingr_objs)

        objects = dedup_by_name(objects)
        labels = [
            {"description": k, "score": v}
            for k, v in sorted(labels_counter.items(), key=lambda x: -x[1])
        ][:5]

    nutrition: Dict[str, Any] = {}
    for o in objects[:3]:
        n = get_nutrition(o["name"])
        if n:
            nutrition[o["name"]] = n

    return {
        "labels": labels,
        "objects": objects,
        "nutrition": nutrition or None,
    }


