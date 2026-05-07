import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Navigation key — set by app_router, used for deep links from notifications
typedef NotificationTapCallback = void Function(String route);

// Background FCM handler — must be top-level
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await NotificationService._showLocalNotification(message);
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// Stream of notification-driven routes — app_router subscribes to this
final notificationRouteProvider = StateProvider<String?>((ref) => null);

class NotificationService {
  static final _localNotifications = FlutterLocalNotificationsPlugin();
  static const _channelAnalysis = AndroidNotificationChannel(
    'bipolar_analysis',
    'Analýza dokončena',
    description: 'Výsledky zpracování nahrávky',
    importance: Importance.defaultImportance,
  );
  static const _channelReminder = AndroidNotificationChannel(
    'bipolar_reminder',
    'Denní připomínka',
    description: 'Připomínka pro denní nahrávku',
    importance: Importance.low,
  );

  // Set by main.dart after ProviderContainer is created
  static NotificationTapCallback? onTap;

  Future<void> initialize() async {
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_channelAnalysis);
    await androidPlugin?.createNotificationChannel(_channelReminder);

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // App opened from terminated state via notification
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) {
      _routeFromMessage(initial);
    }

    // App opened from background state via notification
    FirebaseMessaging.onMessageOpenedApp.listen(_routeFromMessage);

    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: false,
    );
  }

  Future<String?> getFcmToken() => FirebaseMessaging.instance.getToken();

  Future<void> scheduleReminder({required int hour, required int minute}) async {
    await _localNotifications.cancelAll();
    await _localNotifications.show(
      1,
      'Čas na nahrávku',
      'Chceš si dnes povídat?',
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelReminder.id, _channelReminder.name,
          channelDescription: _channelReminder.description,
          importance: Importance.low, priority: Priority.low, silent: true,
        ),
        iOS: const DarwinNotificationDetails(presentSound: false),
      ),
    );
  }

  Future<void> cancelReminder() => _localNotifications.cancel(1);

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    final data = message.data;
    final title = message.notification?.title ?? 'BipolarMonitor';
    final body = message.notification?.body ?? '';

    await _localNotifications.show(
      data['measurement_id']?.hashCode ?? title.hashCode,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelAnalysis.id, _channelAnalysis.name,
          channelDescription: _channelAnalysis.description,
          importance: Importance.defaultImportance, silent: true,
        ),
        iOS: const DarwinNotificationDetails(presentSound: false),
      ),
      payload: jsonEncode(data),
    );
  }

  static void _onForegroundMessage(RemoteMessage message) {
    final type = message.data['type'] as String?;
    if (type == 'analysis_complete' || type == 'deviation_alert') {
      _showLocalNotification(message);
    }
  }

  static void _routeFromMessage(RemoteMessage message) {
    final measurementId = message.data['measurement_id'] as String?;
    if (measurementId != null) {
      onTap?.call('/measurement/$measurementId');
    }
  }

  static void _onNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null) return;
    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      final measurementId = data['measurement_id'] as String?;
      if (measurementId != null) {
        onTap?.call('/measurement/$measurementId');
      }
    } catch (_) {}
  }
}
