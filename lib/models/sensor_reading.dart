import 'dart:convert';

enum GasType {
  smoke('SMOKE', 'Fumaça'),
  lpg('LPG', 'GLP'),
  propane('PROPANE', 'Propano'),
  hydrogen('HYDROGEN', 'Hidrogênio'),
  mixed('MIXED', 'Mistura');

  const GasType(this.raw, this.label);
  final String raw;
  final String label;

  static GasType fromString(String raw) => GasType.values.firstWhere((g) => g.raw == raw, orElse: () => GasType.mixed);
}

class MQ7Reading {
  final double ppm;
  final int rawAdc;

  const MQ7Reading({required this.ppm, required this.rawAdc});

  factory MQ7Reading.fromJson(Map<String, dynamic> json) => MQ7Reading(
    ppm: (json['ppm'] as num).toDouble(),
    rawAdc: json['raw_adc'] as int,
  );

  Map<String, dynamic> toJson() => {
    'ppm': ppm,
    'raw_adc': rawAdc,
  };
}
class MQ25Reading {
  final double ppm;
  final int rawAdc;
  final GasType gasType;

  const MQ25Reading({required this.ppm, required this.rawAdc, required this.gasType});

  factory MQ25Reading.fromJson(Map<String, dynamic> json) => MQ25Reading(
    ppm: (json['ppm'] as num).toDouble(),
    rawAdc: json['raw_adc'] as int,
    gasType: GasType.fromString(json['gas_type'] as String? ?? 'MIXED'),
  );

  Map<String, dynamic> toJson() => {
    'ppm': ppm,
    'raw_adc': rawAdc,
    'gas_type': gasType.raw,
  };
}
class BatteryInfo {
  final int percentage;
  final double voltage;
  final bool charging;

  const BatteryInfo({required this.percentage, required this.voltage, required this.charging});

  factory BatteryInfo.fromJson(Map<String, dynamic> json) => BatteryInfo(
    percentage: json['percentage'] as int,
    voltage: (json['voltage'] as num).toDouble(),
    charging: json['charging'] as bool,
  );

  Map<String, dynamic> toJson() => {
    'percentage': percentage,
    'voltage': voltage,
    'charging': charging,
  };
}

class SensorReading {
  final String deviceId;
  final DateTime timestamp;
  final MQ7Reading mq7;
  final MQ25Reading mq25;
  final BatteryInfo battery;

  const SensorReading({
    required this.deviceId,
    required this.timestamp,
    required this.mq7,
    required this.mq25,
    required this.battery,
  });

  factory SensorReading.fromJson(Map<String, dynamic> json) {
    final sensors = json['sensors'] as Map<String, dynamic>;

    return SensorReading(
      deviceId: json['device_id'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch((json['timestamp'] as int)),
      mq7: MQ7Reading.fromJson(sensors['mq7'] as Map<String, dynamic>),
      mq25: MQ25Reading.fromJson(sensors['mq25'] as Map<String, dynamic>),
      battery: BatteryInfo.fromJson(sensors['battery'] as Map<String, dynamic>),
    );
  }

  factory SensorReading.fromRawJson(String raw) => SensorReading.fromJson(jsonDecode(raw) as Map<String, dynamic>);
        
    int get mq7Ppm => mq7.ppm.round();
    int get mq25Ppm => mq25.ppm.round();

    Map<String, dynamic> toJson() => {
      'device_id': deviceId,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'sensors': {
        'mq7': mq7.toJson(),
        'mq25': mq25.toJson(),
        },
      'battery': battery.toJson(),
    };

    String toRawJson() => jsonEncode(toJson());
}