import 'package:flutter/material.dart';
import '../../view/home/home_screen.dart';
import '../../view/historic/historic_screen.dart';
import '../../view/onboard/settings_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String historic = '/historic';
  static const String settings = '/settings';

  static Map<String, WidgetBuilder> get routes => {
    home: (_) => const HomeScreen(),
    historic: (_) => const HistoricScreen(),
    settings: (_) => const SettingsScreen(),
  };
}