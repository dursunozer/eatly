import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'consent_update_viewmodel.dart';
import '../../../core/theme/app_theme.dart';

class ConsentUpdateView extends StackedView<ConsentUpdateViewModel> {
  const ConsentUpdateView({super.key});

  @override
  Widget builder(
    BuildContext context,
    ConsentUpdateViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Politika Güncellemesi'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Politika sürümü: ${viewModel.policyVersion}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: viewModel.openPolicy,
              child: const Text('KVKK ve Gizlilik Politikasını oku'),
            ),
            const Divider(height: 24),
            CheckboxListTile(
              value: viewModel.acceptKvkk,
              onChanged: viewModel.setKvkkAcceptance,
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text('KVKK ve Gizlilik Politikasını kabul ediyorum.'),
            ),
            CheckboxListTile(
              value: viewModel.acceptHealth,
              onChanged: viewModel.setHealthAcceptance,
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text('Sağlık verilerimin işlenmesine açık rıza veriyorum.'),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: viewModel.isBusy ? null : viewModel.submitConsent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: viewModel.isBusy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Onayla ve Devam Et',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  ConsentUpdateViewModel viewModelBuilder(BuildContext context) =>
      ConsentUpdateViewModel();
}