import 'package:flutter/material.dart';
import '../style/app_theme.dart';

class BatteryIcon extends StatelessWidget {
  final int percentage;
  final bool charging;

  const BatteryIcon({
    super.key,
    required this.percentage,
    required this.charging,
  });

  Color get _color {
    if (charging) return AM032Colors.accentCyan;
    if (percentage <= 15) return AM032Colors.statusDanger;
    if (percentage <= 30) return AM032Colors.statusWarning;

    return AM032Colors.statusGood;
  }

  IconData get _icon {
    if (charging) return Icons.battery_charging_full;
    if (percentage <= 10) return Icons.battery_0_bar;
    if (percentage <= 30) return Icons.battery_2_bar;
    if (percentage <= 50) return Icons.battery_3_bar;
    if (percentage <= 70) return Icons.battery_4_bar;
    if (percentage <= 90) return Icons.battery_5_bar;

    return Icons.battery_full;
  }

  @override
  Widget build(BuildContext context) {
    return Icon(_icon, size: 20, color: _color);
  }
}
