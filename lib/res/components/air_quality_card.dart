import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../models/air_quality_status.dart';
import '../style/app_theme.dart';

class AirQualityCard extends StatefulWidget{
  final AirQualityState airQuality;
  final bool isDeviceOnline;
  final DateTime? lastUpdated;

  const AirQualityCard({
    super.key,
    required this.airQuality,
    required this.isDeviceOnline,
    this.lastUpdated,
  });

  @override
  State<AirQualityCard> createState() => _AirQualityCardState();
}

class _AirQualityCardState extends State<AirQualityCard> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  bool get _shouldPulse => widget.airQuality == AirQualityState.danger && widget.isDeviceOnline;

  @override 
  Widget build(BuildContext context) {
    final quality = widget.airQuality;
    final statusColor = quality.color;
    final glowColor = quality.glowColor;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AM032Colors.bgSurface,
        borderRadius: BorderRadius.circular(20),
        // border: Border.all(color: statusColor.withValues(alpha: opacity))
        boxShadow: [
          BoxShadow(
            color: glowColor,
            blurRadius: 24,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'QUALIDADE DO AR',
                style: Theme.of(context).textTheme.labelSmall,
              ),

              if (widget.lastUpdated != null)
                Text(
                  _formatTime(widget.lastUpdated!),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 11,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 24),
          AnimatedBuilder(
            animation: _pulseAnim, 
            builder: (context, child) {
              final scale = _shouldPulse ? _pulseAnim.value : 1.0;

              return Transform.scale(
                scale: scale,
                child: child,
              );
            },
            child: SizedBox(
              width: 180,
              height: 180,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: glowColor,
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                  ),

                  CustomPaint(
                    size: const Size(180, 180),
                    painter: _GaugePainter(
                      quality: quality,
                      color: statusColor,
                    ),
                  ),

                  AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AM032Colors.bgPrimary,
                      border: Border.all(color: statusColor.withAlpha(1), width: 2),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _qualityIcon(quality),
                          color: statusColor,
                          size: 28,
                        ),
                        const SizedBox(height: 4),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          child: Text(
                            quality.label,
                            key: ValueKey(quality),
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: statusColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          const _QualityScale(),
          
          if (!widget.isDeviceOnline) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AM032Colors.statusOffline.withAlpha(1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AM032Colors.statusOffline),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.cloud_off_outlined,
                    size: 14,
                    color: AM032Colors.statusOffline,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Dispositivo offline - exibindo última leitura',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 11,
                      color: AM032Colors.statusOffline,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _qualityIcon(AirQualityState q) {
    switch (q) {
      case AirQualityState.good: return Icons.eco_outlined;
      case AirQualityState.warning: return Icons.warning_amber_outlined;
      case AirQualityState.danger: return Icons.dangerous_outlined;
    }
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inSeconds < 60) return 'Agora';
    if (diff.inMinutes < 60) return 'Há ${diff.inMinutes}min';
    
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  }
}

class _GaugePainter extends CustomPainter {
  final AirQualityState quality;
  final Color color;

  _GaugePainter({required this.quality, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    const startAngle = math.pi * 0.75;
    const sweepTotal = math.pi * 1.5;

    final trackPaint = Paint()
      ..color = AM032Colors.border
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepTotal, 
        false, 
        trackPaint,
      );

      final progressFraction = _qualityFraction(quality);
      final progressPaint = Paint()
        ..color = color
        ..strokeWidth = 10
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepTotal * progressFraction,
        false,
        progressPaint,
      );

      _drawTickMarks(canvas, center, radius + 14, color);
  }

  double _qualityFraction(AirQualityState q) {
    switch(q) {
      case AirQualityState.good: return 0.33;
      case AirQualityState.warning: return 0.66;
      case AirQualityState.danger: return 1.0;
    }
  }

  void _drawTickMarks(Canvas canvas, Offset center, double radius, Color accent) {
    const tickAngles = [math.pi * 0.75, math.pi * 1.25, math.pi * 1.75];
    final colors = [AM032Colors.statusGood, AM032Colors.statusWarning, AM032Colors.statusDanger];

    for (var i = 0; i < tickAngles.length; i++) {
      final angle = tickAngles[i];
      final x = center.dx + (radius - 6) * math.cos(angle);
      final y = center.dy + (radius - 6) * math.sin(angle);

      canvas.drawCircle(
        Offset(x, y),
        3, 
        Paint()..color = colors[i],
      );
    }
  }

  @override 
  bool shouldRepaint(_GaugePainter old) => old.quality != quality;
}

class _QualityScale extends StatelessWidget {
  const _QualityScale();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ScaleItem(color: AM032Colors.statusGood, label: 'BOA'),
        const SizedBox(width: 16),

        _ScaleItem(color: AM032Colors.statusWarning, label: 'ATENÇÃO'),
        const SizedBox(width: 16),

        _ScaleItem(color: AM032Colors.statusDanger, label: 'PERIGO'),
      ],
    );
  }
}

class _ScaleItem extends StatelessWidget {
  final Color color;
  final String label;

  const _ScaleItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),

        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: color,
            fontSize: 9,
          ),
        ),
      ],
    );
  }
}