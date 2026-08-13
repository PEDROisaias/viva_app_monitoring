import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sensor_reading.dart';
import '../models/mqtt_broker_config.dart';

class LocalStorageService {
  static const String _configKey = 'am032_broker_config';
  static const String _historicKey = 'am032_reading_historic';
  static const int _maxStoredReadings = 2016; // ~7 dias a 5s/leitura

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _instance async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<void> saveBrokerConfig(MqttBrokerConfig config) async {
    final prefs = await _instance;
    await prefs.setString(_configKey, jsonEncode(config.toJson()));
  }

  Future<MqttBrokerConfig?> loadBrokerConfig() async {
    final prefs = await _instance;
    final raw = prefs.getString(_configKey);
    
    if (raw == null ) return null;
    
    try {
      return MqttBrokerConfig.fromJson(jsonDecode(raw) as Map<String, dynamic>); 
    }
    catch (_) {
      return null;
    }
  }

  Future<void> saveHistoric(List<SensorReading> readings) async {
    final prefs = await _instance;
    final capped = readings.length > _maxStoredReadings ? readings.sublist(readings.length - _maxStoredReadings) : readings;
    
    await prefs.setStringList(_historicKey, capped.map((r) => r.toRawJson()).toList());
  }

  Future<List<SensorReading>> loadHistoric() async {
    final prefs = await _instance;
    final raw = prefs.getStringList(_historicKey) ?? [];
    final readings = <SensorReading>[];
    
    for (final item in raw) {
      try {
        readings.add(SensorReading.fromRawJson(item));
      }
      catch (_) {}
    }
    return readings;
  }

  Future<void> clearHistoric() async {
    final prefs = await _instance;
    await prefs.remove(_historicKey);
  }
}