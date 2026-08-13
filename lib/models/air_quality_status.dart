import 'dart:convert';

enum AirQualityState {
  good(0, 'BOA', 'Ambiente Seguro'),
  warning(1, 'ATENÇÃO', 'Qualidade Moderada'),
  danger(2, 'PERIGO', 'Risco à saúde');

  const AirQualityState(this.code, this.label, this.description);
  
  final int code;
  final String label;
  final String description;

  static AirQualityState fromCode(int code) => 
  AirQualityState.values.firstWhere(
    (s) => s.code == code,
    orElse: () => AirQualityState.good,
  );
}

class SensorThresholds {
  final double warningPpm;
  final double dangerPpm;

  const SensorThresholds({required this.warningPpm, required this.dangerPpm});

  factory SensorThresholds.fromJson(Map<String, dynamic> json) => SensorThresholds(
    warningPpm: (json['warning_ppm'] as num).toDouble(),
    dangerPpm: (json['danger_ppm'] as num).toDouble(),
  );
}

class AirQualityStatus {
  final String deviceId;
  final DateTime timestamp;
  final AirQualityState state;
  final String triggerdBy;
  final SensorThresholds? thresholds;

  const AirQualityStatus({
    required this.deviceId,
    required this.timestamp,
    required this.state,
    required this.triggerdBy,
    this.thresholds,
  });

  factory AirQualityStatus.fromJson(Map<String, dynamic> json) => AirQualityStatus(
    deviceId: json['device_id'] as String,
    timestamp: DateTime.fromMillisecondsSinceEpoch((json['timestamp'] as int)),
    state: AirQualityState.fromCode(json['state'] as int),
    triggerdBy: json['triggered_by'] as String? ?? 'none',
    thresholds: json['thresholds'] != null ? SensorThresholds.fromJson(json['thresholds'] as Map<String, dynamic>) : null,
  );

  factory AirQualityStatus.fromRawJson(String raw) => AirQualityStatus.fromJson(jsonDecode(raw) as Map<String, dynamic>);
}