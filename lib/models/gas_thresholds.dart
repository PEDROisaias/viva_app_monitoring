enum GasType {
  co2,
  co,
  methanol,
  butaneLpg,
}

extension GasTypeLabel on GasType {
  String get label {
    switch (this) {
      case GasType.co2:
        return 'CO₂';
      case GasType.co:
        return 'CO';
      case GasType.methanol:
        return 'Metanol';
      case GasType.butaneLpg:
        return 'Butano / GLP';
    }
  }

  String get unit => 'ppm';
}

enum AlertLevel { safe, warning, critical }

class GasLevelThreshold {
  final GasType gasType;

  final double safeMax;
  final double warningMax;

  const GasLevelThreshold({
    required this.gasType,
    required this.safeMax,
    required this.warningMax,
  });

  AlertLevel evaluate(double ppm) {
    if (ppm <= safeMax) return AlertLevel.safe;
    if (ppm <= warningMax) return AlertLevel.warning;
    return AlertLevel.critical;
  }
 
  GasLevelThreshold copyWith({
    double? safeMax,
    double? warningMax,
  }) {
    return GasLevelThreshold(
      gasType: gasType,
      safeMax: safeMax ?? this.safeMax,
      warningMax: warningMax ?? this.warningMax,
    );
  }

  Map<String, dynamic> toJson() => {
    'gasType': gasType.name,
    'safeMax': safeMax,
    'warningMax': warningMax,
  };

  factory GasLevelThreshold.fromJson(Map<String, dynamic> json) {
    return GasLevelThreshold(
      gasType: GasType.values.byName(json['gasType'] as String),
      safeMax: (json['safeMax'] as num).toDouble(),
      warningMax: (json['warningMax'] as num).toDouble(),
    );
  }
}

class GasThresholds {
  final GasLevelThreshold co2;
  final GasLevelThreshold co;
  final GasLevelThreshold methanol;
  final GasLevelThreshold butaneLpg;
 
  const GasThresholds({
    required this.co2,
    required this.co,
    required this.methanol,
    required this.butaneLpg,
  });

  static const GasThresholds defaults = GasThresholds(
    co2: GasLevelThreshold(
      gasType: GasType.co2, 
      safeMax: 1000, 
      warningMax: 2000,
    ), 
    co: GasLevelThreshold(
      gasType: GasType.co, 
      safeMax: 9, 
      warningMax: 34,
    ), 
    methanol: GasLevelThreshold(
      gasType: GasType.methanol,
      safeMax: 99,
      warningMax: 199,
    ), 
    butaneLpg: GasLevelThreshold(
      gasType: GasType.butaneLpg,
      safeMax: 469,
      warningMax: 999,
    ),
  );

  GasThresholds copyWith({
    GasLevelThreshold? co2,
    GasLevelThreshold? co,
    GasLevelThreshold? methanol,
    GasLevelThreshold? butaneLpg,
  }) {
    return GasThresholds(
      co2: co2 ?? this.co2,
      co: co ?? this.co,
      methanol: methanol ?? this.methanol,
      butaneLpg: butaneLpg ?? this.butaneLpg,
    );
  }

  Map<String, dynamic> toJson() => {
        'co2': co2.toJson(),
        'co': co.toJson(),
        'methanol': methanol.toJson(),
        'butaneLpg': butaneLpg.toJson(),
      };
 
  factory GasThresholds.fromJson(Map<String, dynamic> json) {
    return GasThresholds(
      co2: GasLevelThreshold.fromJson(json['co2'] as Map<String, dynamic>),
      co: GasLevelThreshold.fromJson(json['co'] as Map<String, dynamic>),
      methanol:
          GasLevelThreshold.fromJson(json['methanol'] as Map<String, dynamic>),
      butaneLpg: GasLevelThreshold.fromJson(
          json['butaneLpg'] as Map<String, dynamic>),
    );
  }

  List<GasLevelThreshold> get all => [co2, co, methanol, butaneLpg];
}