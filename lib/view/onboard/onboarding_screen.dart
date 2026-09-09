import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/enviroment_profile.dart';
import '../../res/style/app_theme.dart';
import '../../view_model/onboarding_view_model.dart';
import 'environment_profile_screen.dart';


class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
 
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
   void _animateToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }
 
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OnboardingViewModel(),
      child: Consumer<OnboardingViewModel>(
        builder: (context, vm, _) {
          return PopScope(
            canPop: !vm.canGoBack,
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop && vm.canGoBack) {
                vm.previousStep();
                _animateToPage(vm.currentStep);
              }
            },
            child: Scaffold(
              backgroundColor: AM032Colors.bgPrimary,
              body: SafeArea(
                child: Column(
                  children: [
                    _OnboardingHeader(
                      vm: vm,
                      onBack: () {
                        vm.previousStep();
                        _animateToPage(vm.currentStep);
                      },
                    ),
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _Section1Local(vm: vm),
                          _Section2Ventilation(vm: vm),
                          _Section3Sources(vm: vm),
                          _Section4Installation(vm: vm),
                          _Section5Confirmation(vm: vm),
                        ],
                      ),
                    ),
                    _OnboardingFooter(
                      vm: vm,
                      onNext: () async {
                        if (vm.isLastStep) {
                          final profile = await vm.saveProfile();
                          if (!context.mounted) return;
                          if (profile != null) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) =>
                                    EnvironmentProfileScreen(profile: profile),
                              ),
                            );
                          }
                        } else {
                          vm.nextStep();
                          _animateToPage(vm.currentStep);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
 
// ─── Header com progresso ────────────────────────────────────────────────────
 
class _OnboardingHeader extends StatelessWidget {
  final OnboardingViewModel vm;
  final VoidCallback onBack;
 
  const _OnboardingHeader({required this.vm, required this.onBack});
 
  static const _stepTitles = [
    'Sobre o Local',
    'Ventilação e Ocupação',
    'Fontes de Poluentes',
    'Instalação do VIVA',
    'Confirmação',
  ];
 
  static const _stepSubtitles = [
    'Onde o VIVA será instalado?',
    'Como o ambiente é utilizado?',
    'O que existe próximo ao sensor?',
    'Onde você vai posicionar o VIVA?',
    'Revise seu perfil de ambiente',
  ];
 
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (vm.canGoBack)
                IconButton(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back_ios_new,
                      color: AM032Colors.textPrimary, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                )
              else
                const SizedBox(width: 8),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Configuração do Ambiente',
                      style: TextStyle(
                        color: AM032Colors.textSecondary,
                        fontSize: 11,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _stepTitles[vm.currentStep],
                      style: const TextStyle(
                        color: AM032Colors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AM032Colors.bgSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${vm.currentStep + 1} / ${OnboardingViewModel.totalSteps}',
                  style: const TextStyle(
                    color: AM032Colors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Barra de progresso segmentada
          Row(
            children: List.generate(
              OnboardingViewModel.totalSteps,
              (i) => Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 3,
                  margin: EdgeInsets.only(right: i < OnboardingViewModel.totalSteps - 1 ? 4 : 0),
                  decoration: BoxDecoration(
                    color: i <= vm.currentStep
                        ? AM032Colors.statusGood
                        : AM032Colors.bgSurface,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _stepSubtitles[vm.currentStep],
            style: TextStyle(
              color: AM032Colors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
 
// ─── Footer com botão de ação ─────────────────────────────────────────────────
 
class _OnboardingFooter extends StatelessWidget {
  final OnboardingViewModel vm;
  final VoidCallback onNext;
 
  const _OnboardingFooter({required this.vm, required this.onNext});
 
  @override
  Widget build(BuildContext context) {
    final isSaving = vm.status == OnboardingStatus.saving;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: (vm.currentStepValid && !isSaving) ? onNext : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AM032Colors.statusGood,
            disabledBackgroundColor: AM032Colors.bgSurface,
            foregroundColor: Colors.black,
            disabledForegroundColor: AM032Colors.textSecondary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
          ),
          child: isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.black54,
                  ),
                )
              : Text(
                  vm.isLastStep ? 'Confirmar e Iniciar' : 'Próximo',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}
 
// ─── Componentes reutilizáveis do wizard ─────────────────────────────────────
 
class _SectionScroll extends StatelessWidget {
  final List<Widget> children;
  const _SectionScroll({required this.children});
 
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      children: children,
    );
  }
}
 
class _QuestionLabel extends StatelessWidget {
  final String number;
  final String text;
  final String? hint;
 
  const _QuestionLabel({required this.number, required this.text, this.hint});
 
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AM032Colors.statusGood.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  number,
                  style: TextStyle(
                    color: AM032Colors.statusGood,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    color: AM032Colors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (hint != null) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 34),
              child: Text(
                hint!,
                style: TextStyle(
                  color: AM032Colors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
 
/// Opção de seleção única (radio-like)
class _SingleOption<T> extends StatelessWidget {
  final T value;
  final T? groupValue;
  final String label;
  final String? icon;
  final ValueChanged<T> onTap;
 
  const _SingleOption({
    required this.value,
    required this.groupValue,
    required this.label,
    this.icon,
    required this.onTap,
  });
 
  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? AM032Colors.statusGood.withOpacity(0.12)
              : AM032Colors.bgSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AM032Colors.statusGood : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Text(icon!, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: selected
                      ? AM032Colors.textPrimary
                      : AM032Colors.textSecondary,
                  fontSize: 14,
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (selected)
              Icon(Icons.check_circle_rounded,
                  color: AM032Colors.statusGood, size: 18),
          ],
        ),
      ),
    );
  }
}
 
/// Opção de seleção múltipla (checkbox-like)
class _MultiOption<T> extends StatelessWidget {
  final T value;
  final bool selected;
  final String label;
  final String? icon;
  final VoidCallback onTap;
 
  const _MultiOption({
    required this.value,
    required this.selected,
    required this.label,
    this.icon,
    required this.onTap,
  });
 
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? AM032Colors.statusGood.withOpacity(0.12)
              : AM032Colors.bgSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AM032Colors.statusGood : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Text(icon!, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: selected
                      ? AM032Colors.textPrimary
                      : AM032Colors.textSecondary,
                  fontSize: 14,
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: selected
                    ? AM032Colors.statusGood
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: selected
                      ? AM032Colors.statusGood
                      : AM032Colors.textSecondary.withOpacity(0.4),
                  width: 1.5,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check, color: Colors.black, size: 14)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
 
class _SectionDivider extends StatelessWidget {
  const _SectionDivider();
  @override
  Widget build(BuildContext context) =>
      const SizedBox(height: 20);
}
 
// ─── Seção 1: Local ──────────────────────────────────────────────────────────
 
class _Section1Local extends StatelessWidget {
  final OnboardingViewModel vm;
  const _Section1Local({required this.vm});
 
  @override
  Widget build(BuildContext context) {
    return _SectionScroll(children: [
      _QuestionLabel(number: '1', text: 'Onde o VIVA será instalado?'),
      ...InstallationLocation.values.map(
        (loc) => _SingleOption<InstallationLocation>(
          value: loc,
          groupValue: vm.location,
          label: loc.label,
          icon: loc.icon,
          onTap: vm.setLocation,
        ),
      ),
      const _SectionDivider(),
      _QuestionLabel(number: '2', text: 'Tipo de ambiente'),
      ...EnvironmentType.values.map(
        (t) => _SingleOption<EnvironmentType>(
          value: t,
          groupValue: vm.environmentType,
          label: t.label,
          onTap: vm.setEnvironmentType,
        ),
      ),
      const _SectionDivider(),
      _QuestionLabel(number: '3', text: 'Tamanho aproximado do ambiente'),
      ...RoomSize.values.map(
        (s) => _SingleOption<RoomSize>(
          value: s,
          groupValue: vm.roomSize,
          label: s.label,
          onTap: vm.setRoomSize,
        ),
      ),
      const _SectionDivider(),
      _QuestionLabel(number: '4', text: 'Altura aproximada do teto'),
      ...CeilingHeight.values.map(
        (h) => _SingleOption<CeilingHeight>(
          value: h,
          groupValue: vm.ceilingHeight,
          label: h.label,
          onTap: vm.setCeilingHeight,
        ),
      ),
      const SizedBox(height: 8),
    ]);
  }
}
 
// ─── Seção 2: Ventilação e Ocupação ─────────────────────────────────────────
 
class _Section2Ventilation extends StatelessWidget {
  final OnboardingViewModel vm;
  const _Section2Ventilation({required this.vm});
 
  @override
  Widget build(BuildContext context) {
    return _SectionScroll(children: [
      _QuestionLabel(number: '5', text: 'Como o ambiente é ventilado normalmente?'),
      ...VentilationType.values.map(
        (v) => _SingleOption<VentilationType>(
          value: v,
          groupValue: vm.ventilation,
          label: v.label,
          onTap: vm.setVentilation,
        ),
      ),
      const _SectionDivider(),
      _QuestionLabel(
        number: '6',
        text: 'Quantas pessoas costumam estar no ambiente?',
      ),
      ...OccupancyCount.values.map(
        (o) => _SingleOption<OccupancyCount>(
          value: o,
          groupValue: vm.occupancy,
          label: o.label,
          onTap: vm.setOccupancy,
        ),
      ),
      const _SectionDivider(),
      _QuestionLabel(
        number: '7',
        text: 'Por quanto tempo as pessoas ficam no ambiente?',
        hint:
            'A duração da exposição é especialmente relevante para monitoramento de CO.',
      ),
      ...OccupancyDuration.values.map(
        (d) => _SingleOption<OccupancyDuration>(
          value: d,
          groupValue: vm.duration,
          label: d.label,
          onTap: vm.setDuration,
        ),
      ),
      const SizedBox(height: 8),
    ]);
  }
}
 
// ─── Seção 3: Fontes de Poluentes ────────────────────────────────────────────
 
class _Section3Sources extends StatelessWidget {
  final OnboardingViewModel vm;
  const _Section3Sources({required this.vm});
 
  @override
  Widget build(BuildContext context) {
    return _SectionScroll(children: [
      _QuestionLabel(
        number: '8',
        text: 'Existem estas fontes no ambiente ou próximo dele?',
        hint: 'Selecione todas que se aplicam.',
      ),
      ...PollutantSource.values.map(
        (s) => _MultiOption<PollutantSource>(
          value: s,
          selected: vm.selectedSources.contains(s),
          label: s.label,
          icon: s.icon,
          onTap: () => vm.toggleSource(s),
        ),
      ),
      const _SectionDivider(),
      _QuestionLabel(
        number: '9',
        text: 'Com que frequência essas atividades ocorrem?',
      ),
      ...PollutantFrequency.values.map(
        (f) => _SingleOption<PollutantFrequency>(
          value: f,
          groupValue: vm.pollutantFrequency,
          label: f.label,
          onTap: vm.setPollutantFrequency,
        ),
      ),
      const _SectionDivider(),
      _QuestionLabel(
        number: '10',
        text:
            'Já houve problemas com fumaça, gases, odores ou ventilação inadequada neste local?',
      ),
      ...PreviousIncident.values.map(
        (i) => _SingleOption<PreviousIncident>(
          value: i,
          groupValue: vm.previousIncident,
          label: switch (i) {
            PreviousIncident.yes => 'Sim',
            PreviousIncident.no => 'Não',
            PreviousIncident.unknown => 'Não sei',
          },
          onTap: vm.setPreviousIncident,
        ),
      ),
      if (vm.showIncidentDetail) ...[
        const SizedBox(height: 12),
        TextField(
          onChanged: vm.setIncidentDescription,
          maxLines: 2,
          style: const TextStyle(color: AM032Colors.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText:
                'Opcional: descreva o problema (fumaça, vazamento, odores...)',
            hintStyle: TextStyle(
              color: AM032Colors.textSecondary,
              fontSize: 13,
            ),
            filled: true,
            fillColor: AM032Colors.bgSurface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
      const SizedBox(height: 8),
    ]);
  }
}
 
// ─── Seção 4: Instalação ─────────────────────────────────────────────────────
 
class _Section4Installation extends StatelessWidget {
  final OnboardingViewModel vm;
  const _Section4Installation({required this.vm});
 
  @override
  Widget build(BuildContext context) {
    final warnings = vm.placementWarnings;
    return _SectionScroll(children: [
      _QuestionLabel(number: '11', text: 'Onde você pretende instalar o VIVA?'),
      ...DevicePlacement.values.map(
        (p) => _SingleOption<DevicePlacement>(
          value: p,
          groupValue: vm.placement,
          label: p.label,
          onTap: vm.setPlacement,
        ),
      ),
      const _SectionDivider(),
      _QuestionLabel(
        number: '12',
        text: 'O aparelho ficará próximo a alguma dessas condições?',
        hint: 'Selecione todas que se aplicam.',
      ),
      ...NearbyCondition.values.map(
        (c) => _MultiOption<NearbyCondition>(
          value: c,
          selected: vm.selectedNearbyConditions.contains(c),
          label: c.label,
          icon: c.icon,
          onTap: () => vm.toggleNearbyCondition(c),
        ),
      ),
      if (warnings.isNotEmpty) ...[
        const SizedBox(height: 12),
        _PlacementWarningCard(warnings: warnings),
      ],
      const SizedBox(height: 8),
    ]);
  }
}
 
class _PlacementWarningCard extends StatelessWidget {
  final List<String> warnings;
  const _PlacementWarningCard({required this.warnings});
 
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AM032Colors.statusWarning.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AM032Colors.statusWarning.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  color: AM032Colors.statusWarning, size: 18),
              const SizedBox(width: 8),
              Text(
                'Atenção ao posicionamento',
                style: TextStyle(
                  color: AM032Colors.statusWarning,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...warnings.map(
            (w) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                w,
                style: TextStyle(
                  color: AM032Colors.textSecondary,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
 
// ─── Seção 5: Confirmação ─────────────────────────────────────────────────────
 
class _Section5Confirmation extends StatelessWidget {
  final OnboardingViewModel vm;
  const _Section5Confirmation({required this.vm});
 
  @override
  Widget build(BuildContext context) {
    final profile = vm.previewProfile;
    if (profile == null) {
      return const Center(
        child: Text(
          'Preencha todas as etapas anteriores.',
          style: TextStyle(color: AM032Colors.textSecondary),
        ),
      );
    }
 
    final thresholds = profile.computedThresholds;
 
    return _SectionScroll(children: [
      // Perfil gerado
      _ConfirmCard(
        title: 'Perfil do Ambiente',
        icon: '🛡️',
        children: [
          _ConfirmRow(label: 'Local', value: profile.location.label),
          _ConfirmRow(
              label: 'Ambiente', value: profile.environmentType.label),
          _ConfirmRow(label: 'Área', value: profile.roomSize.label),
          _ConfirmRow(label: 'Teto', value: profile.ceilingHeight.label),
          _ConfirmRow(label: 'Ventilação', value: profile.ventilation.label),
          _ConfirmRow(label: 'Ocupação', value: profile.occupancy.label),
          _ConfirmRow(
              label: 'Permanência', value: profile.duration.label),
        ],
      ),
      const SizedBox(height: 14),
 
      // Limiares calculados
      _ConfirmCard(
        title: 'Limiares de Alerta Personalizados',
        icon: '⚗️',
        subtitle: thresholds.isCustomized
            ? 'Ajustados com base no seu ambiente'
            : 'Padrão OSHA/NIOSH — sem ajuste necessário',
        children: [
          _ThresholdRow(
            sensor: 'CO (MQ-7)',
            warning: thresholds.coWarningPpm,
            danger: thresholds.coDangerPpm,
          ),
          const SizedBox(height: 6),
          _ThresholdRow(
            sensor: 'Fumaça/Gases (MQ-2/5)',
            warning: thresholds.smokeWarningPpm,
            danger: thresholds.smokeDangerPpm,
          ),
        ],
      ),
      const SizedBox(height: 14),
 
      // Descrição do perfil
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AM032Colors.statusGood.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AM032Colors.statusGood.withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Perfil de Monitoramento',
              style: TextStyle(
                color: AM032Colors.statusGood,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              profile.profileMonitoringLabel,
              style: TextStyle(
                color: AM032Colors.textSecondary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
      if (vm.placementWarnings.isNotEmpty) ...[
        const SizedBox(height: 14),
        _PlacementWarningCard(warnings: vm.placementWarnings),
      ],
      const SizedBox(height: 8),
    ]);
  }
}
 
class _ConfirmCard extends StatelessWidget {
  final String title;
  final String icon;
  final String? subtitle;
  final List<Widget> children;
 
  const _ConfirmCard({
    required this.title,
    required this.icon,
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
          Divider(color: AM032Colors.textSecondary.withOpacity(0.15), height: 1),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}
 
class _ConfirmRow extends StatelessWidget {
  final String label;
  final String value;
 
  const _ConfirmRow({required this.label, required this.value});
 
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
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
 
class _ThresholdRow extends StatelessWidget {
  final String sensor;
  final double warning;
  final double danger;
 
  const _ThresholdRow({
    required this.sensor,
    required this.warning,
    required this.danger,
  });
 
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          sensor,
          style: const TextStyle(
            color: AM032Colors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            _ThresholdBadge(
              label: 'ATENÇÃO',
              value: '≥ ${warning.toStringAsFixed(0)} ppm',
              color: AM032Colors.statusWarning,
            ),
            const SizedBox(width: 8),
            _ThresholdBadge(
              label: 'PERIGO',
              value: '≥ ${danger.toStringAsFixed(0)} ppm',
              color: AM032Colors.statusDanger,
            ),
          ],
        ),
      ],
    );
  }
}
 
class _ThresholdBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
 
  const _ThresholdBadge({
    required this.label,
    required this.value,
    required this.color,
  });
 
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}