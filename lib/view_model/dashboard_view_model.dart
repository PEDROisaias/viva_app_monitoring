import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/sensor_reading.dart';
import '../models/air_quality_status.dart';
import '../models/device_heartbeat.dart';
import '../models/mqtt_broker_config.dart';
import '../models/mqtt_events.dart';
import '../repository/i_mqtt_repository.dart';
import '../repository/mqtt_repository.dart';
import '../data/local_storage_service.dart';
import '../utils/alert_service.dart';

enum RecommendationPriority { low, medium, high }

class Recommendation {
  final String icon;
  final String text;
  final RecommendationPriority priority;


  const Recommendation({
    required this.icon,
    required this.text,
    required this.priority,
  });
}

class DashBoardState {
  final SensorReading? latestReading;
  final AirQualityState airQuality;
  final DeviceConnectionState connectionState;
  final DeviceHeartbeat? heartbeat;
  final List<Recommendation> recommendations;
  final List<SensorReading> historic;
  final DateTime? lastUpdated;
  final String? errorMessage;
  final int reconnectAttempt;

  const DashBoardState({
    this.latestReading,
    this.airQuality = AirQualityState.good,
    this.connectionState = DeviceConnectionState.disconnected,
    this.heartbeat,
    this.recommendations = const [],
    this.historic = const [],
    this.lastUpdated,
    this.errorMessage,
    this.reconnectAttempt = 0,
  });

  DashBoardState copyWith({
    SensorReading? latestReading,
    AirQualityState? airQuality,
    DeviceConnectionState? connectionState,
    DeviceHeartbeat? heartbeat,
    List<Recommendation>? recommendations,
    List<SensorReading>? historic,
    DateTime? lastUpdated,
    String? errorMessage,
    int? reconnectAttempt,
  }) => DashBoardState(
    latestReading: latestReading ?? this.latestReading,
    airQuality: airQuality ?? this.airQuality,
    connectionState: connectionState ?? this.connectionState,
    heartbeat: heartbeat ?? this.heartbeat,
    recommendations: recommendations ?? this.recommendations,
    historic: historic ?? this.historic,
    lastUpdated: lastUpdated ?? this.lastUpdated, 
    errorMessage: errorMessage,
    reconnectAttempt: reconnectAttempt ?? this.reconnectAttempt,
  );

  bool get isDeviceOnlin => heartbeat?.isOnline ?? false;
  bool get hasData => latestReading != null;
}

class DashboardViewModel extends ChangeNotifier{
  static const int _maxHistoricSize = 200;

  final IMqttRepository _mqttRepository;
  final LocalStorageService _storage;
  final AlertService _alertService;

  DashBoardState _state = const DashBoardState();
  StreamSubscription<MqttEvents>? _eventSubscription;


  DashboardViewModel({
    required IMqttRepository mqttRepository,
    required LocalStorageService storage,
    required AlertService alertService,
  }) : _mqttRepository = mqttRepository, _storage = storage, _alertService = alertService {
    _init();
  }

  DashBoardState get state => _state;

  Future<void> _init() async {
    await _loadCachedData();
    _listenToMqttEvents();
    final savedConfig = await _storage.loadBrokerConfig();

    if (savedConfig != null) await connectToBroker(savedConfig);
  }

  Future<void> _loadCachedData() async{
    final historic = await _storage.loadHistoric();

    if (historic.isNotEmpty) {
      _state = _state.copyWith(
        historic: historic,
        latestReading: historic.last,
        airQuality: _qualityFromReading(historic.last),
        recommendations: _buildRecommendations(AirQualityState.good),
      );
      notifyListeners();
    }
  }

