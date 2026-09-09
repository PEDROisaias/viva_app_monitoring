
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
 
import '../../res/style/app_theme.dart';
import '../../utils/routes/app_routes.dart';
import '../../view_model/auth_view_model.dart';
import 'widgets/auth_text_field.dart';
import 'widgets/viva_logo.dart';
 
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
 
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}
 
class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
 
  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }
 
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
 
    final vm = context.read<AuthViewModel>();
    final success = await vm.register(
      name: _nameCtrl.text.trim(),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Voltar ────────────────────────────────────────────────
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AM032Colors.textSecondary,
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ),
 
                const SizedBox(height: 12),
 
                // ── Logo compacta ─────────────────────────────────────────
                const VivaLogo(compact: true),
 
                const SizedBox(height: 32),
 
                // ── Título ────────────────────────────────────────────────
                Text(
                  'Criar conta',
                  style: TextStyle(
                    color: AM032Colors.textPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Configure seu perfil de monitoramento.',
                  style: TextStyle(
                    color: AM032Colors.textSecondary,
                    fontSize: 14,
                  ),
                ),
 
                const SizedBox(height: 32),
 
                // ── Nome ──────────────────────────────────────────────────
                AuthTextField(
                  controller: _nameCtrl,
                  label: 'Nome',
                  hint: 'Seu nome',
                  prefixIcon: Icons.person_outline_rounded,
                  textCapitalization: TextCapitalization.words,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Informe seu nome.';
                    }
                    return null;
                  },
                ),
 
                const SizedBox(height: 16),
 
                // ── E-mail ────────────────────────────────────────────────
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
                        .hasMatch(v.trim())) {
                      return 'E-mail inválido.';
                    }
                    return null;
                  },
                ),
 
                const SizedBox(height: 16),
 
                // ── Senha ─────────────────────────────────────────────────
                AuthTextField(
                  controller: _passwordCtrl,
                  label: 'Senha',
                  hint: 'Mínimo 6 caracteres',
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
                    if (v == null || v.isEmpty) return 'Crie uma senha.';
                    if (v.length < 6) {
                      return 'Mínimo de 6 caracteres.';
                    }
                    return null;
                  },
                ),
 
                const SizedBox(height: 16),
 
                // ── Confirmar senha ───────────────────────────────────────
                AuthTextField(
                  controller: _confirmCtrl,
                  label: 'Confirmar senha',
                  hint: 'Repita a senha',
                  obscureText: _obscureConfirm,
                  prefixIcon: Icons.lock_outline_rounded,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AM032Colors.textSecondary,
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  validator: (v) {
                    if (v != _passwordCtrl.text) {
                      return 'As senhas não coincidem.';
                    }
                    return null;
                  },
                ),
 
                const SizedBox(height: 12),
 
                // ── Banner de aviso sobre limiares ────────────────────────
                _ThresholdsInfoBanner(),
 
                // ── Erro ──────────────────────────────────────────────────
                _ErrorBanner(),
 
                const SizedBox(height: 24),
 
                // ── Botão cadastrar ───────────────────────────────────────
                _SubmitButton(onPressed: _submit),
 
                const SizedBox(height: 24),
 
                // ── Ir para login ─────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Já tem conta? ',
                      style: TextStyle(
                        color: AM032Colors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        'Entrar',
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
    );
  }
}
 
// ─── Widgets internos ─────────────────────────────────────────────────────────
 
class _ThresholdsInfoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AM032Colors.statusWarning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border:
            Border.all(color: AM032Colors.statusWarning.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded,
              color: AM032Colors.statusWarning, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Os limiares de alerta serão definidos com base no ambiente '
              'do seu dispositivo. Por enquanto, usamos os padrões NIOSH / NR-15.',
              style: TextStyle(
                color: AM032Colors.statusWarning,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
 
class _ErrorBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final error = context.watch<AuthViewModel>().errorMessage;
    if (error == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
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
                'Criar conta',
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
 