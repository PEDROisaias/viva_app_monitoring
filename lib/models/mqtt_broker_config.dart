
class MqttBrokerConfig {
  final String host;
  final int port;
  final String clientId;
  final String topicPrefix;
  final String? username;
  final String? password;
  final bool useSsl;
  final bool useWebSocket;

  const MqttBrokerConfig({
    required this.host,
    this.port = 1883,
    required this.clientId,
    this.topicPrefix = 'am032',
    this.username,
    this.password,
    this.useSsl = false,
    this.useWebSocket = false,
  });

  factory MqttBrokerConfig.defaults() => MqttBrokerConfig(
    host: 'broker.hivemq.com',
    port: 1883,
    clientId: 'am032_app_${DateTime.now().millisecondsSinceEpoch}',
    topicPrefix: 'am032',
  );

  factory MqttBrokerConfig.fromJson(Map<String, dynamic> json) => MqttBrokerConfig(
    host: json['host'] as String,
    port: json['port'] as int? ?? 1883,
    clientId: json['client_id'] as String,
    topicPrefix: json['topic_prefix'] as String? ?? 'am032',
    username: json['username'] as String?,
    password: json['password'] as String?,
    useSsl: json['use_ssl'] as bool? ?? false,
    useWebSocket: json['use_websocket'] as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {
    'host': host,
    'port': port,
    'client_id': clientId,
    'topic_prefix': topicPrefix,
    if (username != null) 'username': username,
    if (password != null) 'password': password,
    'use_ssl': useSsl,
    'use_websocket': useWebSocket,
  };

  MqttBrokerConfig copyWith({
    String? host,
    int? port,
    String? clientId,
    String? topicPrefix,
    String? username,
    String? password,
    bool? useSsl,
    bool? useWebSocket,
  }) => 

  MqttBrokerConfig(
    host: host ?? this.host,
    port: port ?? this.port,
    clientId: clientId ?? this.clientId,
    topicPrefix: topicPrefix ?? this.topicPrefix,
    username: username ?? this.username,
    password: password ?? this.password,
    useSsl: useSsl ?? this.useSsl,
    useWebSocket: useWebSocket ?? this.useWebSocket,
  );

  String get sensorDataTopic => '$topicPrefix/sensors/data';
  String get sensorStatusTopic => '$topicPrefix/sensors/status';
  String get heartbeatTopic => '$topicPrefix/device/heartbeat';
}
 