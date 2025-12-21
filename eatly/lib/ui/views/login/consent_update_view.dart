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
      backgroundColor: Colors.black.withOpacity(0.5),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // İkon
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.policy_outlined,
                      size: 48,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Başlık
                  const Text(
                    'Gizlilik Politikası Güncellendi',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  
                  // Açıklama
                  Text(
                    'Hizmetlerimizi daha iyi sunabilmek için gizlilik politikamızı güncelledik. Devam etmek için lütfen yeni politikayı kabul edin.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  
                  // Versiyon
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Sürüm ${viewModel.policyVersion}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Politikayı Oku Linki
                  TextButton.icon(
                    onPressed: viewModel.openPolicy,
                    icon: const Icon(Icons.description_outlined, size: 18),
                    label: const Text('Gizlilik Politikasını Oku'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Onay Kutuları
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        _buildCheckbox(
                          value: viewModel.acceptKvkk,
                          onChanged: viewModel.setKvkkAcceptance,
                          title: 'KVKK ve Gizlilik Politikasını kabul ediyorum',
                          isRequired: true,
                        ),
                        const SizedBox(height: 12),
                        _buildCheckbox(
                          value: viewModel.acceptHealth,
                          onChanged: viewModel.setHealthAcceptance,
                          title: 'Sağlık verilerimin işlenmesine açık rıza veriyorum',
                          isRequired: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Kabul Et Butonu
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (viewModel.acceptKvkk && viewModel.acceptHealth && !viewModel.isBusy)
                          ? viewModel.submitConsent
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        disabledBackgroundColor: Colors.grey.shade300,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: viewModel.isBusy
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Kabul Et ve Devam Et',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // İpucu
                  Text(
                    'Kabul etmeden uygulamayı kullanamazsınız',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox({
    required bool value,
    required void Function(bool?)? onChanged,
    required String title,
    bool isRequired = false,
  }) {
    return InkWell(
      onTap: () => onChanged?.call(!value),
      borderRadius: BorderRadius.circular(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textPrimary,
                    height: 1.4,
                  ),
                  children: [
                    TextSpan(text: title),
                    if (isRequired)
                      const TextSpan(
                        text: ' *',
                        style: TextStyle(color: Colors.red),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  ConsentUpdateViewModel viewModelBuilder(BuildContext context) =>
      ConsentUpdateViewModel();
}
