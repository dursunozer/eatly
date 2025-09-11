import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../../core/config/policy_config.dart';
import '../../../core/services/consent_service.dart';

class ConsentUpdateView extends StatefulWidget {
  const ConsentUpdateView({super.key});

  @override
  State<ConsentUpdateView> createState() => _ConsentUpdateViewState();
}

class _ConsentUpdateViewState extends State<ConsentUpdateView> {
  bool _isBusy = false;
  bool _acceptKvkk = false;
  bool _acceptHealth = false;

  Future<void> _openPolicy() async {
    await launchUrlString(PolicyConfig.policyUrl, mode: LaunchMode.externalApplication);
  }

  Future<void> _submit() async {
    if (!_acceptKvkk || !_acceptHealth) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Devam etmek için tüm onayları vermelisiniz.')),
      );
      return;
    }
    setState(() => _isBusy = true);
    try {
      await ConsentService.saveConsent(kvkkAccepted: _acceptKvkk, healthAccepted: _acceptHealth);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Onay kaydedilemedi: $e')),
      );
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Politika Güncellemesi')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Politika sürümü: ${PolicyConfig.policyVersion}', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _openPolicy,
              child: const Text('KVKK ve Gizlilik Politikasını oku'),
            ),
            const Divider(height: 24),
            CheckboxListTile(
              value: _acceptKvkk,
              onChanged: (v) => setState(() => _acceptKvkk = v ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text('KVKK ve Gizlilik Politikasını kabul ediyorum.'),
            ),
            CheckboxListTile(
              value: _acceptHealth,
              onChanged: (v) => setState(() => _acceptHealth = v ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text('Sağlık verilerimin işlenmesine açık rıza veriyorum.'),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isBusy ? null : _submit,
                child: _isBusy
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Onayla ve Devam Et'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


