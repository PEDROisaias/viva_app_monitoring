import 'dart:async';
import 'dart:math';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import '../models/mqtt_broker_config.dart';
import '../models/mqtt_events.dart';
import '../models/sensor_reading.dart';
import '../models/air_quality_status.dart';
import '../models/device_heartbeat.dart';
import 'i_mqtt_repository.dart';

class MqttRepository implements IMqttRepository{
  static const int _maxRetryAttempts = 8;
  static const Duration _baseRetryDelay = Duration(seconds: 2);
  static const Duration _maxRetryDelay = Duration(minutes: 2);

  MqttServerClient? _client;
  MqttBrokerConfig? _config;

  final _eventController = StreamController<MqttEvents>.broadcast();
  DeviceConnectionState _connectionState = DeviceConnectionState.disconnected;

  int _reconnectAttempt = 0;
  Timer? _reconnectTimer;
  bool _intentionalDisconnect = false;

  @override
  Stream<MqttEvents> get events => _eventController.stream;

  @override
  DeviceConnectionState get connectionState => _connectionState;

  @override
  Future<void> connect(MqttBrokerConfig config) async {
    _config = config;
    _intentionalDisconnect = false;
    _reconnectAttempt = 0;
    await _performConnect(config);
  }

  Future<void> _performConnect(MqttBrokerConfig config) async {
    _updateState(DeviceConnectionState.connecting);

    try {
      _client = _buildClient(config);
      _configureLastWill(config);

      final result = await _client!.connect(config.username, config.password);

      if (result?.state != MqttConnectionState.connected) {
        throw Exception('Falha na conexão: estado=${result?.state}');
      }

      _reconnectAttempt = 0;
      _updateState(DeviceConnectionState.connected);
      _eventController.add(MqttConnectedEvent());

      _subscribeToTopics(config);
      _listenToMessages();
    }
    catch (e) {
      _eventController.add(MqttErrorEvent('Erro ao conectar ao broker MQTT', e));
      _scheduleReconnect();
    }
  }

  MqttServerClient _buildClient(MqttBrokerConfig config) {
    final client = MqttServerClient.withPort(config.host, config.clientId, config.port);
    client.logging(on: false);
    client.keepAlivePeriod = 30;
    client.connectTimeoutPeriod = 10000;
    client.autoReconnect = false;
    client.onDisconnected = _onDisconnected;
    client.onBadCertificate = (cert) => !config.useSsl;

    if (config.useSsl) client.secure = true;
    if (config.useWebSocket) {
      client.useWebSocket = true;
      client.websocketProtocols = MqttClientConstants.protocolsSingleDefault;
    }
    
    return client;
  }

  void _configureLastWill(MqttBrokerConfig config) {
    final willMessage = MqttConnectMessage()
      .withClientIdentifier(config.clientId)
      .withWillTopic(config.heartbeatTopic)
      .withWillMessage('offline')
      .withWillRetain()
      .withWillQos(MqttQos.atLeastOnce)
      .startClean();
    _client!.connectionMessage = willMessage;
  }

  void _subscribeToTopics(MqttBrokerConfig config) {
    _client?.subscribe(config.sensorDataTopic, MqttQos.atLeastOnce);
    _client?.subscribe(config.sensorStatusTopic, MqttQos.atLeastOnce);
    _client?.subscribe(config.heartbeatTopic, MqttQos.atLeastOnce);
  }

  void _listenToMessages() {
    _client?.updates?.listen((List<MqttReceivedMessage<MqttMessage?>> messages) {
      for (final message in messages) {
        final topic = message.topic;
        final publish = message.payload as MqttPublishMessage;
        final payload = MqttPublishPayload.bytesToStringAsString(publish.payload.message);

        _routeMessage(topic, payload);
      }
    });
  }

  void _routeMessage(String topic, String payload) {
    final config = _config;
    if (config == null) return;

    try {
      if (topic == config.sensorDataTopic) {
        _eventController.add(MqttSensorDataEvent(SensorReading.fromRawJson(payload)));
      }
      else if (topic == config.sensorStatusTopic) {
        _eventController.add(MqttStatusEvent(AirQualityStatus.fromRawJson(payload)));
      }
      else if (topic == config.heartbeatTopic) {
        _eventController.add(MqttHeartbeatEvent(DeviceHeartbeat.fromRawJson(payload)));
      }
    }
    catch (e) {
      _eventController.add(MqttErrorEvent('Erro ao parsear tópico $topic', e));
    }
  }


  @override
  void publish(String topic, String payload) {
    if (_client?.connectionStatus?.state != MqttConnectionState.connected) return;

    final builder = MqttClientPayloadBuilder()..addString(payload);
    _client?.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }

  @override
  Future<void> disconnect() async {
    _intentionalDisconnect = true;
    _reconnectTimer?.cancel();
    _client?.disconnect();
    _updateState(DeviceConnectionState.disconnected);
    _eventController.add(MqttDisconnectedEvent('Desconectado pelo usuário'));
  }

  void _onDisconnected() {
    if (_intentionalDisconnect) return;
    
    _updateState(DeviceConnectionState.disconnected);
    _eventController.add(MqttDisconnectedEvent('Conexão perdida com o broker'));
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_intentionalDisconnect || _reconnectAttempt >= _maxRetryAttempts ) {
      if (_reconnectAttempt >= _maxRetryAttempts) {
        _eventController.add(MqttErrorEvent('Máximo de tentativas atingido.'));
        _updateState(DeviceConnectionState.error);
      }
      return;
    }

    _reconnectAttempt++;
    final delay = _calculateBackoffDelay(_reconnectAttempt);
    _updateState(DeviceConnectionState.reconnecting);
    _eventController.add(MqttReconnectingEvent(_reconnectAttempt, delay));

    _reconnectTimer = Timer(delay, () async {
      if (!_intentionalDisconnect && _config != null) {
        await _performConnect(_config!);
      }
    });
  }

  Duration _calculateBackoffDelay(int attempt) {
    final jitter = Random().nextInt(1000);
    final exponential = _baseRetryDelay.inMilliseconds * pow(2, attempt - 1).toInt();
    final total = min(exponential + jitter, _maxRetryDelay.inMilliseconds);

    return Duration(milliseconds: total);
  }

  Future<void> forceReconnect() async {
    _reconnectAttempt = 0;
    _reconnectTimer?.cancel();
    _client?.disconnect();

    if (_config != null) await _performConnect(_config!);
  }

  void _updateState(DeviceConnectionState state) {
    _connectionState = state;
  }

  void dispose() {
    _reconnectTimer?.cancel();
    _client?.disconnect();
    _eventController.close();
  }
}