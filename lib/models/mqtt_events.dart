import 'sensor_reading.dart';
import 'air_quality_status.dart';
import 'device_heartbeat.dart';

sealed class MqttEvents {}

class MqttConnectedEvent extends MqttEvents{}

class MqttDisconnectedEvent extends MqttEvents {
  final String reason;
  MqttDisconnectedEvent(this.reason);
}

class MqttReconnectingEvent extends MqttEvents {
  final int attempt;
  final Duration nextRetryIn;
  MqttReconnectingEvent(this.attempt, this.nextRetryIn);
}

class MqttSensorDataEvent extends MqttEvents {
  final SensorReading reading;
  MqttSensorDataEvent(this.reading);
}

class MqttStatusEvent extends MqttEvents {
  final AirQualityStatus status;
  MqttStatusEvent(this.status);
}

class MqttHeartbeatEvent extends MqttEvents {
  final DeviceHeartbeat heartbeat;
  MqttHeartbeatEvent(this.heartbeat);
}

class MqttErrorEvent extends MqttEvents {
  final String message;
  final Object? error;
  MqttErrorEvent(this.message, [this.error]);
}
