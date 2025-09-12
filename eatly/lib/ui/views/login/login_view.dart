import 'package:eatly/ui/views/home/home_view.dart';
import 'package:eatly/ui/views/main/main_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
import 'login_viewmodel.dart';
import 'signup_view.dart';
import 'forgot_password_view.dart';
import 'consent_update_view.dart';

class LoginView extends StackedView<LoginViewModel> {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    LoginViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Container(
        padding: const EdgeInsets.only(left: 25.0, right: 25.0),
        child: Center(
          child: _LoginForm(viewModel: viewModel),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignupView()),
                );
              },
              child: const Text('Kayıt ol'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ForgotPasswordView()),
                );
              },
              child: const Text('Şifremi unuttum'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  LoginViewModel viewModelBuilder(BuildContext context) => LoginViewModel();
}

class _LoginForm extends StatefulWidget {
  const _LoginForm({super.key, required this.viewModel});
  final LoginViewModel viewModel;
  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.viewModel;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _email,
          decoration: const InputDecoration(labelText: 'E-posta'),
          keyboardType: TextInputType.emailAddress,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z0-9@_.]")),
          ],
        ),
        const SizedBox(height: 12),
        _PasswordField(controller: _password),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: vm.isBusySignIn
              ? null
              : () async {
                  // Giriş öncesi şifre karmaşıklık kontrolü
                  final strong = RegExp(r'^(?=.*[A-Z])(?=.*[^A-Za-z0-9]).{8,}$');
                  if (!strong.hasMatch(_password.text)) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Şifre en az 8 hane, 1 büyük harf ve 1 özel karakter içermeli.')),
                    );
                    return;
                  }
                  final ok = await vm.signIn(_email.text, _password.text);
                  if (!mounted) return;
                  if (ok) {
                    if (widget.viewModel.requirePolicyUpdate) {
                      final updated = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(builder: (_) => const ConsentUpdateView()),
                      );
                      if (updated != true) return;
                    }
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const MainView()),
                    );
                  } else {
                    final msg = vm.lastError ?? 'E‑posta veya şifre hatalı';
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(msg)),
                    );
                  }
                },
          child: vm.isBusySignIn
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Giriş Yap'),
        ),
      ],
    );
  }
}

class _PasswordField extends StatefulWidget {
  const _PasswordField({required this.controller});
  final TextEditingController controller;
  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscure = true;
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _obscure,
      decoration: InputDecoration(
        labelText: 'Şifre',
        suffixIcon: IconButton(
          icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
    );
  }
}
