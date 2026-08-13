import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../res/style/app_theme.dart';
import '../../view_model/dashboard_view_model.dart';
import '../../models/device_heartbeat.dart';
import '../../models/sensor_reading.dart';
import '../../repository/i_mqtt_repository.dart';
import '../../utils/routes/app_routes.dart';
import '../../res/components/connection_header.dart';
import '../../res/components/air_quality_card.dart';
import '../../res/components/sensor_readings_card.dart';
import '../../res/components/recommendations_card.dart';
import '../../res/components/battery_indicator.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AM032Colors.bgPrimary,
      body: SafeArea(
        child: Consumer<DashboardViewModel>(
          builder: (context, vm, _) {
            final state = vm.state;
            return RefreshIndicator(
              onRefresh: vm.forceReconnect,
              color: AM032Colors.accentBlue,
              backgroundColor: AM032Colors.bgSurface,
              child: CustomScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: ConnectionHeader(
                        connectionState: state.connectionState,
                        reconnectAttempt: state.reconnectAttempt,
                        heartbeat: state.heartbeat,
                        onSettingsTap: () =>
                            Navigator.pushNamed(context, AppRoutes.settings),
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                      child: AirQualityCard(
                        airQuality: state.airQuality,
                        isDeviceOnline: state.isDeviceOnlin, // Dar uma olhada depois 
                        lastUpdated: state.lastUpdated,
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: SensorReadingsCard(reading: state.latestReading),
                    ),
                  ),

                  if (state.heartbeat != null)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                        child: DeviceInfoRow(
                          heartbeat: state.heartbeat!,
                          battery: state.latestReading?.battery,
                        ),
                      ),
                    ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                      child: RecommendationsCard(
                        recommendations: state.recommendations,
                        airQuality: state.airQuality,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),

      bottomNavigationBar: const _BottomNav(),
    );
  }
}

class DeviceInfoRow extends StatelessWidget {
  final DeviceHeartbeat heartbeat;
  final BatteryInfo? battery;

  const DeviceInfoRow({super.key, required this.heartbeat, this.battery});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AM032Colors.bgSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AM032Colors.border),
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              WifiSignalIcon(bars: heartbeat.signalBars),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sinal wi-fi',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    '${heartbeat.signalLabel} (${heartbeat.wifiRssi} dBm)',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),

          Container(width: 1, height: 32, color: AM032Colors.border),
          if (battery != null)
            Row(
              children: [
                BatteryIcon(
                  percentage: battery!.percentage,
                  charging: battery!.charging,
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Bateria',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      '${battery!.percentage}%${battery!.charging ? ' ' : ''}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class WifiSignalIcon extends StatelessWidget {
  final int bars;
  const WifiSignalIcon({super.key, required this.bars});

  @override 
  Widget build(BuildContext context) {
    final color = bars >= 3
      ? AM032Colors.statusGood
      : bars >= 2
        ? AM032Colors.statusWarning
        : AM032Colors.statusDanger;
    return Icon(
      bars >= 4 ? Icons.wifi : bars >= 2 ? Icons.wifi_2_bar : Icons.wifi_1_bar,
      color: color, size: 20,
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav();

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
        onDestinationSelected: (i) => _navigate(context, i),
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