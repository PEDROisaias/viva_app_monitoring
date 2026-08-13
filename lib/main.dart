import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'repository/mqtt_repository.dart';
import 'data/local_storage_service.dart';
import 'utils/alert_service.dart';
import 'utils/routes/app_routes.dart';
import 'view_model/dashboard_view_model.dart';
import 'view_model/settings_view_model.dart';
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
      child: const AM032App(),
    ),
  );
}

class AM032App extends StatelessWidget {
  const AM032App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AM-032 - Detector de Gases',
      theme: AM032Theme.dark,
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.home,
      routes: AppRoutes.routes,
    );
  }
}

