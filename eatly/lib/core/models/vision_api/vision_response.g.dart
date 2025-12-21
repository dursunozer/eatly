// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vision_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VisionApiResponse _$VisionApiResponseFromJson(Map<String, dynamic> json) =>
    VisionApiResponse(
      responses: (json['responses'] as List<dynamic>)
          .map((e) => ResponseItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$VisionApiResponseToJson(VisionApiResponse instance) =>
    <String, dynamic>{'responses': instance.responses};

ResponseItem _$ResponseItemFromJson(Map<String, dynamic> json) => ResponseItem(
  labels: (json['labelAnnotations'] as List<dynamic>?)
      ?.map((e) => VisionLabel.fromJson(e as Map<String, dynamic>))
      .toList(),
  objects: (json['localizedObjectAnnotations'] as List<dynamic>?)
      ?.map((e) => VisionObject.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ResponseItemToJson(ResponseItem instance) =>
    <String, dynamic>{
      'labelAnnotations': instance.labels,
      'localizedObjectAnnotations': instance.objects,
    };
