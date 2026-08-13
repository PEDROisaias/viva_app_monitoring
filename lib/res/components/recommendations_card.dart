import 'package:flutter/material.dart';
import 'package:viva_app_monitoring/models/air_quality_status.dart';
import '../../view_model/dashboard_view_model.dart';
import '../style/app_theme.dart';

class RecommendationsCard extends StatelessWidget {
  final List<Recommendation> recommendations;
  final AirQualityState airQuality;

  const RecommendationsCard({
    super.key,
    required this.recommendations,
    required this.airQuality,
  });

  @override
  Widget build(BuildContext context) {
    if (recommendations.isEmpty) return const SizedBox.shrink();

    final statusColor = airQuality.color;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AM032Colors.bgSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withAlpha(1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.tips_and_updates_outlined,
                size: 16,
                color: statusColor,
              ),

              const SizedBox(width: 8),
              Text(
                'RECOMENDAÇÕES',
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: statusColor),
              ),
            ],
          ),

          const SizedBox(height: 14),
          ...recommendations.asMap().entries.map(
            (entry) => _RecommendationItem(
              recommendation: entry.value,
              index: entry.key,
              airQuality: airQuality,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationItem extends StatelessWidget {
  final Recommendation recommendation;
  final int index;
  final AirQualityState airQuality;

  const _RecommendationItem({
    required this.recommendation,
    required this.index,
    required this.airQuality,
  });

  Color get _itemColor {
    switch (recommendation.priority) {
      case RecommendationPriority.high:
        return AM032Colors.statusDanger;
      case RecommendationPriority.medium:
        return AM032Colors.statusWarning;
      case RecommendationPriority.low:
        return AM032Colors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: index < 3 ? 12 : 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ícone / emoji
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _itemColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                recommendation.icon,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Texto
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                recommendation.text,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 13,
                  fontWeight:
                      recommendation.priority == RecommendationPriority.high
                      ? FontWeight.w600
                      : FontWeight.w400,
                  color: recommendation.priority == RecommendationPriority.high
                      ? AM032Colors.textPrimary
                      : AM032Colors.textSecondary,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
