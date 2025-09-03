import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../utils/env.dart';

class VisionLabel {
  final String description;
  final double score;

  VisionLabel({required this.description, required this.score});
}

class VisionObject {
  final String name;
  final double score;
  final List<NormalizedVertex> polygon; // boundingPoly normalized vertices

  VisionObject({
    required this.name,
    required this.score,
    required this.polygon,
  });
}

class NormalizedVertex {
  final double x;
  final double y;

  NormalizedVertex({required this.x, required this.y});
}

class VisionResult {
  final List<VisionLabel> labels;
  final List<VisionObject> objects;

  VisionResult({required this.labels, required this.objects});
}

class VisionService {
  final http.Client _client;

  VisionService({http.Client? client}) : _client = client ?? http.Client();

  Future<VisionResult> analyzeImageBytes(Uint8List imageBytes) async {
    if (EnvConfig.visionProxyEndpoint.isEmpty) {
      throw Exception('Vision proxy endpoint tanımlı değil (EnvConfig).');
    }

    final uri = Uri.parse('${EnvConfig.visionProxyEndpoint}?features=labels,objects');
    final response = await _client.post(
      uri,
      headers: {
        'Content-Type': 'application/octet-stream',
      },
      body: imageBytes,
    );

    if (response.statusCode != 200) {
      throw Exception('Vision proxy hata: ${response.statusCode} ${response.body}');
    }

    final Map<String, dynamic> json = jsonDecode(response.body) as Map<String, dynamic>;
    final List<VisionLabel> labels = ((json['labels'] as List?) ?? [])
        .map((e) => VisionLabel(
              description: e['description'] as String,
              score: (e['score'] as num).toDouble(),
            ))
        .toList();

    final List<VisionObject> objects = ((json['objects'] as List?) ?? [])
        .map((e) => VisionObject(
              name: e['name'] as String,
              score: (e['score'] as num).toDouble(),
              polygon: ((e['polygon'] as List?) ?? [])
                  .map((v) => NormalizedVertex(
                        x: (v['x'] as num).toDouble(),
                        y: (v['y'] as num).toDouble(),
                      ))
                  .toList(),
            ))
        .toList();

    return VisionResult(labels: labels, objects: objects);
  }
}


