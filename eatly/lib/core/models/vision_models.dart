import 'package:freezed_annotation/freezed_annotation.dart';

part 'vision_models.freezed.dart';
part 'vision_models.g.dart';

@freezed
abstract class VisionLabel with _$VisionLabel {
  const factory VisionLabel({
    @Default('') String description,
    @Default(0.0) double score,
  }) = _VisionLabel;

  factory VisionLabel.fromJson(Map<String, dynamic> json) =>
      _$VisionLabelFromJson(json);
}

@freezed
abstract class NormalizedVertex with _$NormalizedVertex {
  const factory NormalizedVertex({
    @Default(0.0) double x,
    @Default(0.0) double y,
  }) = _NormalizedVertex;

  factory NormalizedVertex.fromJson(Map<String, dynamic> json) =>
      _$NormalizedVertexFromJson(json);
}

@freezed
abstract class VisionObject with _$VisionObject {
  const factory VisionObject({
    @Default('') String name,
    @Default(0.0) double score,
    @Default(<NormalizedVertex>[]) List<NormalizedVertex> polygon,
  }) = _VisionObject;

  factory VisionObject.fromJson(Map<String, dynamic> json) =>
      _$VisionObjectFromJson(json);
}

@freezed
abstract class VisionResult with _$VisionResult {
  const factory VisionResult({
    @Default(<VisionLabel>[]) List<VisionLabel> labels,
    @Default(<VisionObject>[]) List<VisionObject> objects,
  }) = _VisionResult;

  factory VisionResult.fromJson(Map<String, dynamic> json) =>
      _$VisionResultFromJson(json);
}
