// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vision_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VisionLabel _$VisionLabelFromJson(Map<String, dynamic> json) => _VisionLabel(
  description: json['description'] as String? ?? '',
  score: (json['score'] as num?)?.toDouble() ?? 0.0,
);

Map<String, dynamic> _$VisionLabelToJson(_VisionLabel instance) =>
    <String, dynamic>{
      'description': instance.description,
      'score': instance.score,
    };

_NormalizedVertex _$NormalizedVertexFromJson(Map<String, dynamic> json) =>
    _NormalizedVertex(
      x: (json['x'] as num?)?.toDouble() ?? 0.0,
      y: (json['y'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$NormalizedVertexToJson(_NormalizedVertex instance) =>
    <String, dynamic>{'x': instance.x, 'y': instance.y};

_VisionObject _$VisionObjectFromJson(Map<String, dynamic> json) =>
    _VisionObject(
      name: json['name'] as String? ?? '',
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      polygon:
          (json['polygon'] as List<dynamic>?)
              ?.map((e) => NormalizedVertex.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <NormalizedVertex>[],
    );

Map<String, dynamic> _$VisionObjectToJson(_VisionObject instance) =>
    <String, dynamic>{
      'name': instance.name,
      'score': instance.score,
      'polygon': instance.polygon,
    };

_VisionResult _$VisionResultFromJson(Map<String, dynamic> json) =>
    _VisionResult(
      labels:
          (json['labels'] as List<dynamic>?)
              ?.map((e) => VisionLabel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <VisionLabel>[],
      objects:
          (json['objects'] as List<dynamic>?)
              ?.map((e) => VisionObject.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <VisionObject>[],
    );

Map<String, dynamic> _$VisionResultToJson(_VisionResult instance) =>
    <String, dynamic>{'labels': instance.labels, 'objects': instance.objects};
