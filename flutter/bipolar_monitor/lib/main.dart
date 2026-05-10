import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app.dart';
import 'core/notifications/notification_service.dart';
import 'features/record/data/offline_queue.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('cs', null);

  try {
    await Firebase.initializeApp();
    // Shared container for service initialization
    final container = ProviderContainer();
    // Initialize notifications (FCM token registration)
    await container.read(notificationServiceProvider).initialize();
    // Initialize background upload queue (Workmanager + iOS BackgroundFetch)
    await container.read(offlineQueueProvider).initialize();
    runApp(UncontrolledProviderScope(
      container: container,
      child: const BipolarApp(),
    ));
    return;
  } catch (_) {
    // Firebase not configured — run without push notifications and offline queue
  }

  final container = ProviderContainer();

  runApp(UncontrolledProviderScope(
    container: container,
    child: const BipolarApp(),
  ));
}
