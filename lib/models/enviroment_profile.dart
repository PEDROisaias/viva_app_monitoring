enum InstallationLocation {
  residence,
  school,
  office,
  commerce,
  kitchen,
  garage,
  industry,
  laboratory,
  greenhouse,
  other;

  String get label => switch (this) {
    InstallationLocation.residence => 'Residência',
    InstallationLocation.school => 'Escola / Sala de aula',
    InstallationLocation.office => 'Escritório',
    InstallationLocation.commerce => 'Comércio',
    InstallationLocation.kitchen => 'Cozinha / Restaurante',
    InstallationLocation.garage => 'Garagem / Oficina',
    InstallationLocation.industry => 'Indústria',
    InstallationLocation.laboratory => 'Laboratório',
    InstallationLocation.greenhouse => 'Estufa / Ambiente agrícola',
    InstallationLocation.other => 'Outro',
  };

  String get icon => switch (this) {
    InstallationLocation.residence => '🏠',
    InstallationLocation.school => '🏫',
    InstallationLocation.office => '🏢',
    InstallationLocation.commerce => '🏪',
    InstallationLocation.kitchen => '🍳',
    InstallationLocation.garage => '🔧',
    InstallationLocation.industry => '🏭',
    InstallationLocation.laboratory => '🧪',
    InstallationLocation.greenhouse => '🌿',
    InstallationLocation.other => '📍',
  };
}

enum EnvironmentType {
  indoorClosed,
  indoorVentilated,
  semiOpen,
  outdoorCovered;

  String get label => switch (this) {
      EnvironmentType.indoorClosed => 'Interno fechado',
      EnvironmentType.indoorVentilated => 'Interno com bastante ventilação',
      EnvironmentType.semiOpen => 'Semiaberto',
      EnvironmentType.outdoorCovered => 'Externo coberto',
  };
}

enum RoomSize {
  upTo10,
  from10to30,
  from30to60,
  above60,
  unknown;
 
  String get label => switch (this) {
    RoomSize.upTo10 => 'Até 10 m²',
    RoomSize.from10to30 => '10 a 30 m²',
    RoomSize.from30to60 => '30 a 60 m²',
    RoomSize.above60 => 'Mais de 60 m²',
    RoomSize.unknown => 'Não sei',
  };

  double get aproximatedArea => switch (this) {
    RoomSize.upTo10 => 8.0,
    RoomSize.from10to30 => 20.0,
    RoomSize.from30to60 => 45.0,
    RoomSize.above60 => 80.0,
    RoomSize.unknown => 30.0,
  };
}

enum CeilingHeight {
  upTo2_5,
  from2_5to3_5,
  above3_5,
  unknown;

  String get label => switch (this) {
    CeilingHeight.upTo2_5 => 'Até 2,5 m',
    CeilingHeight.from2_5to3_5 => '2,5 a 3,5 m',
    CeilingHeight.above3_5 => 'Acima de 3,5 m',
    CeilingHeight.unknown => 'Não sei',
  }

  double get aproximatedHeight => switch (this) {
    CeilingHeight.upTo2_5 => 2.3,
    CeilingHeight.from2_5to3_5 => 3.0,
    CeilingHeight.above3_5 => 4.0,
    CeilingHeight.unknown => 2.7,
  };
}

enum VentilationType {
  windowsDoors,
  fan,
  airConditioning,
  exhaustSystem,
  combined,
  none;

  String get label => switch (this) {
    VentilationType.windowsDoors => 'Janelas e portas',
    VentilationType.fan => 'Ventilador',
    VentilationType.airConditioning => 'Ar condicionado',
    VentilationType.exhaustSystem => 'Exaustor / sistema de ventilação',
    VentilationType.combined => 'Combinação de Sistemas',
    VentilationType.none => 'Praticamente nenhum',
  };

  double get ventilationFactor => switch (this) {
    VentilationType.windowsDoors => 1.0,
    VentilationType.fan => 0.9,
    VentilationType.airConditioning => 0.85,
    VentilationType.exhaustSystem => 1.2,
    VentilationType.combined => 1.3,
    VentilationType.none => 0.5,
  };
}

enum OccupancyCount {
  oneToTwo,
  threeToFive,
  sixToTen,
  elevenToTwenty,
  aboveTwenty,
  varies;

  String get label => switch (this) {
    OccupancyCount.oneToTwo => '1 a 2 pessoas',
    OccupancyCount.threeToFive => '3 a 5 pessoas',
    OccupancyCount.sixToTen => '6 a 10 pessoas',
    OccupancyCount.elevenToTwenty => '11 a 20 pessoas',
    OccupancyCount.aboveTwenty => 'Mais de 20 pessoas',
    OccupancyCount.varies => 'Varia muito',
  };

