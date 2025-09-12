import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../../core/config/policy_config.dart';
import 'signup_viewmodel.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  late final TextEditingController _passwordConfirm;
  late final TextEditingController _name;
  late final TextEditingController _age;
  late final TextEditingController _weight;
  late final TextEditingController _height;
  late final TextEditingController _waist;
  late final TextEditingController _hip;
  String _gender = 'Erkek';
  bool _acceptKvkk = false;
  bool _acceptHealth = false;
  bool _obscurePassword = true;
  bool _obscurePasswordConfirm = true;

  @override
  void initState() {
    super.initState();
    _email = TextEditingController();
    _password = TextEditingController();
    _passwordConfirm = TextEditingController();
    _name = TextEditingController();
    _age = TextEditingController();
    _weight = TextEditingController();
    _height = TextEditingController();
    _waist = TextEditingController();
    _hip = TextEditingController();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _passwordConfirm.dispose();
    _name.dispose();
    _age.dispose();
    _weight.dispose();
    _height.dispose();
    _waist.dispose();
    _hip.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SignupViewModel>.reactive(
      viewModelBuilder: () => SignupViewModel(),
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Kayıt Ol')),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: _name,
                    decoration: const InputDecoration(labelText: 'Ad Soyad'),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r"[a-zA-ZğüşöçıİĞÜŞÖÇ ]"),
                      ),
                    ],
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _email,
                    decoration: const InputDecoration(labelText: 'E-posta'),
                    keyboardType: TextInputType.emailAddress,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r"[a-zA-Z0-9@_.]"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _password,
                    decoration: InputDecoration(
                      labelText: 'Şifre',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    obscureText: _obscurePassword,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passwordConfirm,
                    decoration: InputDecoration(
                      labelText: 'Şifrenizi tekrar girin',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePasswordConfirm ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () => setState(() => _obscurePasswordConfirm = !_obscurePasswordConfirm),
                      ),
                    ),
                    obscureText: _obscurePasswordConfirm,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _age,
                    decoration: const InputDecoration(labelText: 'Yaş'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _weight,
                    decoration: const InputDecoration(labelText: 'Kilo (kg)'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _height,
                    decoration: const InputDecoration(labelText: 'Boy (cm)'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _waist,
                    decoration: const InputDecoration(
                      labelText: 'Bel çevresi (cm)',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _hip,
                    decoration: const InputDecoration(
                      labelText: 'Kalça çevresi (cm)',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 8),
                  _BmiPreview(heightCtrl: _height, weightCtrl: _weight),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _gender,
                    items: const [
                      DropdownMenuItem(value: 'Erkek', child: Text('Erkek')),
                      DropdownMenuItem(value: 'Kadın', child: Text('Kadın')),
                    ],
                    onChanged: (v) => setState(() => _gender = v ?? 'Erkek'),
                    decoration: const InputDecoration(labelText: 'Cinsiyet'),
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    value: _acceptKvkk,
                    onChanged: (v) => setState(() => _acceptKvkk = v ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    title: const Text(
                      'KVKK ve Gizlilik Politikası\'nı okudum, anladım ve kabul ediyorum.',
                    ),
                    subtitle: const Text(
                      'Devam ederek verilerinizin işlenmesine ilişkin aydınlatma metnini kabul etmiş olursunuz.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  CheckboxListTile(
                    value: _acceptHealth,
                    onChanged: (v) =>
                        setState(() => _acceptHealth = v ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    title: const Text(
                      'Sağlık verilerimin beslenme takibi amacıyla işlenmesine açık rıza veriyorum.',
                    ),
                    subtitle: const Text(
                      'Bu onay, boy/kilo vb. özel nitelikli veriler için gereklidir.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      children: [
                        //Text(
                        //  'Politika sürümü: ${PolicyConfig.policyVersion}',
                        //  style: const TextStyle(color: Colors.grey),
                        //),
                        TextButton(
                          onPressed: () async {
                            final ok = await launchUrlString(
                              PolicyConfig.policyUrl,
                              mode: LaunchMode.externalApplication,
                            );
                            if (!ok && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Politika açılırken bir sorun oluştu.',
                                  ),
                                ),
                              );
                            }
                          },
                          child: const Text(
                            'KVKK ve Gizlilik Politikasını oku',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: viewModel.isBusy
                        ? null
                        : () async {
                            final strong2 = RegExp(r'^(?=.*[A-Z])(?=.*[^A-Za-z0-9]).{8,}$');
                            if (!strong2.hasMatch(_password.text)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Şifre en az 8 hane, 1 büyük harf ve 1 özel karakter içermeli.'),
                                ),
                              );
                              return;
                            }
                            if (_password.text != _passwordConfirm.text) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Girilen şifreler uyuşmuyor.'),
                                ),
                              );
                              return;
                            }
                            if (!_acceptKvkk) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Devam etmek için KVKK ve Gizlilik onaylarını kabul etmelisiniz.',
                                  ),
                                ),
                              );
                              return;
                            }
                            if (!_acceptHealth) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Devam etmek için sağlık verisi açık rızasını vermelisiniz.',
                                  ),
                                ),
                              );
                              return;
                            }
                            final err = await viewModel.signUpExtended(
                              email: _email.text,
                              password: _password.text,
                              displayName: _name.text,
                              age: int.tryParse(_age.text),
                              weight: double.tryParse(_weight.text),
                              height: double.tryParse(_height.text),
                              gender: _gender,
                              waistCm: double.tryParse(_waist.text),
                              hipCm: double.tryParse(_hip.text),
                              kvkkAccepted: _acceptKvkk,
                              healthAccepted: _acceptHealth,
                            );
                            if (!mounted) return;
                            if (err == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Kayıt başarılı.'),
                                ),
                              );
                              Navigator.pop(context);
                            } else {
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(SnackBar(content: Text(err)));
                            }
                          },
                    child: viewModel.isBusy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Kayıt Ol'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BmiPreview extends StatefulWidget {
  const _BmiPreview({required this.heightCtrl, required this.weightCtrl});
  final TextEditingController heightCtrl;
  final TextEditingController weightCtrl;
  @override
  State<_BmiPreview> createState() => _BmiPreviewState();
}

class _BmiPreviewState extends State<_BmiPreview> {
  double? _bmi;

  @override
  void initState() {
    super.initState();
    widget.heightCtrl.addListener(_recalc);
    widget.weightCtrl.addListener(_recalc);
    _recalc();
  }

  @override
  void dispose() {
    widget.heightCtrl.removeListener(_recalc);
    widget.weightCtrl.removeListener(_recalc);
    super.dispose();
  }

  void _recalc() {
    final h = double.tryParse(widget.heightCtrl.text);
    final w = double.tryParse(widget.weightCtrl.text);
    double? bmi;
    if (h != null && h > 0 && w != null && w > 0) {
      final m = h / 100.0;
      bmi = w / (m * m);
    }
    setState(() => _bmi = bmi);
  }

  @override
  Widget build(BuildContext context) {
    final text = _bmi == null ? 'BKİ: -' : 'BKİ: ${_bmi!.toStringAsFixed(1)}';
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(text, style: const TextStyle(color: Colors.grey)),
    );
  }
}
