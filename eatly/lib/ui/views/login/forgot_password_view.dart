import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'forgot_password_viewmodel.dart';

class ForgotPasswordView extends StackedView<ForgotPasswordViewModel> {
  const ForgotPasswordView({super.key});

  @override
  Widget builder(BuildContext context, ForgotPasswordViewModel viewModel, Widget? child) {
    final email = TextEditingController();
    return Scaffold(
      appBar: AppBar(title: const Text('Şifremi Unuttum')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: email, decoration: const InputDecoration(labelText: 'E-posta')),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: viewModel.isBusy
                  ? null
                  : () async {
                      final ok = await viewModel.sendReset(email.text);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(ok ? 'E-posta gönderildi' : 'Gönderilemedi')),
                      );
                      if (ok) Navigator.pop(context);
                    },
              child: viewModel.isBusy
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Sıfırlama bağlantısı gönder'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  ForgotPasswordViewModel viewModelBuilder(BuildContext context) => ForgotPasswordViewModel();
}
