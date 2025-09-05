part of 'vision_request.dart';

VisionApiRequest _$VisionApiRequestFromJson(Map<String, dynamic> json) =>
    VisionApiRequest(
      requests: (json['requests'] as List<dynamic>)
          .map((e) => RequestItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$VisionApiRequestToJson(VisionApiRequest instance) =>
    <String, dynamic>{'requests': instance.requests};

RequestItem _$RequestItemFromJson(Map<String, dynamic> json) => RequestItem(
  image: ImageContent.fromJson(json['image'] as Map<String, dynamic>),
  features: (json['features'] as List<dynamic>)
      .map((e) => Feature.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$RequestItemToJson(RequestItem instance) =>
    <String, dynamic>{'image': instance.image, 'features': instance.features};

ImageContent _$ImageContentFromJson(Map<String, dynamic> json) =>
    ImageContent(content: json['content'] as String);

Map<String, dynamic> _$ImageContentToJson(ImageContent instance) =>
    <String, dynamic>{'content': instance.content};

Feature _$FeatureFromJson(Map<String, dynamic> json) => Feature(
  type: json['type'] as String,
  maxResults: (json['maxResults'] as num?)?.toInt(),
);

Map<String, dynamic> _$FeatureToJson(Feature instance) => <String, dynamic>{
  'type': instance.type,
  'maxResults': instance.maxResults,
};
