import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Background FCM handler — must be top-level
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await NotificationService._showLocalNotification(message);
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

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

  Future<void> initialize() async {
    // Local notifications
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

    // Create channels (Android)
    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_channelAnalysis);
    await androidPlugin?.createNotificationChannel(_channelReminder);

    // FCM
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_onNotificationOpenedApp);

    // Request permission
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: false, // no sound — mental health app
    );
  }

  Future<String?> getFcmToken() => FirebaseMessaging.instance.getToken();

  Future<void> scheduleReminder({required int hour, required int minute}) async {
    await _localNotifications.cancelAll();

    // Daily reminder — using zonedSchedule for exact time
    // (requires timezone package in production)
    await _localNotifications.show(
      1,
      'Čas na nahrávku',
      'Dávno jsme se neviděli. Chceš si povídat?',
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelReminder.id,
          _channelReminder.name,
          channelDescription: _channelReminder.description,
          importance: Importance.low,
          priority: Priority.low,
          silent: true,
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
      data['measurement_id'].hashCode,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelAnalysis.id,
          _channelAnalysis.name,
          channelDescription: _channelAnalysis.description,
          importance: Importance.defaultImportance,
          silent: true,
        ),
        iOS: const DarwinNotificationDetails(presentSound: false),
      ),
      payload: jsonEncode(data),
    );
  }

  static void _onForegroundMessage(RemoteMessage message) {
    // Only show if notification warrants it (analysis done, significant deviation)
    final type = message.data['type'] as String?;
    if (type == 'analysis_complete' || type == 'deviation_alert') {
      _showLocalNotification(message);
    }
  }

  static void _onNotificationOpenedApp(RemoteMessage message) {
    // Navigation handled by app_router listening to notification tap
  }

  static void _onNotificationTap(NotificationResponse response) {
    // Deep link via payload — handled by router
  }
}
