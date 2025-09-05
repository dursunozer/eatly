import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../utils/env.dart';
import '../models/vision_models.dart' as vr;

class VisionService {
  final http.Client _client;

  VisionService({http.Client? client}) : _client = client ?? http.Client();

  Future<vr.VisionResult> analyzeImageBytes(Uint8List imageBytes) async {
    if (EnvConfig.visionProxyEndpoint.isEmpty) {
      throw Exception('Vision proxy endpoint tanımlı değil (EnvConfig).');
    }

    final uri = Uri.parse(
      '${EnvConfig.visionProxyEndpoint}?features=labels,objects',
    );
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/octet-stream'},
      body: imageBytes,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Vision proxy hata: ${response.statusCode} ${response.body}',
      );
    }

    final Map<String, dynamic> json =
        jsonDecode(response.body) as Map<String, dynamic>;
    final List<vr.VisionLabel> labels = ((json['labels'] as List?) ?? [])
        .map(
          (e) => vr.VisionLabel(
            description: e['description'] as String,
            score: (e['score'] as num).toDouble(),
          ),
        )
        .toList();

    final List<vr.VisionObject> objects = ((json['objects'] as List?) ?? [])
        .map(
          (e) => vr.VisionObject(
            name: e['name'] as String,
            score: (e['score'] as num).toDouble(),
            polygon: ((e['polygon'] as List?) ?? [])
                .map(
                  (v) => vr.NormalizedVertex(
                    x: (v['x'] as num).toDouble(),
                    y: (v['y'] as num).toDouble(),
                  ),
                )
                .toList(),
          ),
        )
        .toList();

    return vr.VisionResult(labels: labels, objects: objects);
  }
}
