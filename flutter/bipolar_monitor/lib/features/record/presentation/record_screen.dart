import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/widgets/crisis_button.dart';
import 'dialog_widget.dart';
import 'record_provider.dart';

class RecordScreen extends ConsumerStatefulWidget {
  const RecordScreen({super.key});

  @override
  ConsumerState<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends ConsumerState<RecordScreen> {
  CameraController? _cameraController;
  bool _cameraReady = false;
  int _countdown = 3;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final front = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );
    _cameraController = CameraController(front, ResolutionPreset.high, enableAudio: false);
    await _cameraController!.initialize();
    if (mounted) setState(() => _cameraReady = true);
    ref.read(recordProvider.notifier).startFlow(_cameraController!);
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }

  void _startCountdown() {
    setState(() => _countdown = 3);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_countdown <= 1) {
        t.cancel();
        ref.read(recordProvider.notifier).startRecording();
      } else {
        setState(() => _countdown--);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final recordState = ref.watch(recordProvider);

    // React to state transitions
    ref.listen(recordProvider, (prev, next) {
      if (next.state == RecordState.countdown && prev?.state != RecordState.countdown) {
        _startCountdown();
      }
      if (next.state == RecordState.done) {
        context.go('/dashboard', extra: next.completedMeasurementId);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            _buildContent(recordState),
            const Positioned(top: 16, right: 16, child: CrisisButton()),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(RecordStateData state) {
    return switch (state.state) {
      RecordState.idle || RecordState.biometricCheck || RecordState.loadingDialog => _LoadingView(
          message: state.state == RecordState.loadingDialog ? 'Připravuji dialog…' : 'Ověřuji…',
        ),
      RecordState.countdown => _CountdownView(count: _countdown),
      RecordState.recording => _RecordingView(
          cameraController: _cameraController,
          recordState: state,
          onQuestionAdvanced: ref.read(recordProvider.notifier).recordQuestionTiming,
          onComplete: () => ref.read(recordProvider.notifier).stopAndUpload(),
        ),
      RecordState.uploading => _UploadingView(progress: state.uploadProgress),
      RecordState.error => _ErrorView(message: state.errorMessage ?? 'Chyba nahrávání'),
      RecordState.done => const SizedBox.shrink(),
    };
  }
}

class _LoadingView extends StatelessWidget {
  final String message;
  const _LoadingView({required this.message});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.accent),
            const SizedBox(height: 16),
            Text(message, style: AppTypography.body),
          ],
        ),
      );
}

class _CountdownView extends StatelessWidget {
  final int count;
  const _CountdownView({required this.count});

  @override
  Widget build(BuildContext context) => Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            '$count',
            key: ValueKey(count),
            style: AppTypography.heading.copyWith(fontSize: 80, color: AppColors.accent),
          ),
        ),
      );
}

class _RecordingView extends StatelessWidget {
  final CameraController? cameraController;
  final RecordStateData recordState;
  final void Function(dynamic) onQuestionAdvanced;
  final VoidCallback onComplete;

  const _RecordingView({
    required this.cameraController,
    required this.recordState,
    required this.onQuestionAdvanced,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final session = recordState.session;
    if (session == null || cameraController == null) return const SizedBox.shrink();

    return Column(
      children: [
        // Camera preview — top half, rounded
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: CameraPreview(cameraController!),
            ),
          ),
        ),

        // Recording indicator
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                width: 8, height: 8,
                decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                _formatElapsed(recordState.elapsed),
                style: AppTypography.mono.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Dialog widget — bottom half
        Expanded(
          flex: 5,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DialogWidget(
              questions: session.questions,
              suggestedDurationSeconds: session.suggestedDurationPerQuestion,
              recordingElapsed: recordState.elapsed,
              onQuestionAdvanced: onQuestionAdvanced,
              onAllQuestionsAnswered: onComplete,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  String _formatElapsed(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

class _UploadingView extends StatelessWidget {
  final double progress;
  const _UploadingView({required this.progress});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Nahrávám…', style: AppTypography.heading),
              const SizedBox(height: 24),
              LinearProgressIndicator(
                value: progress,
                color: AppColors.accent,
                backgroundColor: AppColors.surface,
              ),
              const SizedBox(height: 12),
              Text('${(progress * 100).toInt()} %', style: AppTypography.mono),
            ],
          ),
        ),
      );
}

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) => Center(
        child: Text(message, style: AppTypography.body.copyWith(color: AppColors.accentWarm)),
      );
}
