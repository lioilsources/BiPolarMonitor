import 'dart:io';
import 'dart:convert';
import 'package:background_fetch/background_fetch.dart' as bgfetch;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';
import '../../../core/storage/local_database.dart';
import '../../../core/network/api_client.dart';

const _kUploadTaskName = 'bipolar_upload_pending';

// Registered as Workmanager callback — must be top-level
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName == _kUploadTaskName) {
      final db = LocalDatabase();
      final pending = await db.getPendingUploads();
      await db.close();
      return pending.isEmpty ? true : false;
    }
    return true;
  });
}

// iOS background fetch headless callback — must be top-level
@pragma('vm:entry-point')
void backgroundFetchHeadlessTask(bgfetch.HeadlessTask task) async {
  final db = LocalDatabase();
  final pending = await db.getPendingUploads();
  await db.close();
  bgfetch.BackgroundFetch.finish(task.taskId);
  if (pending.isEmpty) bgfetch.BackgroundFetch.stop(task.taskId);
}

final offlineQueueProvider = Provider<OfflineQueue>((ref) => OfflineQueue(ref));

class OfflineQueue {
  final Ref _ref;

  OfflineQueue(this._ref);

  LocalDatabase get _db => _ref.read(localDbProvider);
  ApiClient get _api => _ref.read(apiClientProvider);

  Future<void> initialize() async {
    // Android background uploads via WorkManager
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
    await Workmanager().registerPeriodicTask(
      _kUploadTaskName,
      _kUploadTaskName,
      frequency: const Duration(hours: 1),
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingWorkPolicy.keep,
    );

    // iOS background fetch — triggers processQueue when app is suspended
    if (Platform.isIOS) {
      await bgfetch.BackgroundFetch.configure(
        bgfetch.BackgroundFetchConfig(
          minimumFetchInterval: 60,
          stopOnTerminate: false,
          enableHeadless: true,
          requiredNetworkType: bgfetch.NetworkType.ANY,
        ),
        (taskId) async {
          await processQueue();
          bgfetch.BackgroundFetch.finish(taskId);
        },
        (taskId) => bgfetch.BackgroundFetch.finish(taskId), // timeout handler
      );
      bgfetch.BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
    }
  }

  /// Called when app comes to foreground — process any pending uploads.
  Future<void> processQueue() async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) return;

    final pending = await _db.getPendingUploads();
    for (final m in pending) {
      // Skip if retry not yet due
      if (m.nextRetryAt != null && m.nextRetryAt!.isAfter(DateTime.now())) continue;

      final videoFile = m.localVideoPath != null ? File(m.localVideoPath!) : null;
      final audioFile = m.localAudioPath != null ? File(m.localAudioPath!) : null;

      if (videoFile == null || !videoFile.existsSync() ||
          audioFile == null || !audioFile.existsSync()) {
        // Files gone — mark as uploaded to remove from queue
        await _db.markUploaded(m.id);
        continue;
      }

      try {
        await _api.uploadMeasurement(
          measurementId: m.id,
          questionsUsed: m.questionsUsed,
          recordedAt: m.recordedAt.toUtc().toIso8601String(),
          durationSeconds: m.durationSeconds,
          notes: m.notes,
          videoFile: videoFile,
          audioFile: audioFile,
        );
        await _db.markUploaded(m.id);
        // Clean up local files after successful upload
        videoFile.deleteSync();
        audioFile.deleteSync();
      } catch (_) {
        // Exponential backoff: 5min, 15min, 1h, 4h, 24h
        final delays = [5, 15, 60, 240, 1440];
        final delay = delays[m.retryCount.clamp(0, delays.length - 1)];
        await _db.incrementRetry(m.id, DateTime.now().add(Duration(minutes: delay)));
      }
    }
  }

  /// Queue a measurement that failed to upload immediately.
  Future<void> enqueue({
    required String id,
    required DateTime recordedAt,
    required int durationSeconds,
    required String questionsUsed,
    String? notes,
    String? videoPath,
    String? audioPath,
  }) async {
    await _db.upsertMeasurement(LocalMeasurementsCompanion(
      id: Value(id),
      recordedAt: Value(recordedAt),
      durationSeconds: Value(durationSeconds),
      questionsUsed: Value(questionsUsed),
      notes: Value(notes),
      localVideoPath: Value(videoPath),
      localAudioPath: Value(audioPath),
      uploaded: const Value(false),
      retryCount: const Value(0),
    ));
  }
}
