
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
 
import '../../res/style/app_theme.dart';
import '../../utils/routes/app_routes.dart';
import '../../view_model/auth_view_model.dart';
import '../../view_model/onboarding_view_model.dart';
import 'widgets/viva_logo.dart';
 
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
 
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}
 
class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;
 
  @override
  void initState() {
    super.initState();
 
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _fadeCtrl.forward();
 
    _decideRoute();
  }
 
  Future<void> _decideRoute() async {
    // Tempo mínimo para o splash ser percebido visualmente
    await Future.wait([
      context.read<AuthViewModel>().checkSession(),
      Future.delayed(const Duration(milliseconds: 1400)),
    ]);

    if (!mounted) return;

    final authStatus = context.read<AuthViewModel>().status;
    if (authStatus != AuthStatus.authenticated) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
      return;
    }

    final onboardingDone = await OnboardingViewModel.isOnboardingDone();
    if (!mounted) return;

    if (!onboardingDone) {
      Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
      return;
    }

    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }
 
  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AM032Colors.bgPrimary,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const VivaLogo(),
              const SizedBox(height: 12),
              Text(
                'APP MONITORING',
                style: TextStyle(
                  color: AM032Colors.textSecondary,
                  fontSize: 11,
                  letterSpacing: 3.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 64),
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AM032Colors.statusGood.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}