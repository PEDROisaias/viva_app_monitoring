import 'dart:async';
import 'package:flutter/foundation.dart';

import '../models/mqtt_broker_config.dart';
import '../models/mqtt_events.dart';
import '../repository/i_mqtt_repository.dart';
import '../repository/mqtt_repository.dart';
import '../data/local_storage_service.dart';

class SettingsViewModel extends ChangeNotifier {
  final LocalStorageService _storage;
  final IMqttRepository _mqttRepository;

  MqttBrokerConfig _config = MqttBrokerConfig.defaults();
  bool _isTesting = false;
  String? _testResult;

  SettingsViewModel({
    required LocalStorageService storage,
    required IMqttRepository mqttRepository,
  }) : _storage = storage,
       _mqttRepository = mqttRepository {
    _load();
  }

  MqttBrokerConfig get config => _config;
  bool get isTesting => _isTesting;
  String? get testResult => _testResult;

  Future<void> _load() async {
    final saved = await _storage.loadBrokerConfig();
    if (saved != null) {
        _config = saved;
        notifyListeners();
    }
  }

  void updateConfig(MqttBrokerConfig config) {
    _config = config;
    notifyListeners();
  }

  Future<void> saveAndApply() async {
    await _storage.saveBrokerConfig(_config);
    await _mqttRepository.connect(_config);
  }

  Future<void> testConnection() async {
    _isTesting = true;
    _testResult = null;
    notifyListeners();

    try {
        final testService = MqttRepository();
        final completer = Completer<String>();

        final sub = testService.events.listen((event) {
            if (!completer.isCompleted) {
                if (event is MqttConnectedEvent) completer.complete('Conexão bem-sucessida!');
                if (event is MqttErrorEvent) completer.complete('Falha: ${event.message}');
            }
        });

        await testService.connect(_config);
        _testResult = await completer.future.timeout(
            const Duration(seconds: 10),
            onTimeout: () => 'Timeoutr: broker não respondeu',
        );

        sub.cancel();
        await testService.disconnect();
        testService.dispose();
    }
    catch (e) {
        _testResult = 'Erro: @e';
    }

    _isTesting = false;
    notifyListeners();
  }
}
