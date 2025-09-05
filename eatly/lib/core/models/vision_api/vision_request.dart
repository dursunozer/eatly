import 'package:json_annotation/json_annotation.dart';

part 'vision_request.g.dart';

@JsonSerializable()
class VisionApiRequest {
  final List<RequestItem> requests;

  VisionApiRequest({required this.requests});

  factory VisionApiRequest.fromJson(Map<String, dynamic> json) =>
      _$VisionApiRequestFromJson(json);
  Map<String, dynamic> toJson() => _$VisionApiRequestToJson(this);
}

@JsonSerializable()
class RequestItem {
  final ImageContent image;
  final List<Feature> features;

  RequestItem({required this.image, required this.features});

  factory RequestItem.fromJson(Map<String, dynamic> json) =>
      _$RequestItemFromJson(json);
  Map<String, dynamic> toJson() => _$RequestItemToJson(this);
}

@JsonSerializable()
class ImageContent {
  final String content;

  ImageContent({required this.content});

  factory ImageContent.fromJson(Map<String, dynamic> json) =>
      _$ImageContentFromJson(json);
  Map<String, dynamic> toJson() => _$ImageContentToJson(this);
}

@JsonSerializable()
class Feature {
  final String type;
  final int? maxResults; // Opsiyonel olabilir

  Feature({required this.type, this.maxResults});

  factory Feature.fromJson(Map<String, dynamic> json) =>
      _$FeatureFromJson(json);
  Map<String, dynamic> toJson() => _$FeatureToJson(this);
}
