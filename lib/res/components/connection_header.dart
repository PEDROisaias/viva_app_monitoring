import 'package:flutter/material.dart';
import 'package:viva_app_monitoring/models/device_heartbeat.dart';
import 'package:viva_app_monitoring/repository/i_mqtt_repository.dart';
import '../style/app_theme.dart';

class ConnectionHeader extends StatelessWidget{
  final DeviceConnectionState connectionState;
  final int reconnectAttempt;
  final DeviceHeartbeat? heartbeat;
  final VoidCallback onSettingsTap;

  const ConnectionHeader({
    super.key,
    required this.connectionState,
    required this.reconnectAttempt,
    required this.heartbeat,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AM-032',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                letterSpacing: 2,
                color: AM032Colors.accentCyan,
              ),
            ),

            Text(
              'Detector de Gases',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),

        const Spacer(),

        _ConnectionBadge(
          connectionState: connectionState,
          reconnectAttempt: reconnectAttempt,
        ),

        const SizedBox(width: 10),

        GestureDetector(
          onTap: onSettingsTap,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AM032Colors.bgSurface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AM032Colors.border),
            ),

            child: const Icon(
              Icons.settings_outlined,
              size: 18,
              color: AM032Colors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _ConnectionBadge extends StatefulWidget {
  final DeviceConnectionState connectionState;
  final int reconnectAttempt;

  const _ConnectionBadge({
    required this.connectionState,
    required this.reconnectAttempt,
  });

  @override
  State<_ConnectionBadge> createState() => _ConnectionBadgeState();
}

class _ConnectionBadgeState extends State<_ConnectionBadge> with SingleTickerProviderStateMixin {
  late AnimationController _blink;

  @override
  void initState() {
    super.initState();
    _blink = AnimationController(
      vsync: this,
      duration: const Duration(microseconds: 800)
    ) ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _blink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final (color, label, blinking) = _stateInfo(widget.connectionState);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4)),
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          blinking
            ? AnimatedBuilder(
              animation: _blink,
              builder: (_, __) => Opacity(
                opacity: _blink.value,
                child: _dot(color),
              ),
            )
            : _dot(color),
          const SizedBox(width: 6),
          Text(
            widget.connectionState == DeviceConnectionState.reconnecting
              ? '$label (${widget.reconnectAttempt})'
              : label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(Color color) => Container(
    width: 6,
    height: 6,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: color
    ),
  );
  (Color, String, bool) _stateInfo(DeviceConnectionState s) {
    switch (s) {
      case DeviceConnectionState.connected: return (AM032Colors.statusGood, 'MQTT Online', false);
      case DeviceConnectionState.connecting: return (AM032Colors.accentBlue, 'Conectando...', false);
      case DeviceConnectionState.reconnecting: return (AM032Colors.statusWarning, 'Reconectando', false);
      case DeviceConnectionState.disconnected: return (AM032Colors.statusOffline, 'Ofline', false);
      case DeviceConnectionState.error: return (AM032Colors.statusDanger, 'Erro', false);
      
    }
  }
}