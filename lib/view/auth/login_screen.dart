
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
 
import '../../res/style/app_theme.dart';
import '../../utils/routes/app_routes.dart';
import '../../view_model/auth_view_model.dart';
import 'widgets/auth_text_field.dart';
import 'widgets/viva_logo.dart';
 
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
 
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
 
  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
 
    final vm = context.read<AuthViewModel>();
    final success = await vm.login(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
    );
 
    if (success && mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AM032Colors.bgPrimary,
       body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Logo ──────────────────────────────────────────────────
                  const VivaLogo(),
                  const SizedBox(height: 12),
                  Text(
                    'APP MONITORING',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AM032Colors.textSecondary,
                      fontSize: 12,
                      letterSpacing: 3,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
 
                  const SizedBox(height: 48),
 
                  // ── Título ────────────────────────────────────────────────
                  Text(
                    'Entrar',
                    style: TextStyle(
                      color: AM032Colors.textPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Continue monitorando em tempo real.',
                    style: TextStyle(
                      color: AM032Colors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
 
                  const SizedBox(height: 32),
 
                  // ── Campos ────────────────────────────────────────────────
                  AuthTextField(
                    controller: _emailCtrl,
                    label: 'E-mail',
                    hint: 'seu@email.com',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.mail_outline_rounded,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Informe o e-mail.';
                      }
                      if (!RegExp(r'^[\w\.\+\-]+@[\w\-]+\.[a-z]{2,}$')
                          .hasMatch(v)) {
                        return 'E-mail inválido.';
                      }
                      return null;
                    },
                  ),
 
                  const SizedBox(height: 16),
 
                  AuthTextField(
                    controller: _passwordCtrl,
                    label: 'Senha',
                    hint: '••••••••',
                    obscureText: _obscurePassword,
                    prefixIcon: Icons.lock_outline_rounded,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AM032Colors.textSecondary,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Informe a senha.';
                      return null;
                    },
                  ),
 
                  const SizedBox(height: 12),
 
                  // ── Erro ──────────────────────────────────────────────────
                  _ErrorBanner(),
 
                  const SizedBox(height: 24),
 
                  // ── Botão entrar ──────────────────────────────────────────
                  _SubmitButton(onPressed: _submit),
 
                  const SizedBox(height: 24),
 
                  // ── Ir para cadastro ──────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Não tem conta? ',
                        style: TextStyle(
                          color: AM032Colors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(
                            context, AppRoutes.register),
                        child: Text(
                          'Cadastre-se',
                          style: TextStyle(
                            color: AM032Colors.statusGood,
                            fontSize: 14,
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
        ),
      ),
    );
  }
}
 
// ─── Widgets internos ─────────────────────────────────────────────────────────
 
class _ErrorBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final error = context.watch<AuthViewModel>().errorMessage;
    if (error == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AM032Colors.statusDanger.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AM032Colors.statusDanger.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded,
              color: AM032Colors.statusDanger, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: TextStyle(
                color: AM032Colors.statusDanger,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
 
class _SubmitButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _SubmitButton({required this.onPressed});
 
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: vm.isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AM032Colors.statusGood,
          foregroundColor: Colors.black,
          disabledBackgroundColor: AM032Colors.statusGood.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: vm.isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.black54,
                ),
              )
            : const Text(
                'Entrar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }
}