import '../models/mqtt_broker_config.dart';
import '../models/mqtt_events.dart';

enum DeviceConnectionState {
  connected,
  connecting,
  reconnecting,
  disconnected,
  error,
}

abstract class IMqttRepository {
  Stream<MqttEvents> get events;
  DeviceConnectionState get connectionState;
  Future<void> connect(MqttBrokerConfig config);
  Future<void> disconnect();
  void publish(String topic, String payload);
}