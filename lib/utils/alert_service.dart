import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AlertChannels {
  
  static const String dangerChannelId = 'am032_danger';
  static const String dangerChannelName = 'Alertas Críticos de Gás';
  static const String warningChannelId = 'am032_warning';
  static const String warningChannelName = 'Alertas de Qualidade do Ar';

  static const int dangerNotificationId = 1001;
  static const int warningNotificationId = 1002;

}

class AlertService {
  
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  DateTime? _lastDangerAlert;
  DateTime? _lastWarningAlert;
  static const Duration _alertCooldown = Duration(seconds: 30);

  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    await _createChannels();
    _initialized = true;
  }

  Future<void> _createChannels() async {
    final dangerChannel = AndroidNotificationChannel(
      AlertChannels.dangerChannelId,
      AlertChannels.dangerChannelName,
      description: 'Alertas de concentração crítica de gases tóxicos',
      importance: Importance.max,
      sound: RawResourceAndroidNotificationSound('alarm_danger'),
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 500, 200, 500, 200, 500]),
      enableLights: true,
      ledColor: Color.fromARGB(255, 255, 0, 0),
    );

    const warningChannel = AndroidNotificationChannel(
      AlertChannels.warningChannelId,
      AlertChannels.warningChannelName,
      description: 'Alertas de qualidade do ar moderada',
      importance: Importance.high,
    );

    final androidPlugin = _plugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      await androidPlugin?.createNotificationChannel(dangerChannel);
      await androidPlugin?.createNotificationChannel(warningChannel);
  }

  Future<void> triggerDangerAlert({int? mq7Ppm, int? mq25Ppm}) async {
    if (!_initialized) await initialize();
    if (!_shouldSendAlert(_lastDangerAlert)) return;

    _lastDangerAlert = DateTime.now();

    final body = _buildDangerBody(mq7Ppm, mq25Ppm);

    final androidDetails = AndroidNotificationDetails(
      AlertChannels.dangerChannelId,
      AlertChannels.dangerChannelName,
      channelDescription: 'Concentração crítica de gases tóxicos detectada',
      importance: Importance.max,
      priority: Priority.max,
      ticker: '⚠️ PERIGO — Gás Tóxico Detectado!',
      sound: const RawResourceAndroidNotificationSound('alarm_danger'),
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 500, 200, 500, 200, 500]),
      color: const Color.fromARGB(255, 220, 38, 38),
      ledColor: const Color.fromARGB(255, 255, 0, 0),
      ledOnMs: 300,
      ledOffMs: 100,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      styleInformation: BigTextStyleInformation(body),
      ongoing: true,
      autoCancel: false,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'alarm_danger.aiff',
      interruptionLevel: InterruptionLevel.critical,
    );

    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.show(
      id: AlertChannels.dangerNotificationId,
      title: '🚨 PERIGO — Gás Tóxico Detectado!',
      body: body,
      notificationDetails: details,
      payload: 'danger',
    );
  }

  Future<void> triggerWarningAlert() async {
    if (!_initialized) await initialize();
    if (!_shouldSendAlert(_lastWarningAlert)) return;

    _lastWarningAlert = DateTime.now();

    const androidDetails = AndroidNotificationDetails(
      AlertChannels.warningChannelId,
      AlertChannels.warningChannelName,
      importance: Importance.high,
      priority: Priority.high,
      color: Color.fromARGB(255, 234, 179, 8),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.timeSensitive
    );

    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.show(
      id: AlertChannels.warningNotificationId,
      title: '⚠️ Qualidade do Ar — Atenção',
      body: 'Nível elevado de gases detectado. Ventile o ambiente imediatamente.',
      notificationDetails: details,
      payload: 'warning',
    );
  }

  Future<void> cancelDangerAlert() async {
    await _plugin.cancel(id: AlertChannels.dangerNotificationId);
  }

  Future<void> cancelAllAlerts() async {
    await _plugin.cancelAll();
  }

  bool _shouldSendAlert(DateTime? lastAlert) {
    if (lastAlert == null) return true;
    return DateTime.now().difference(lastAlert) > _alertCooldown;
  }

  String _buildDangerBody(int? mq7Ppm, int? mq25Ppm) {
    final parts = <String>[];
    if (mq7Ppm != null) parts.add('CO: $mq7Ppm PPM');
    if (mq25Ppm != null) parts.add('Fumaça/Gases: $mq25Ppm PPM');

    final readings = parts.isNotEmpty ? ' (${parts.join(' | ')})' : '';
    return 'Concentração crítica detectada$readings. EVACUE O LOCAL IMEDIATAMENTE e ligue 193.';
  }

  void _onNotificationTap(NotificationResponse response) {

  }

  Future<bool> requestPermissions() async {
    final android = _plugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    final ios = _plugin
      .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();

    final androidGranted = await android?.requestNotificationsPermission() ?? true;
    final iosGranted = await ios?.requestPermissions(alert: true, badge: true, sound: true) ?? true;

    return androidGranted && iosGranted;
  }
}