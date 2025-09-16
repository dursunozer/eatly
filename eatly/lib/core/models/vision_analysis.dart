import 'package:eatly/core/models/vision_models.dart' as vr;

class VisionAnalysis {
  final vr.VisionResult result;
  final Map<String, dynamic>? nutrition;

  const VisionAnalysis({required this.result, this.nutrition});
}