  int get aproximatePeople => switch (this) {
    OccupancyCount.oneToTwo => 2,
    OccupancyCount.threeToFive => 4,
    OccupancyCount.sixToTen => 8,
    OccupancyCount.elevenToTwenty => 15,
    OccupancyCount.aboveTwenty => 25,
    OccupancyCount.varies => 10,
  };

}

enum OccupancyDuration {
  lessThan1h,
  oneToFour,
  fourToEight,
  moreThan8,

  String get label => switch (this) {
    OccupancyDuration.lessThan1h => 'Menos de 1 hora',
    OccupancyDuration.oneToFour => '1 a 4 horas',
    OccupancyDuration.fourToEight => '4 a 8 horas',
    OccupancyDuration.moreThan8 => 'Mais de 8 horas',
  };
}
 
enum PollutantSource {
  gasStoveOven,
  gasHeater,
  combustionVehicles,
  cigaretteSmoke,
  paintsVarnishes,
  cleaningProducts,
  alcoholChemicals,
  fuels,
  industrialMachines,
  materialBurning,
  none,
  other;
 
  String get label => switch (this) {
    PollutantSource.gasStoveOven => 'Fogão ou forno a gás',
    PollutantSource.gasHeater => 'Aquecedor a gás',
    PollutantSource.combustionVehicles => 'Veículos ou motores a combustão',
    PollutantSource.cigaretteSmoke => 'Fumaça de cigarro / vape',
    PollutantSource.paintsVarnishes => 'Tintas, vernizes ou solventes',
    PollutantSource.cleaningProducts => 'Produtos de limpeza',
    PollutantSource.alcoholChemicals => 'Álcool ou outros produtos químicos',
    PollutantSource.fuels => 'Combustíveis',
    PollutantSource.industrialMachines => 'Máquinas ou processos industriais',
    PollutantSource.materialBurning => 'Queima de materiais',
    PollutantSource.none => 'Nenhuma dessas fontes',
    PollutantSource.other => 'Outra',
  };
 
  String get icon => switch (this) {
    PollutantSource.gasStoveOven => '🍳',
    PollutantSource.gasHeater => '🔥',
    PollutantSource.combustionVehicles => '🚗',
    PollutantSource.cigaretteSmoke => '🚬',
    PollutantSource.paintsVarnishes => '🖌️',
    PollutantSource.cleaningProducts => '🧹',
    PollutantSource.alcoholChemicals => '⚗️',
    PollutantSource.fuels => '⛽',
    PollutantSource.industrialMachines => '⚙️',
    PollutantSource.materialBurning => '💨',
    PollutantSource.none => '✅',
    PollutantSource.other => '❓',
  };
 
  /// Quais sensores este poluente afeta mais
  bool get affectsCO => [
    PollutantSource.gasStoveOven,
    PollutantSource.gasHeater,
    PollutantSource.combustionVehicles,
    PollutantSource.materialBurning,
    PollutantSource.industrialMachines,
  ].contains(this);
 
  bool get affectsSmoke => [
    PollutantSource.cigaretteSmoke,
    PollutantSource.paintsVarnishes,
    PollutantSource.materialBurning,
    PollutantSource.industrialMachines,
    PollutantSource.fuels,
    PollutantSource.alcoholChemicals,
  ].contains(this);
}


enum PollutantFrequency {
  constantly,
  daily,
  fewTimesWeek,
  rarely,
  never;
 
  String get label => switch (this) {
    PollutantFrequency.constantly => 'Constantemente',
    PollutantFrequency.daily => 'Todos os dias',
    PollutantFrequency.fewTimesWeek => 'Algumas vezes por semana',
    PollutantFrequency.rarely => 'Raramente',
    PollutantFrequency.never => 'Nunca',
  };
 
  /// Multiplicador de risco: 1.0 = base
  double get riskMultiplier => switch (this) {
    PollutantFrequency.constantly => 1.4,
    PollutantFrequency.daily => 1.2,
    PollutantFrequency.fewTimesWeek => 1.0,
    PollutantFrequency.rarely => 0.85,
    PollutantFrequency.never => 0.7,
  };
}
 
enum PreviousIncident { yes, no, unknown }
 
enum DevicePlacement {
  wall,
  desk,
  shelf,
  nearMachine,
  undefined;
 
  String get label => switch (this) {
    DevicePlacement.wall => 'Parede',
    DevicePlacement.desk => 'Mesa / Bancada',
    DevicePlacement.shelf => 'Prateleira',
    DevicePlacement.nearMachine => 'Próximo a máquina / equipamento',
    DevicePlacement.undefined => 'Ainda não defini',
  };
}
 
