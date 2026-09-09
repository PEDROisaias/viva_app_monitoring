import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'repository/mqtt_repository.dart';
import 'data/local_storage_service.dart';
import 'data/auth_service.dart';
import 'utils/alert_service.dart';
import 'utils/routes/app_routes.dart';
import 'view_model/dashboard_view_model.dart';
import 'view_model/settings_view_model.dart';
import 'view_model/auth_view_model.dart';
import 'view/auth/splash_screen.dart';
import 'view/auth/login_screen.dart';
import 'view/auth/register_screen.dart';
import 'view/onboard/onboarding_screen.dart';
import 'view/home/home_screen.dart';
import 'view/historic/historic_screen.dart';
import 'view/onboard/settings_screen.dart';
import 'res/style/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp, 
    DeviceOrientation.portraitDown, 
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  final mqttRepository = MqttRepository();
  final storageService = LocalStorageService();
  final alertService = AlertService();
  final authService = AuthService();


  await alertService.initialize();
  await alertService.requestPermissions();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(authService),
        ),
        ChangeNotifierProvider(
          create: (_) => DashboardViewModel(
            mqttRepository: mqttRepository, 
            storage: storageService, 
            alertService: alertService
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsViewModel(
            storage: storageService, 
            mqttRepository: mqttRepository
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VIVA Monitoring',
      theme: AM032Theme.dark,
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash:      (_) => const SplashScreen(),
        AppRoutes.login:       (_) => const LoginScreen(),
        AppRoutes.register:    (_) => const RegisterScreen(),
        AppRoutes.onboarding:  (_) => const OnboardingScreen(),
        AppRoutes.home:        (_) => const HomeScreen(),
        AppRoutes.historic:    (_) => const HistoricScreen(),
        AppRoutes.settings:    (_) => const SettingsScreen(),
      },
    );
  }
}