import 'package:json_annotation/json_annotation.dart';
import 'package:eatly/core/models/vision_models.dart';

part 'vision_response.g.dart';

@JsonSerializable()
class VisionApiResponse {
  final List<ResponseItem> responses;

  VisionApiResponse({required this.responses});

  factory VisionApiResponse.fromJson(Map<String, dynamic> json) =>
      _$VisionApiResponseFromJson(json);
  Map<String, dynamic> toJson() => _$VisionApiResponseToJson(this);
}

@JsonSerializable()
class ResponseItem {
  @JsonKey(name: 'labelAnnotations') // API'den gelen alan adı labelAnnotations
  final List<VisionLabel>? labels;

  @JsonKey(
    name: 'localizedObjectAnnotations',
  ) // API'den gelen alan adı localizedObjectAnnotations
  final List<VisionObject>? objects;

  ResponseItem({this.labels, this.objects});

  factory ResponseItem.fromJson(Map<String, dynamic> json) =>
      _$ResponseItemFromJson(json); // <<< DÜZELTME BURADA
  Map<String, dynamic> toJson() =>
      _$ResponseItemToJson(this); // <<< DÜZELTME BURADA
}
