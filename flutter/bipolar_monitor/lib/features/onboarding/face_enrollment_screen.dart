/// Face enrollment — uživatel si třikrát vyfotí obličej.
/// Snímky se pošlou na ML service, která vrátí embedding vektor,
/// ten se uloží přes POST /user/enroll-face.
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/haptics.dart';
import '../../shared/widgets/app_button.dart';

enum _FaceEnrollState { intro, capturing, processing, done, error, skipped }

class FaceEnrollmentScreen extends ConsumerStatefulWidget {
  const FaceEnrollmentScreen({super.key});

  @override
  ConsumerState<FaceEnrollmentScreen> createState() => _FaceEnrollmentScreenState();
}

class _FaceEnrollmentScreenState extends ConsumerState<FaceEnrollmentScreen> {
  _FaceEnrollState _state = _FaceEnrollState.intro;
  CameraController? _camera;
  bool _cameraReady = false;
  final List<String> _capturedPaths = [];
  String? _errorMsg;

  static const _requiredShots = 3;
  static const _instructions = [
    'Podívej se přímo do kamery',
    'Mírně nakloň hlavu doleva',
    'Mírně nakloň hlavu doprava',
  ];

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  @override
  void dispose() {
    _camera?.dispose();
    super.dispose();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final front = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );
    _camera = CameraController(front, ResolutionPreset.medium, enableAudio: false);
    await _camera!.initialize();
    if (mounted) setState(() => _cameraReady = true);
  }

  Future<void> _capturePhoto() async {
    if (_camera == null || !_cameraReady) return;
    await Haptics.tick();
    final tmpDir = await getTemporaryDirectory();
    final path = '${tmpDir.path}/face_${const Uuid().v4()}.jpg';
    final xFile = await _camera!.takePicture();
    await File(xFile.path).copy(path);

    setState(() => _capturedPaths.add(path));

    if (_capturedPaths.length >= _requiredShots) {
      _enroll();
    }
  }

  Future<void> _enroll() async {
    setState(() => _state = _FaceEnrollState.processing);
    try {
      final api = ref.read(apiClientProvider);

      // Send images to ML service for embedding extraction
      final mlResp = await api.post('/ml/face-enroll', {
        'image_paths': _capturedPaths,
      });

      final embedding = (mlResp['embedding'] as List).cast<double>();
      if (embedding.isEmpty) throw Exception('Empty embedding');

      // Store embedding via API
      await api.post('/user/enroll-face', {'embedding': embedding});

      await Haptics.light();
      if (mounted) setState(() => _state = _FaceEnrollState.done);
    } catch (e) {
      await Haptics.heavy();
      if (mounted) setState(() {
        _state = _FaceEnrollState.error;
        _errorMsg = 'Rozpoznání obličeje se nezdařilo. Zkus to znovu.';
      });
    }
  }

  void _retry() {
    _capturedPaths.clear();
    setState(() {
      _state = _FaceEnrollState.capturing;
      _errorMsg = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text('Rozpoznání obličeje', style: AppTypography.headingMd),
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textSecondary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return switch (_state) {
      _FaceEnrollState.intro => _IntroView(
          onStart: () => setState(() => _state = _FaceEnrollState.capturing),
          onSkip: () => context.pop(),
        ),
      _FaceEnrollState.capturing => _CapturingView(
          camera: _cameraReady ? _camera : null,
          shotIndex: _capturedPaths.length,
          totalShots: _requiredShots,
          instruction: _instructions[_capturedPaths.length.clamp(0, _instructions.length - 1)],
          onCapture: _capturePhoto,
        ),
      _FaceEnrollState.processing => const _ProcessingView(),
      _FaceEnrollState.done => _DoneView(onContinue: () => context.pop()),
      _FaceEnrollState.error => _ErrorView(
          message: _errorMsg ?? 'Chyba',
          onRetry: _retry,
          onSkip: () => context.pop(),
        ),
      _FaceEnrollState.skipped => const SizedBox.shrink(),
    };
  }
}

// ─── Sub-views ────────────────────────────────────────────────────────────────

class _IntroView extends StatelessWidget {
  final VoidCallback onStart;
  final VoidCallback onSkip;
  const _IntroView({required this.onStart, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.face_outlined, size: 48, color: AppColors.accent),
        const SizedBox(height: 24),
        Text('Nastavení rozpoznání obličeje', style: AppTypography.heading.copyWith(fontSize: 24)),
        const SizedBox(height: 16),
        Text(
          'Nafotíme tvůj obličej ze tří úhlů. Tím zajistíme, '
          'že záznamy vždy pochází od tebe — nikdy od jiné osoby.\n\n'
          'Snímky nikdy neopustí server a jsou použity pouze jako matematický vektor.',
          style: AppTypography.body,
        ),
        const Spacer(),
        AppButton(label: 'Začít fotit', onPressed: onStart),
        const SizedBox(height: 12),
        AppButton(label: 'Přeskočit', onPressed: onSkip, secondary: true),
      ],
    );
  }
}

