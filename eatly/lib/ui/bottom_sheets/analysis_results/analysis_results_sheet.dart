import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'dart:typed_data';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/vision_models.dart' as vr;

class AnalysisResultsSheet extends StatelessWidget {
  final Function(SheetResponse) completer;
  final SheetRequest request;

  const AnalysisResultsSheet({
    super.key,
    required this.completer,
    required this.request,
  });

  @override
  Widget build(BuildContext context) {
    final data = request.data as Map<String, dynamic>;
    final Uint8List imageBytes = data['imageBytes'];
    final vr.VisionResult result = data['result'];
    final Map<String, dynamic>? nutrition = data['nutrition'];

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Tespit Edilen Besinler',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    imageBytes,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 20),
                // Obje tespitleri
                if (result.objects.isNotEmpty)
                  ...result.objects.map(
                    (o) => _buildDetectedVisionItem(
                      o.name.toString(),
                      'Skor: ${((o.score) * 100).toStringAsFixed(0)}%',
                    ),
                  )
                // Etiket tespitleri
                else if (result.labels.isNotEmpty)
                  ...result.labels.take(5).map(
                        (l) => _buildDetectedVisionItem(
                          l.description.toString(),
                          'Skor: ${((l.score) * 100).toStringAsFixed(0)}%',
                        ),
                      ),
                const SizedBox(height: 12),
                // Besin değerleri
                if (nutrition != null && nutrition.isNotEmpty)
                  ...nutrition.entries.map((e) {
                    final name = e.key;
                    final Map<String, dynamic> v = e.value as Map<String, dynamic>;
                    final source = (v['source'] ?? '').toString();
                    final per100 = (v['per_100g'] ?? {}) as Map<String, dynamic>;
                    final kcal = per100['kcal'];
                    final protein = per100['protein_g'];
                    final carb = per100['carb_g'];
                    final fat = per100['fat_g'];
                    return _buildDetectedVisionItem(
                      '$name • ${source.toUpperCase()}',
                      '100g: ${kcal != null ? '${kcal.toString()} kcal' : '-'} • P:${protein ?? '-'}g C:${carb ?? '-'}g Y:${fat ?? '-'}g',
                    );
                  }),
                if (result.objects.isEmpty && result.labels.isEmpty)
                  const Text(
                    'Herhangi bir besin veya obje tespit edilemedi.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    completer(SheetResponse(confirmed: true));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Kaydet',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetectedVisionItem(String title, String subtitle) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.restaurant,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
