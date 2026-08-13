import 'package:flutter/material.dart';
import 'package:viva_app_monitoring/models/sensor_reading.dart';
import '../style/app_theme.dart';

class SensorReadingsCard extends StatelessWidget{
  final SensorReading? reading;

  const SensorReadingsCard({super.key, this.reading});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AM032Colors.bgSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AM032Colors.border),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'LEITURAS DOS SENSORES',
            style: Theme.of(context).textTheme.labelSmall,
          ),
          
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SensorTile(
                  label: 'Monóxido de Carbono',
                  sublabel: 'Sensor MQ-7',
                  icon: Icons.air,
                  ppm: reading?.mq7Ppm,
                  maxPpm: 200,
                  warningThreshold: 50,
                  dangerThreshold: 150,
                ),
              ),

              const SizedBox(width: 12),
              Expanded(
                child: _SensorTile(
                  label: 'Fumaça / Gases',
                  sublabel: reading != null ? 'MQ-2/5 MQ-2/5 · ${reading!.mq25.gasType.label}' : 'Sensor MQ-2/5',
                  icon: Icons.cloud_outlined,
                  ppm: reading?.mq25Ppm,
                  maxPpm: 1000,
                  warningThreshold: 150,
                  dangerThreshold: 500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SensorTile extends StatelessWidget {
  final String label;
  final String sublabel;
  final IconData icon;
  final int? ppm;
  final int maxPpm;
  final int warningThreshold;
  final int dangerThreshold;

  const _SensorTile({
    required this.label,
    required this.sublabel,
    required this.icon,
    required this.ppm,
    required this.maxPpm,
    required this.warningThreshold,
    required this.dangerThreshold,
  });

  Color get _ppmColor {
    if (ppm == null) return AM032Colors.textMuted;
    if (ppm! >= dangerThreshold) return AM032Colors.statusDanger;
    if (ppm! >= warningThreshold) return AM032Colors.statusWarning;
    return AM032Colors.statusGood;
  }

  double get _progressFraction {
    if (ppm == null) return 0;
    return (ppm! / maxPpm).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final color = _ppmColor;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AM032Colors.bgElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(1)),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AM032Colors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Row(
              key: ValueKey(ppm),
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  ppm != null ? '$ppm' : '--',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontSize: 36,
                    color: color,
                    fontFeatures: [const FontFeature.tabularFigures()],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4, left: 4),
                  child: Text(
                    'PPM',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 11,
                      color: AM032Colors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _progressFraction,
              backgroundColor: AM032Colors.border,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 4,
            ),
          ),

          const SizedBox(height: 6),
          Text(
            sublabel,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 10),
          ),
        ],
      ),
    );
  }
}