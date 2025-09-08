import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'signup_viewmodel.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  late final TextEditingController _name;
  late final TextEditingController _age;
  late final TextEditingController _weight;
  late final TextEditingController _height;
  late final TextEditingController _waist;
  late final TextEditingController _hip;
  String _gender = 'Erkek';

  @override
  void initState() {
    super.initState();
    _email = TextEditingController();
    _password = TextEditingController();
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
                  TextField(controller: _name, decoration: const InputDecoration(labelText: 'Ad Soyad')),
                  const SizedBox(height: 8),
                  TextField(controller: _email, decoration: const InputDecoration(labelText: 'E-posta')),
                  const SizedBox(height: 8),
                  TextField(controller: _password, decoration: const InputDecoration(labelText: 'Şifre'), obscureText: true),
                  const SizedBox(height: 8),
                  TextField(controller: _age, decoration: const InputDecoration(labelText: 'Yaş'), keyboardType: TextInputType.number),
                  const SizedBox(height: 8),
                  TextField(controller: _weight, decoration: const InputDecoration(labelText: 'Kilo (kg)'), keyboardType: TextInputType.number),
                  const SizedBox(height: 8),
                  TextField(controller: _height, decoration: const InputDecoration(labelText: 'Boy (cm)'), keyboardType: TextInputType.number),
                  const SizedBox(height: 8),
                  TextField(controller: _waist, decoration: const InputDecoration(labelText: 'Bel çevresi (cm)'), keyboardType: TextInputType.number),
                  const SizedBox(height: 8),
                  TextField(controller: _hip, decoration: const InputDecoration(labelText: 'Kalça çevresi (cm)'), keyboardType: TextInputType.number),
                  const SizedBox(height: 8),
                  _BmiPreview(heightCtrl: _height, weightCtrl: _weight),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _gender,
                    items: const [
                      DropdownMenuItem(value: 'Erkek', child: Text('Erkek')),
                      DropdownMenuItem(value: 'Kadın', child: Text('Kadın'))
                    ],
                    onChanged: (v) => setState(() => _gender = v ?? 'Erkek'),
                    decoration: const InputDecoration(labelText: 'Cinsiyet'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: viewModel.isBusy
                        ? null
                        : () async {
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
                            );
                            if (!mounted) return;
                            if (err == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Kayıt başarılı.')),
                              );
                              Navigator.pop(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(err)),
                              );
                            }
                          },
                    child: viewModel.isBusy
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
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