enum NearbyCondition {
  windowDoor,
  airConditioning,
  fan,
  exhaust,
  stove,
  smokeSource,
  chemicals,
  vehiclesMotors,
  none;
 
  String get label => switch (this) {
    NearbyCondition.windowDoor => 'Janela ou porta',
    NearbyCondition.airConditioning => 'Ar-condicionado',
    NearbyCondition.fan => 'Ventilador',
    NearbyCondition.exhaust => 'Exaustor',
    NearbyCondition.stove => 'Fogão',
    NearbyCondition.smokeSource => 'Fonte de fumaça',
    NearbyCondition.chemicals => 'Produtos químicos',
    NearbyCondition.vehiclesMotors => 'Veículos / Motores',
    NearbyCondition.none => 'Nenhuma dessas',
  };
 
  String get icon => switch (this) {
    NearbyCondition.windowDoor => '🪟',
    NearbyCondition.airConditioning => '❄️',
    NearbyCondition.fan => '🌀',
    NearbyCondition.exhaust => '💨',
    NearbyCondition.stove => '🍳',
    NearbyCondition.smokeSource => '💨',
    NearbyCondition.chemicals => '⚗️',
    NearbyCondition.vehiclesMotors => '🚗',
    NearbyCondition.none => '✅',
  };
 
  bool get causesMeasurementInterference => [
    NearbyCondition.windowDoor,
    NearbyCondition.airConditioning,
    NearbyCondition.fan,
    NearbyCondition.exhaust,
  ].contains(this);
}
 

class EnvironmentProfile {
  // Seção 1
  final InstallationLocation location;
  final EnvironmentType environmentType;
  final RoomSize roomSize;
  final CeilingHeight ceilingHeight;
 
  // Seção 2
  final VentilationType ventilation;
  final OccupancyCount occupancy;
  final OccupancyDuration duration;
 
  // Seção 3
  final List<PollutantSource> pollutantSources;
  final PollutantFrequency pollutantFrequency;
  final PreviousIncident previousIncident;
  final String? previousIncidentDescription;
 
  // Seção 4
  final DevicePlacement placement;
  final List<NearbyCondition> nearbyConditions;
 
  const EnvironmentProfile({
    required this.location,
    required this.environmentType,
    required this.roomSize,
    required this.ceilingHeight,
    required this.ventilation,
    required this.occupancy,
    required this.duration,
    required this.pollutantSources,
    required this.pollutantFrequency,
    required this.previousIncident,
    this.previousIncidentDescription,
    required this.placement,
    required this.nearbyConditions,
  });

  double get environmentVolume => roomSize.approximateArea * ceilingHeight.approximateHeight;

  bool get hasPlacementWarning => nearbyConditions.any((c) => c.causesMeasurementInterference);

  List<NearbyCondition> get interferenceConditions => nearbyConditions.where((c) => c.causesMeasurementInterference).toList();

   CustomThresholds get computedThresholds {
    const baseCoWarning = 50.0;
    const baseCoDanger = 150.0;
    const baseSmokeWarning = 150.0;
    const baseSmokeDanger = 500.0;

    final confinementFactor = _confinementFactor();

    final ventFactor = ventilation.ventilationFactor;

    final freqFactor = pollutantFrequency.riskMultiplier;

    final hasCoSources = pollutantSources.any((s) => s.affectsCO);
    final hasSmokeSources = pollutantSources.any((s) => s.affectsSmoke);
    final coSourcesFactor = hasCoSources ? 0.85 : 1.0;
    final smokeSourceFactor = hasSmokeSources ? 0.85 : 1.0;

    final incidentFactor = previousIncident == PreviousIncident.yes ? 0.9 : 1.0;

    final occupationDensity = occupancy.aproximatePeople / environmentVolume;
    final densityFactor = occupationDensity > 0.3 ? 0.85 : 1.0;

    final coAdjust = confinementFactor * ventFactor * coSourceFactor * freqFactor * incidentFactor * densityFactor;
    final smokeAdjust = confinementFactor * ventFactor * smokeSourceFactor * freqFactor * incidentFactor * densityFactor;

    final coWarning = (baseCoWarning * coAdjust).clamp(20.0, 50.0).roundTodouble();
    final coDanger = (baseCoDanger * coAdjust).clamp(70.0, 150.0).roundTodouble();
    final smokeWarning = (baseSmokeWarning * smokeAdjust).clamp(60.0, 150.0).roundTodouble();
    final smokeDanger = (baseSmokeDanger * smokeAdjust).clamp(200.0, 500.0).roundTodouble();

    return CustomThresholds(
      coWarningPpm: coWarning,
      coDangerPpm: coDanger,
      smokeWarningPpm: smokeWarning,
      smokeDangerPpm: smokeDanger,
    );
  }
}

