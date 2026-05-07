import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';
import 'app.dart';
import 'core/notifications/notification_service.dart';
import 'features/record/data/offline_queue.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(const ProviderScope(child: BipolarApp()));
}

/// Called after ProviderScope is up — initializes services that need Riverpod.
class AppInitializer extends ConsumerWidget {
  final Widget child;
  const AppInitializer({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return child;
  }
}
