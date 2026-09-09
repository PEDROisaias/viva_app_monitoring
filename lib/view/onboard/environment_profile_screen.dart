
import 'package:flutter/material.dart';
import '../../models/enviroment_profile.dart';
import '../../res/style/app_theme.dart';
import '../../utils/routes/app_routes.dart';
 
class EnvironmentProfileScreen extends StatelessWidget {
  final EnvironmentProfile profile;
 
  const EnvironmentProfileScreen({super.key, required this.profile});
 
  @override
  Widget build(BuildContext context) {
    final thresholds = profile.computedThresholds;
 
    return Scaffold(
      backgroundColor: AM032Colors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 8),
                children: [
                  // ── Ícone de sucesso ──────────────────────────────────────
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AM032Colors.statusGood.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          profile.location.icon,
                          style: const TextStyle(fontSize: 36),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
 
                  // ── Título ────────────────────────────────────────────────
                  const Center(
                    child: Text(
                      'Configuração concluída',
                      style: TextStyle(
                        color: AM032Colors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Text(
                      'Seu perfil de ambiente foi criado com sucesso.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AM032Colors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
 
                  // ── Card: Resumo do perfil ────────────────────────────────
                  _ProfileCard(
                    icon: '🏠',
                    title: 'Resumo do Ambiente',
                    children: [
                      _ProfileRow(
                          label: 'Local',
                          value: profile.location.label),
                      _ProfileRow(
                          label: 'Tipo',
                          value: profile.environmentType.label),
                      _ProfileRow(
                          label: 'Área',
                          value: profile.roomSize.label),
                      _ProfileRow(
                          label: 'Ocupação',
                          value: profile.occupancy.label),
                      _ProfileRow(
                          label: 'Ventilação',
                          value: profile.ventilation.label),
                      if (profile.pollutantSources
                          .where((s) => s != PollutantSource.none)
                          .isNotEmpty)
                        _ProfileRow(
                          label: 'Fontes',
                          value: profile.pollutantSources
                              .where((s) => s != PollutantSource.none)
                              .map((s) => s.label)
                              .join(', '),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
 
                  // ── Card: Limiares ────────────────────────────────────────
                  _ProfileCard(
                    icon: '⚗️',
                    title: 'Limiares de Alerta',
                    subtitle: thresholds.isCustomized
                        ? 'Personalizados para o seu ambiente'
                        : 'Padrão OSHA/NIOSH',
                    children: [
                      _ThresholdSection(
                        sensor: 'CO — MQ-7',
                        warning: thresholds.coWarningPpm,
                        danger: thresholds.coDangerPpm,
                        baseWarning: CustomThresholds.defaults.coWarningPpm,
                        baseDanger: CustomThresholds.defaults.coDangerPpm,
                      ),
                      const SizedBox(height: 12),
                      _ThresholdSection(
                        sensor: 'Fumaça / Gases — MQ-2/5',
                        warning: thresholds.smokeWarningPpm,
                        danger: thresholds.smokeDangerPpm,
                        baseWarning:
                            CustomThresholds.defaults.smokeWarningPpm,
                        baseDanger: CustomThresholds.defaults.smokeDangerPpm,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
 
                  // ── Card: Perfil de monitoramento ─────────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AM032Colors.statusGood.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AM032Colors.statusGood.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.shield_outlined,
                                color: AM032Colors.statusGood, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Perfil de Monitoramento',
                              style: TextStyle(
                                color: AM032Colors.statusGood,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          profile.profileMonitoringLabel,
                          style: TextStyle(
                            color: AM032Colors.textSecondary,
                            fontSize: 13,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
 
                  // ── Aviso de posicionamento (se houver) ───────────────────
                  if (profile.hasPlacementWarning) ...[
                    const SizedBox(height: 14),
                    _PlacementWarningBanner(
                        conditions: profile.interferenceConditions),
                  ],
 
                  const SizedBox(height: 8),
                ],
              ),
            ),
 
            // ── Botão de entrada no app ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      AppRoutes.home,
                      (_) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AM032Colors.statusGood,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Ir para o Dashboard',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
 
// ─── Componentes internos ─────────────────────────────────────────────────────
 
class _ProfileCard extends StatelessWidget {
  final String icon;
  final String title;
  final String? subtitle;
  final List<Widget> children;
 
  const _ProfileCard({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.children,
  });
 
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AM032Colors.bgSurface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AM032Colors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: TextStyle(
                          color: AM032Colors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(
            color: AM032Colors.textSecondary.withOpacity(0.15),
            height: 1,
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}
 
class _ProfileRow extends StatelessWidget {
  final String label;
  final String value;
 
  const _ProfileRow({required this.label, required this.value});
 
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(
                color: AM032Colors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AM032Colors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
 
class _ThresholdSection extends StatelessWidget {
  final String sensor;
  final double warning;
  final double danger;
  final double baseWarning;
  final double baseDanger;
 
  const _ThresholdSection({
    required this.sensor,
    required this.warning,
    required this.danger,
    required this.baseWarning,
    required this.baseDanger,
  });
 
  @override
  Widget build(BuildContext context) {
    final warningAdjusted = warning != baseWarning;
    final dangerAdjusted = danger != baseDanger;
 
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          sensor,
          style: const TextStyle(
            color: AM032Colors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _ThresholdChip(
              label: 'ATENÇÃO',
              value: '≥ ${warning.toStringAsFixed(0)} ppm',
              color: AM032Colors.statusWarning,
              adjusted: warningAdjusted,
              baseValue: baseWarning,
            ),
            const SizedBox(width: 8),
            _ThresholdChip(
              label: 'PERIGO',
              value: '≥ ${danger.toStringAsFixed(0)} ppm',
              color: AM032Colors.statusDanger,
              adjusted: dangerAdjusted,
              baseValue: baseDanger,
            ),
          ],
        ),
      ],
    );
  }
}
 
class _ThresholdChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool adjusted;
  final double baseValue;
 
  const _ThresholdChip({
    required this.label,
    required this.value,
    required this.color,
    required this.adjusted,
    required this.baseValue,
  });
 
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                if (adjusted) ...[
                  const SizedBox(width: 4),
                  Icon(Icons.tune_rounded, color: color, size: 10),
                ],
              ],
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (adjusted)
              Text(
                'base: ${baseValue.toStringAsFixed(0)} ppm',
                style: TextStyle(
                  color: color.withOpacity(0.6),
                  fontSize: 10,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
 
class _PlacementWarningBanner extends StatelessWidget {
  final List<NearbyCondition> conditions;
 
  const _PlacementWarningBanner({required this.conditions});
 
  @override
  Widget build(BuildContext context) {
    final labels = conditions.map((c) => c.label).join(', ');
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AM032Colors.statusWarning.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AM032Colors.statusWarning.withOpacity(0.35),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded,
              color: AM032Colors.statusWarning, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Atenção ao posicionamento',
                  style: TextStyle(
                    color: AM032Colors.statusWarning,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'O VIVA está próximo de $labels, o que pode interferir '
                  'nas medições. Para resultados mais precisos, posicione-o '
                  'afastado de correntes diretas de ar.',
                  style: TextStyle(
                    color: AM032Colors.textSecondary,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
