// lib/models/vision_result.dart

class VisionResult {
  final List<VisionLabel> labels;
  final List<VisionObject> objects;

  VisionResult({this.labels = const [], this.objects = const []});

  factory VisionResult.fromJson(Map<String, dynamic> json) {
    final List<dynamic>? labelAnnotations = json['labelAnnotations'];
    final List<dynamic>? localizedObjectAnnotations =
        json['localizedObjectAnnotations'];

    return VisionResult(
      labels: labelAnnotations != null
          ? labelAnnotations.map((e) => VisionLabel.fromJson(e)).toList()
          : [],
      objects: localizedObjectAnnotations != null
          ? localizedObjectAnnotations
                .map((e) => VisionObject.fromJson(e))
                .toList()
          : [],
    );
  }
}

class VisionLabel {
  final String description;
  final double score;

  VisionLabel({required this.description, required this.score});

  factory VisionLabel.fromJson(Map<String, dynamic> json) {
    return VisionLabel(
      description: json['description'] as String,
      score: (json['score'] as num).toDouble(),
    );
  }
}

class VisionObject {
  final String name;
  final double score;
  // Bounding polygon'u şimdilik dahil etmiyoruz, gerekirse eklenebilir.
  // final List<Map<String, double>> polygon;

  VisionObject({required this.name, required this.score});

  factory VisionObject.fromJson(Map<String, dynamic> json) {
    return VisionObject(
      name: json['name'] as String,
      score: (json['score'] as num).toDouble(),
      // polygon: (json['boundingPoly']?['normalizedVertices'] as List<dynamic>?)
      //     ?.map((v) => {'x': (v['x'] as num).toDouble(), 'y': (v['y'] as num).toDouble()})
      //     .toList() ?? [],
    );
  }
}