  void _listenToMqttEvents() {
    _eventSubscription = _mqttRepository.events.listen((event) {
      switch (event) {
        case MqttConnectedEvent(): 
          _state = _state.copyWith(
            connectionState: DeviceConnectionState.connected,
            errorMessage: null,
            reconnectAttempt: 0,
          );

        case MqttDisconnectedEvent(:final reason):
          _state = _state.copyWith(
            connectionState: DeviceConnectionState.disconnected,
            errorMessage: reason,
          );

        case MqttReconnectingEvent(:final attempt):
          _state = _state.copyWith(
            connectionState: DeviceConnectionState.reconnecting,
            reconnectAttempt: attempt,
          );
        case MqttSensorDataEvent(:final reading):
          final newHistoric = [..._state.historic, reading];

          if (newHistoric.length > _maxHistoricSize) newHistoric.removeAt(0);

          final quality = _qualityFromReading(reading);
          _state = _state.copyWith(
            latestReading: reading,
            airQuality: quality,
            recommendations: _buildRecommendations(quality),
            historic: newHistoric,
            lastUpdated: DateTime.now(),
            errorMessage: null,
          );

          _storage.saveHistoric(newHistoric);
        case MqttStatusEvent(:final status):
          _state = _state.copyWith(
            airQuality: status.state,
            recommendations: _buildRecommendations(status.state),
          );

          if (status.state == AirQualityState.danger) {
            _alertService.triggerDangerAlert(
              mq7Ppm: _state.latestReading?.mq7Ppm,
              mq25Ppm: _state.latestReading?.mq25Ppm,
            );
          }
          else if (status.state == AirQualityState.warning) {
            _alertService.triggerWarningAlert();
          }

        case MqttHeartbeatEvent(:final heartbeat):
          _state = _state.copyWith(heartbeat: heartbeat);

        case MqttErrorEvent(:final message): 
          _state = _state.copyWith(errorMessage: message);
      }

      notifyListeners();
    });
  }

  AirQualityState _qualityFromReading(SensorReading reading) {
    if (reading.mq7.ppm >= 150 || reading.mq25.ppm >= 500) return AirQualityState.danger;
    if (reading.mq7.ppm >= 50 || reading.mq25.ppm >= 150) return AirQualityState.warning;
    return AirQualityState.good; 
  }

  List<Recommendation> _buildRecommendations(AirQualityState state) {
    switch (state) {
      case AirQualityState.good:
        return const [
          Recommendation(icon: '✅' , text: 'Ambiente saúdavel - qualidade do ar dentro dos padrões normais.', priority: RecommendationPriority.low ),
          Recommendation(icon: '🌿', text: 'Continue mantendo o ambiente ventilado.', priority: RecommendationPriority.low),
          Recommendation(icon: '📊', text: 'Monitore as leituras ao longo do dia para identificar tendências.', priority: RecommendationPriority.low ),
        ];
      case AirQualityState.warning:
        return const [
          Recommendation(icon: '⚠️', text: 'Nível de gases elevado — tome precauções imediatas.', priority: RecommendationPriority.medium),
          Recommendation(icon: '🪟', text: 'Abra janelas e portas para ventilar o ambiente.', priority: RecommendationPriority.medium),
          Recommendation(icon: '🔥', text: 'Desligue fogões, aquecedores ou equipamentos a gás.', priority: RecommendationPriority.medium),
          Recommendation(icon: '👤', text: 'Pessoas com problemas respiratórios devem sair do ambiente.', priority: RecommendationPriority.high),
        ];
      case AirQualityState.danger:
        return const [
          Recommendation(icon: '🚨', text: 'PERIGO! Concentração crítica. Evacue o local imediatamente!', priority: RecommendationPriority.high),
          Recommendation(icon: '📵', text: 'Não acione interruptores elétricos — risco de ignição.', priority: RecommendationPriority.high),
          Recommendation(icon: '🚪', text: 'Saia deixando portas abertas para dissipar o gás.', priority: RecommendationPriority.high),
          Recommendation(icon: '📞', text: 'Ligue para o Corpo de Bombeiros: 193.', priority: RecommendationPriority.high),
        ];
    }
  }

  Future<void> connectToBroker(MqttBrokerConfig config) async {
    await _storage.saveBrokerConfig(config);
    await _mqttRepository.connect(config);
  }
 
  Future<void> disconnectFromBroker() async => _mqttRepository.disconnect();
 
  Future<void> forceReconnect() async {
    if (_mqttRepository is MqttRepository) {
      await (_mqttRepository as MqttRepository).forceReconnect();
    } 
  }
 
  List<({DateTime time, int mq7Ppm, int mq25Ppm})> get chartData =>
      _state.historic.map((r) => (time: r.timestamp, mq7Ppm: r.mq7Ppm, mq25Ppm: r.mq25Ppm)).toList();
 
  List<({DateTime time, int mq7Ppm, int mq25Ppm})> chartDataForPeriod(Duration period) {
    final cutoff = DateTime.now().subtract(period);
    return chartData.where((d) => d.time.isAfter(cutoff)).toList();
  }
 
  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }
}