import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:viva_app_monitoring/view/historic/historic_screen.dart';
import 'package:viva_app_monitoring/view/home/home_screen.dart';
import 'package:viva_app_monitoring/view/onboard/settings_screen.dart';

import 'repository/mqtt_repository.dart';
import 'data/local_storage_service.dart';
import 'utils/alert_service.dart';
import 'utils/routes/app_routes.dart';
import 'view_model/dashboard_view_model.dart';
import 'view_model/settings_view_model.dart';
import 'view_model/onboarding_view_model.dart';
import 'view/onboard/onboarding_screen.dart';
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
  

  await alertService.initialize();
  await alertService.requestPermissions();
  final onboardingDone = await OnboardingViewModel.isOnboardingDone();

  runApp(
    MultiProvider(
      providers: [
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
      child: MyApp(onboardingDone: onboardingDone),
    ),
  );
}
class MyApp extends StatelessWidget {
  final bool onboardingDone;
  const MyApp({super.key, required this.onboardingDone});
 
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AM032Theme.dark,
      // Decide a rota inicial
      initialRoute: onboardingDone ? AppRoutes.home : AppRoutes.onboarding,
      routes: {
        AppRoutes.onboarding: (_) => const OnboardingScreen(),
        AppRoutes.home:       (_) => const HomeScreen(),
        AppRoutes.historic:    (_) => const HistoricScreen(),
        AppRoutes.settings:   (_) => const SettingsScreen(),
      },
    );
  }
}