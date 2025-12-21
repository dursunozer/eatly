import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../../core/config/policy_config.dart';
import '../../../core/theme/app_theme.dart';
import '../onboarding/onboarding_view.dart';
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
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _passwordConfirm.dispose();
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SignupViewModel>.reactive(
      viewModelBuilder: () => SignupViewModel(),
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: AppTheme.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Başlık
                  const Text(
                    'Hesap Oluştur',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sağlıklı beslenme yolculuğuna başla',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Ad Soyad
                  _buildInputField(
                    controller: _name,
                    label: 'Ad Soyad',
                    icon: Icons.person_outline,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r"[a-zA-ZğüşöçıİĞÜŞÖÇ ]"),
                      ),
                    ],
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 16),

                  // E-posta
                  _buildInputField(
                    controller: _email,
                    label: 'E-posta',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r"[a-zA-Z0-9@_.]"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Şifre
                  _buildInputField(
                    controller: _password,
                    label: 'Şifre',
                    icon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: AppTheme.textSecondary,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'En az 8 karakter, 1 büyük harf ve 1 özel karakter',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Şifre Tekrar
                  _buildInputField(
                    controller: _passwordConfirm,
                    label: 'Şifre Tekrar',
                    icon: Icons.lock_outline,
                    obscureText: _obscurePasswordConfirm,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePasswordConfirm ? Icons.visibility_off : Icons.visibility,
                        color: AppTheme.textSecondary,
                      ),
                      onPressed: () => setState(() => _obscurePasswordConfirm = !_obscurePasswordConfirm),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // KVKK Onayı
                  _buildCheckbox(
                    value: _acceptKvkk,
                    onChanged: (v) => setState(() => _acceptKvkk = v ?? false),
                    title: 'KVKK ve Gizlilik Politikası\'nı kabul ediyorum',
                    onTapLink: () async {
                      await launchUrlString(
                        PolicyConfig.policyUrl,
                        mode: LaunchMode.externalApplication,
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // Sağlık Verisi Onayı
                  _buildCheckbox(
                    value: _acceptHealth,
                    onChanged: (v) => setState(() => _acceptHealth = v ?? false),
                    title: 'Sağlık verilerimin işlenmesine onay veriyorum',
                  ),
                  const SizedBox(height: 32),

                  // Kayıt Ol Butonu
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: viewModel.isBusy ? null : () => _handleSignup(viewModel),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: viewModel.isBusy
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Devam Et',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Giriş Yap Linki
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Zaten hesabın var mı? ',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Text(
                          'Giriş Yap',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        textCapitalization: textCapitalization,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppTheme.primaryColor),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildCheckbox({
    required bool value,
    required Function(bool?) onChanged,
    required String title,
    VoidCallback? onTapLink,
  }) {
    return Row(
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
          child: GestureDetector(
            onTap: onTapLink,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                decoration: onTapLink != null ? TextDecoration.underline : null,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleSignup(SignupViewModel viewModel) async {
    // Validasyonlar
    if (_name.text.trim().isEmpty) {
      _showError('Lütfen adınızı girin');
      return;
    }

    if (_email.text.trim().isEmpty) {
      _showError('Lütfen e-posta adresinizi girin');
      return;
    }

    final strongPassword = RegExp(r'^(?=.*[A-Z])(?=.*[^A-Za-z0-9]).{8,}$');
    if (!strongPassword.hasMatch(_password.text)) {
      _showError('Şifre en az 8 karakter, 1 büyük harf ve 1 özel karakter içermeli');
      return;
    }

    if (_password.text != _passwordConfirm.text) {
      _showError('Şifreler uyuşmuyor');
      return;
    }

    if (!_acceptKvkk) {
      _showError('KVKK ve Gizlilik Politikası\'nı kabul etmelisiniz');
      return;
    }

    if (!_acceptHealth) {
      _showError('Sağlık verisi işleme onayı gereklidir');
      return;
    }

    // Kayıt işlemi
    final error = await viewModel.signUpSimple(
      email: _email.text.trim(),
      password: _password.text,
      displayName: _name.text.trim(),
      kvkkAccepted: _acceptKvkk,
      healthAccepted: _acceptHealth,
    );

    if (!mounted) return;

    if (error == null) {
      // Kayıt başarılı - Onboarding'e yönlendir
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingView()),
      );
    } else {
      _showError(error);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
