import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:record/record.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/network/api_client.dart';
import '../domain/measurement_model.dart';
import '../../dashboard/presentation/dashboard_provider.dart';

enum RecordState { idle, biometricCheck, loadingDialog, countdown, recording, uploading, done, error }

class RecordStateData {
  final RecordState state;
  final DialogSession? session;
  final Duration elapsed;
  final double uploadProgress;
  final String? errorMessage;
  final String? completedMeasurementId;

  const RecordStateData({
    required this.state,
    this.session,
    this.elapsed = Duration.zero,
    this.uploadProgress = 0,
    this.errorMessage,
    this.completedMeasurementId,
  });

  RecordStateData copyWith({
    RecordState? state,
    DialogSession? session,
    Duration? elapsed,
    double? uploadProgress,
    String? errorMessage,
    String? completedMeasurementId,
  }) =>
      RecordStateData(
        state: state ?? this.state,
        session: session ?? this.session,
        elapsed: elapsed ?? this.elapsed,
        uploadProgress: uploadProgress ?? this.uploadProgress,
        errorMessage: errorMessage ?? this.errorMessage,
        completedMeasurementId: completedMeasurementId ?? this.completedMeasurementId,
      );
}

final recordProvider = StateNotifierProvider.autoDispose<RecordNotifier, RecordStateData>(
  (ref) => RecordNotifier(ref),
);

class RecordNotifier extends StateNotifier<RecordStateData> {
  final Ref _ref;
  final _localAuth = LocalAuthentication();
  final _audioRecorder = AudioRecorder();
  CameraController? _cameraController;
  Timer? _elapsedTimer;
  DateTime? _recordingStart;
  final List<QuestionTiming> _timings = [];
  String? _audioPath;
  String? _videoPath;

  RecordNotifier(this._ref) : super(const RecordStateData(state: RecordState.idle));

  Future<void> startFlow(CameraController cameraController) async {
    _cameraController = cameraController;

    // 1. Biometric auth
    state = state.copyWith(state: RecordState.biometricCheck);
    final canAuth = await _localAuth.canCheckBiometrics || await _localAuth.isDeviceSupported();
    if (canAuth) {
      final authed = await _localAuth.authenticate(
        localizedReason: 'Ověřte totožnost před nahráváním',
        options: const AuthenticationOptions(biometricOnly: false),
      );
      if (!authed) {
        state = state.copyWith(state: RecordState.idle);
        return;
      }
    }

    // 2. Load dialog session from API
    state = state.copyWith(state: RecordState.loadingDialog);
    final api = _ref.read(apiClientProvider);
    final sessionJson = await api.get('/dialog/next');
    final session = DialogSession.fromJson(sessionJson);

    // 3. Countdown (3 seconds — handled in UI, we just set state)
    state = state.copyWith(state: RecordState.countdown, session: session);
  }

  Future<void> startRecording() async {
    final tmpDir = await getTemporaryDirectory();
    final id = const Uuid().v4();
    _audioPath = '${tmpDir.path}/$id.wav';
    _videoPath = '${tmpDir.path}/$id.mp4';

    // Start audio recording
    await _audioRecorder.start(
      RecordConfig(encoder: AudioEncoder.wav, sampleRate: 16000, numChannels: 1),
      path: _audioPath!,
    );

    // Start video recording
    await _cameraController?.startVideoRecording();

    _recordingStart = DateTime.now();
    _elapsedTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (_recordingStart != null) {
        state = state.copyWith(elapsed: DateTime.now().difference(_recordingStart!));
      }
    });

    state = state.copyWith(state: RecordState.recording);
  }

  void recordQuestionTiming(QuestionTiming timing) {
    _timings.add(timing);
  }

  Future<void> stopAndUpload({String? notes}) async {
    _elapsedTimer?.cancel();

    // Stop recordings
    await _audioRecorder.stop();
    final videoFile = await _cameraController?.stopVideoRecording();
    if (videoFile != null) _videoPath = videoFile.path;

    state = state.copyWith(state: RecordState.uploading, uploadProgress: 0);

    final session = state.session!;
    final questionsUsed = jsonEncode(session.questions.map((q) => q.key).toList());
    final timingsMap = <String, Map<String, dynamic>>{
      for (final t in _timings) t.questionId: t.toJson(),
    };
    final timingsJson = jsonEncode(timingsMap);

    final measurementId = const Uuid().v4();
    final recordedAt = _recordingStart!.toUtc().toIso8601String();
    final duration = DateTime.now().difference(_recordingStart!).inSeconds;

    await _ref.read(apiClientProvider).uploadMeasurement(
          measurementId: measurementId,
          questionsUsed: questionsUsed,
          questionTimings: timingsJson,
          recordedAt: recordedAt,
          durationSeconds: duration,
          notes: notes,
          videoFile: File(_videoPath!),
          audioFile: File(_audioPath!),
          onProgress: (sent, total) {
            state = state.copyWith(uploadProgress: total > 0 ? sent / total : 0);
          },
        );

    // Cleanup temp files
    _cleanupFiles();

    _ref.invalidate(dashboardProvider);

    state = state.copyWith(
      state: RecordState.done,
      completedMeasurementId: measurementId,
    );
  }

  void _cleanupFiles() {
    if (_audioPath != null) File(_audioPath!).deleteSync(recursive: false);
    if (_videoPath != null) File(_videoPath!).deleteSync(recursive: false);
  }

  @override
  void dispose() {
    _elapsedTimer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }
}