class _CapturingView extends StatelessWidget {
  final CameraController? camera;
  final int shotIndex;
  final int totalShots;
  final String instruction;
  final VoidCallback onCapture;
  const _CapturingView({
    required this.camera,
    required this.shotIndex,
    required this.totalShots,
    required this.instruction,
    required this.onCapture,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Progress dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(totalShots, (i) => AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: i < shotIndex ? 20 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i < shotIndex ? AppColors.accent : AppColors.divider,
              borderRadius: BorderRadius.circular(4),
            ),
          )),
        ),
        const SizedBox(height: 20),

        // Instruction
        Text(instruction, style: AppTypography.bodyPrimary.copyWith(fontWeight: FontWeight.w600), textAlign: TextAlign.center),
        const SizedBox(height: 16),

        // Camera preview
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: camera != null
                ? CameraPreview(camera!)
                : Container(color: AppColors.surface, child: const Center(child: CircularProgressIndicator(color: AppColors.accent))),
          ),
        ),
        const SizedBox(height: 24),

        // Capture button
        GestureDetector(
          onTap: onCapture,
          child: Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.accent, width: 3),
              color: AppColors.accent.withOpacity(0.15),
            ),
            child: const Icon(Icons.camera_alt_outlined, color: AppColors.accent, size: 32),
          ),
        ),
        const SizedBox(height: 8),
        Text('Snímek ${shotIndex + 1} z $totalShots', style: AppTypography.bodySm),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _ProcessingView extends StatelessWidget {
  const _ProcessingView();

  @override
  Widget build(BuildContext context) => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.accent),
            SizedBox(height: 20),
            Text('Zpracovávám snímky…', style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
}

class _DoneView extends StatelessWidget {
  final VoidCallback onContinue;
  const _DoneView({required this.onContinue});

  @override
  Widget build(BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.verified_user_outlined, size: 64, color: AppColors.accent),
          const SizedBox(height: 24),
          Text('Hotovo!', style: AppTypography.heading.copyWith(fontSize: 28)),
          const SizedBox(height: 12),
          Text('Rozpoznání obličeje je nastaveno.', style: AppTypography.body, textAlign: TextAlign.center),
          const Spacer(),
          AppButton(label: 'Pokračovat', onPressed: onContinue),
        ],
      );
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onSkip;
  const _ErrorView({required this.message, required this.onRetry, required this.onSkip});

  @override
  Widget build(BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 48, color: AppColors.accentWarm),
          const SizedBox(height: 16),
          Text(message, style: AppTypography.body, textAlign: TextAlign.center),
          const Spacer(),
          AppButton(label: 'Zkusit znovu', onPressed: onRetry),
          const SizedBox(height: 12),
          AppButton(label: 'Přeskočit', onPressed: onSkip, secondary: true),
        ],
      );
}
