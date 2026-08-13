import 'dart:convert';

class DeviceHeartbeat {
  final String deviceId; 
  final bool isOnline;
  final DateTime timestamp;
  final String firmwareVersion;
  final int uptimeSeconds;
  final int wifiRssi;

  const DeviceHeartbeat({
    required this.deviceId,
    required this.isOnline,
    required this.timestamp,
    required this.firmwareVersion,
    required this.uptimeSeconds,
    required this.wifiRssi,
  });

  factory DeviceHeartbeat.fromJson(Map<String, dynamic> json) => 
  DeviceHeartbeat(
    deviceId: json['device_id'] as String,
    isOnline: (json['status'] as String) == 'online',
    timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
    firmwareVersion: json['firmware_version'] as String? ?? '0.0.0',
    uptimeSeconds: json['uptime_seconds'] as int? ?? 0,
    wifiRssi: json['wifi_rssi'] as int? ?? -100,
  );

  factory DeviceHeartbeat.fromRawJson(String raw) {
    if (raw == 'offline') {
      return DeviceHeartbeat(
        deviceId: 'unknow',
        isOnline: false,
        timestamp: DateTime.now(), 
        firmwareVersion: '-', 
        uptimeSeconds: 0, 
        wifiRssi: -100,
        );
    }

    return DeviceHeartbeat.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  } 

  String get signalLabel {
    if (wifiRssi >= -50) return 'Excelente';
    if (wifiRssi >= -65) return 'Bom';
    if (wifiRssi >= -75) return 'Regular';
    return 'Fraco';
  }

  int get signalBars {
    if (wifiRssi >= -50) return 4;
    if (wifiRssi >= -65) return 3;
    if (wifiRssi >= -75) return 2;
    if (wifiRssi >= -85) return 1;
    return 0;
  }
}