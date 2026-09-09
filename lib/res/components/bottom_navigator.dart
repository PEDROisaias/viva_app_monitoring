import 'package:flutter/material.dart';

import '../../res/style/app_theme.dart';
import '../../utils/routes/app_routes.dart';

class BottomNavigator extends StatelessWidget {
	const BottomNavigator({super.key});

	@override
	Widget build(BuildContext context) {
		final currentRoute = ModalRoute.of(context)?.settings.name ?? AppRoutes.home;

		return Container(
			decoration: const BoxDecoration(
				color: AM032Colors.bgSurface,
				border: Border(top: BorderSide(color: AM032Colors.border)),
			),
			child: NavigationBar(
				backgroundColor: Colors.transparent,
				indicatorColor: AM032Colors.accentBlue.withAlpha(1),
				selectedIndex: _routeIndex(currentRoute),
				onDestinationSelected: (index) => _navigate(context, index),
				destinations: const [
					NavigationDestination(
						icon: Icon(Icons.dashboard_outlined),
						selectedIcon: Icon(Icons.dashboard, color: AM032Colors.accentBlue),
						label: 'Dashboard',
					),
					NavigationDestination(
						icon: Icon(Icons.show_chart_outlined),
						selectedIcon: Icon(Icons.show_chart, color: AM032Colors.accentBlue),
						label: 'Histórico',
					),
					NavigationDestination(
						icon: Icon(Icons.settings_outlined),
						selectedIcon: Icon(Icons.settings, color: AM032Colors.accentBlue),
						label: 'Config',
					),
				],
			),
		);
	}

	int _routeIndex(String route) {
		if (route == AppRoutes.historic) return 1;
		if (route == AppRoutes.settings) return 2;
		return 0;
	}

	void _navigate(BuildContext context, int index) {
		final routes = [AppRoutes.home, AppRoutes.historic, AppRoutes.settings];
		Navigator.pushReplacementNamed(context, routes[index]);
	}
}
