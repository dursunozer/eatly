import 'package:eatly/ui/views/main/main_view.dart';
import 'package:eatly/ui/views/onboarding/onboarding_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
import '../../../core/theme/app_theme.dart';
import 'login_viewmodel.dart';
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
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
          children: [
                const SizedBox(height: 60),
                // Logo ve Başlık
                _buildHeader(context),
                const SizedBox(height: 48),
                // Giriş Formu
                _LoginForm(viewModel: viewModel),
              ],
            ),
            ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        // Logo
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.2),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Text(
            '🥗',
            style: TextStyle(fontSize: 48),
          ),
        ),
        const SizedBox(height: 24),
        // Uygulama Adı
        Text(
          'Tekrar Hoş Geldin!',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Hesabına giriş yap ve kaldığın yerden devam et',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  @override
  LoginViewModel viewModelBuilder(BuildContext context) => LoginViewModel();
}

class _LoginForm extends StatefulWidget {
  const _LoginForm({required this.viewModel});
  final LoginViewModel viewModel;
  
  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.viewModel;
    
    return Form(
      key: _formKey,
      child: Column(
      children: [
          // Google ile Giriş
          _buildGoogleButton(vm),
          const SizedBox(height: 24),
          
          // Ayırıcı
          _buildDivider(),
          const SizedBox(height: 24),
          
          // E-posta Alanı
          _buildEmailField(),
          const SizedBox(height: 16),
          
          // Şifre Alanı
          _buildPasswordField(),
          const SizedBox(height: 12),
          
          // Şifremi Unuttum
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ForgotPasswordView()),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
                padding: EdgeInsets.zero,
              ),
              child: const Text('Şifremi Unuttum'),
            ),
          ),
          const SizedBox(height: 24),
          
          // Giriş Yap Butonu
          _buildLoginButton(vm),
          const SizedBox(height: 32),
          
          // Kayıt Ol Linki
          _buildSignUpLink(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildGoogleButton(LoginViewModel vm) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: vm.isBusy ? null : () => _signInWithGoogle(vm),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(color: Colors.grey.shade300),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.white,
        ),
        child: vm.isBusyGoogle
              ? const SizedBox(
                width: 24,
                height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(
                    'https://www.google.com/favicon.ico',
                    width: 24,
                    height: 24,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.g_mobiledata,
                      size: 28,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Google ile Giriş Yap',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
        ),
                ],
              ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade300)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'veya',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey.shade300)),
      ],
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z0-9@_.]")),
      ],
      decoration: InputDecoration(
        labelText: 'E-posta',
        hintText: 'ornek@email.com',
        prefixIcon: Icon(Icons.email_outlined, color: AppTheme.primaryColor),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'E-posta adresinizi girin';
        }
        if (!value.contains('@')) {
          return 'Geçerli bir e-posta adresi girin';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: 'Şifre',
        hintText: '••••••••',
        prefixIcon: Icon(Icons.lock_outline, color: AppTheme.primaryColor),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: Colors.grey,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Şifrenizi girin';
        }
        return null;
      },
    );
  }

  Widget _buildLoginButton(LoginViewModel vm) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: vm.isBusy ? null : () => _signInWithEmail(vm),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: vm.isBusySignIn
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Giriş Yap',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Hesabın yok mu? ',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
        TextButton(
          onPressed: () {
            // Onboarding'e yönlendir (yeni kayıt için)
            widget.viewModel.goToSignUp();
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Kayıt Ol',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _signInWithGoogle(LoginViewModel vm) async {
    final ok = await vm.signInWithGoogle();
    if (!mounted) return;
    
    if (ok) {
      _handleSuccessfulLogin();
    } else {
      final msg = vm.lastError ?? 'Google ile giriş yapılamadı';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _signInWithEmail(LoginViewModel vm) async {
    if (!_formKey.currentState!.validate()) return;

    final ok = await vm.signIn(_emailController.text, _passwordController.text);
    if (!mounted) return;

    if (ok) {
      _handleSuccessfulLogin();
    } else {
      final msg = vm.lastError ?? 'E-posta veya şifre hatalı';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleSuccessfulLogin() {
    if (widget.viewModel.requirePolicyUpdate) {
      Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => const ConsentUpdateView()),
      ).then((updated) {
        if (updated != true) return;
        _navigateToMainOrOnboarding();
      });
    } else {
      _navigateToMainOrOnboarding();
    }
  }

  void _navigateToMainOrOnboarding() {
    if (widget.viewModel.requireOnboarding) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingView()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainView()),
      );
    }
  }
}
