import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../view_model/dashboard_view_model.dart';
import '../../res/style/app_theme.dart';

enum ChartPeriod {
  today('Hoje', Duration(hours: 24)),
  week('Semana', Duration(days: 7)),
  month('Mês', Duration(days: 30));

  const ChartPeriod(this.label, this.duration);
  final String label;
  final Duration duration;
}

class HistoricScreen extends StatefulWidget{
  const HistoricScreen({super.key});

  @override
  State<HistoricScreen> createState() => _HistroricScreenState();
}

class _HistroricScreenState extends State<HistoricScreen> {
  ChartPeriod _selectedPeriod = ChartPeriod.today;
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AM032Colors.bgPrimary,
      body: SafeArea(
        child: Consumer<DashboardViewModel>(
          builder: (context, vm, _) {
            final data = vm.chartDataForPeriod(_selectedPeriod.duration);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Histórico',
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontSize: 24,
                        ),
                      ),

                      Text (
                        '${data.length} leituras registradas',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: ChartPeriod.values.map((p) {
                      final selected = p == _selectedPeriod;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),

                        child: GestureDetector(
                          onTap: () => setState(() => _selectedPeriod = p),

                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                ?AM032Colors.accentBlue
                                : AM032Colors.bgSurface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: selected
                                  ? AM032Colors.accentBlue
                                  : AM032Colors.border,
                              ),
                            ),

                            child: Text(
                              p.label,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: selected
                                  ? Colors.white
                                  : AM032Colors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: data.isEmpty
                    ? _EmptyChart()
                    : Padding(
                      padding: const EdgeInsets.fromLTRB(4, 0, 20, 0),
                      child: _GasChart(data: data, period: _selectedPeriod),
                    ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: _Legend(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _GasChart extends StatelessWidget {
  final List<({DateTime time, int mq7Ppm, int mq25Ppm})> data;
  final ChartPeriod period;

  const _GasChart({required this.data, required this.period});

  @override
  Widget build(BuildContext context) {
    final sampled = _sample(data, maxPoints: 80);

    final mq7Spots = sampled.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.mq7Ppm.toDouble());
    }).toList();

    final mq25Spots = sampled.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.mq25Ppm.toDouble());
    }).toList();

    final maxY = sampled 
      .fold<double>(0, (m, e) => [m, e.mq7Ppm.toDouble(), e.mq25Ppm.toDouble()]
      .reduce((a, b) => a > b ? a : b));

    return LineChart(
      duration: const Duration(microseconds: 250),
      LineChartData(
        backgroundColor: Colors.transparent,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: AM032Colors.border,
            strokeWidth: 1,
            dashArray: [4, 4],
          ),
        ),

        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              getTitlesWidget: (v, m) => Text(
                '${v.toInt()}',
                style: const TextStyle(
                  fontSize: 10,
                  color: AM032Colors.textMuted,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ),

          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: (sampled.length / 4).ceilToDouble(),
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= sampled.length) return const SizedBox.shrink();
                return Text(
                  _formatTime(sampled[idx].time, period),
                  style: const TextStyle(
                    fontSize: 10,
                    color: AM032Colors.textMuted,
                    fontFamily: 'Inter',
                  ),
                );
              },
            ),
          ),
        ),

        lineBarsData: [
          LineChartBarData(
            spots: mq7Spots,
            color: AM032Colors.accentBlue,
            barWidth: 2,
            isCurved: true,
            curveSmoothness: 0.3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AM032Colors.accentBlue.withValues(alpha: 0.15),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          LineChartBarData(
            spots: mq25Spots,
            color: AM032Colors.accentCyan,
            barWidth: 2,
            isCurved: true,
            curveSmoothness: 0.3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AM032Colors.accentCyan.withValues(alpha: 0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ],

        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AM032Colors.bgElevated,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((ts) {
                final label = ts.barIndex == 0 ? 'CO (MQ-7)' : 'Fumaça (MQ-2/5)';
                final color = ts.barIndex == 0 ? AM032Colors.accentBlue : AM032Colors.accentCyan;
                return LineTooltipItem(
                  '$label\n${ts.y.toInt()} PPM', 
                  TextStyle(
                    color: color,
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w600
                  ),
                );
              }).toList();
            },
          ),
        ),
        minY: 0,
        maxY: (maxY * 1.2).ceilToDouble(),
      ),
    );
  }

  List<T> _sample<T>(List<T> list, {required int maxPoints}) {
    if (list.length <= maxPoints) return list;
    final step = list.length / maxPoints;
    return List.generate(maxPoints, (i) => list[(i * step).floor()]);
  }

  String _formatTime(DateTime dt, ChartPeriod period) {
    switch (period) {
      case ChartPeriod.today:
        return '${dt.hour.toString().padLeft(2, '0')}h';

      case ChartPeriod.week: 
        const days = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
        return days[dt.weekday % 7];

      case ChartPeriod.month:
        return '${dt.day}/${dt.month}';
    }
  }
}

class _EmptyChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.show_chart, size: 48, color: AM032Colors.textMuted),
          const SizedBox(height: 12),
          Text(
            'Sem dados para este período',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendItem(color: AM032Colors.accentBlue, label: 'CO - MQ-7 (PPM)'),
        const SizedBox(width: 24),
        _LegendItem(color: AM032Colors.accentCyan, label: 'Fumaça/Gases - MQ-2/5 (PPM)'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 20, height: 2, color: color),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11)),
      ],
    );
  }
}