double _confinementFactor() {
  if (environmentType == EnvironmentType.outdoorCovered) return 1.3;
  if (environmentType == EnvironmentType.semiOpen) return 1.15;
  if (environmentType == EnvironmentType.indoorVentilated) return 1.05;

  return environmentVolume > 150 ? 1.0 : 0.85;
}

String get profileMonitoringLabel {
  final isHighOccupancy = occupancy == OccupancyCount.eleventToTwenty || occupancy == OccupancyCount.aboveTwenty;
  final isLongDuration = duration == OccupancyDuration.fourToEight || duration == OccupancyDuration.moreThan8h;
  final hasCriticalSources = pollutantSources.any((s) => 
    s == PollutantSource.combustionVehicles || 
    s == PollutantSource.gasHeater ||
    s == PollutantSource.industrialMachines);

  if (hasCriticalSources) {
    return 'Ambiente com fontes de risco elevado de CO e fumaça.'
    'Monitoramento contínuo e alertas antecipados ativados.';
  }
  if (isHighOccupancy && isLongDuration) {
    return 'Ambiente coletivo com permanência prolongada. '
      'Atenção especial à renovação do ar e qualidade geral.';
  }
  if (ventilation == VentilationType.none) {
    return 'Ambiente ventilação deficiente. '
      'Limiares reduzidos para alertas mais precoces.';
  }
  return 'Perfil padrão configurado com base nas características do ambiente.';
}

Map <String, dynamic> toJson() => {
  'location': location.name,
  'environmentType': environmentType.name,
  'roomSize': roomSize.name,
  'ceilingHeight': ceilingHeight.name,
  'ventilation': ventilation.name,
  'occupancy': occupancy.name,
  'duration': duration.name,
  'pollutantSources': pollutantSources.map((s) => s.name).toList(),
  'pollutantFrequency': pollutantFrequency.name,
  'previousIncident': previousIncident.name,
  'previousIncidentDescription': previousIncidentDescription,
  'placement': placement.name,
  'nearbyConditions': nearbyConditions.map((c) => c.name).toList(),
};

factory EnvironmentProfile.fromJson(Map<String, dynamic> json) => EnvironmentProfile(
  location: InstallationLocation.values.byName(json['location']),
  environmentType: EnvironmentType.values.byName(json['environmentType']),
  roomSize: RoomSize.values.byName(json['roomSize']),
  ceilingHeight: CeilingHeight.values.byName(json['ceilingHeight']),
  ventilation: VentilationType.values.byName(json['ventilation']),
  occupancy: OccupancyCount.values.byName(json['occupancy']),
  duration: OccupancyDuration.values.byName(json['duration']),
  pollutantSources: (json['pollutantSources'] as List).map((s) => PollutantSource.values.byName(s)).toList(),
  pollutantFrequency: PollutantFrequency.values.byName(json['pollutantFrequency']),
  previousIncident: PreviousIncident.values.byName(json['previousIncident']),
  previousIncidentDescription: json['previousIncidentDescription'],
  placement: DevicePlacement.values.byName(json['placement']),
  nearbyConditions: (json['nearbyConditions'] as List).map((c) => NearbyCondition.values.byName(c)).toList(),
);

class CustomThresholds {
  final double coWarningPpm;
  final double coDangerPpm;
  final double smokeWarningPpm;
  final double smokeDangerPpm;

  const CustomThresholds({
    required this.coWarningPpm,
    required this.coDangerPpm,
    required this.smokeWarningPpm,
    required this.smokeDangerPpm,
  });

  static const defaults = CustomThresholds(
    coWarningPpm: 50,
    coDangerPpm: 150,
    smokeWarningPpm: 150,
    smokeDangerPpm: 500,
  );

  bool get isCustomized => 
    coWarningPpm != defaults.coWarningPpm ||
    coDangerPpm != defaults.coDangerPpm ||
    smokeWarningPpm != defaults.smokeWarningPpm ||
    smokeDangerPpm != defaults.smokeDangerPpm;

  Map <String, dynamic> ToJson() => {
    'coWarningPpm': coWarningPpm,
    'coDangerPpm': coDangerPpm,
    'smokeWarningPpm': smokeWarningPpm,
    'smokeDangerPpm': smokeDangerPpm,
  };

  factory CustomThresholds.fromJson(Map<String, dynamic> json) => CustomThresholds(
    coWarningPpm: (json['coWarningPpm'] as num).toDouble(),
    coDangerPpm: (json['coDangerPpm'] as num).toDouble(),
    smokeWarningPpm: (json['smokeWarningPpm'] as num).toDouble(),
    smokeDangerPpm: (json['smokeDangerPpm'] as num).toDouble(),
  );
}