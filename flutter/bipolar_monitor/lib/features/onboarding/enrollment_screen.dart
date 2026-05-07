/// Speaker enrollment — uživatel přečte 3 věty, app pošle audio na ML service,
/// ML vrátí embedding vector, uloží se přes /user/enroll-speaker.
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../shared/widgets/app_button.dart';
import '../../core/network/api_client.dart';

const _enrollmentSentences = [
  'Dnes ráno jsem se probudil a díval se z okna na oblohu.',
  'Mám rád tiché chvíle, kdy si mohu jen tak sedět a přemýšlet.',
  'Každý den je jiný a to mi přijde jako to nejlepší na životě.',
];

enum _EnrollState { intro, recording, processing, done, error, skipped }

class EnrollmentScreen extends ConsumerStatefulWidget {
  const EnrollmentScreen({super.key});

  @override
  ConsumerState<EnrollmentScreen> createState() => _EnrollmentScreenState();
}

class _EnrollmentScreenState extends ConsumerState<EnrollmentScreen> {
  _EnrollState _state = _EnrollState.intro;
  int _sentenceIndex = 0;
  final _recorder = AudioRecorder();
  final List<String> _recordedPaths = [];
  String? _errorMsg;

  @override
  void dispose() {
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    final tmpDir = await getTemporaryDirectory();
    final path = '${tmpDir.path}/enroll_${const Uuid().v4()}.wav';
    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.wav, sampleRate: 16000, numChannels: 1),
      path: path,
    );
    setState(() => _state = _EnrollState.recording);
  }

  Future<void> _stopRecording() async {
    final path = await _recorder.stop();
    if (path != null) _recordedPaths.add(path);

    if (_sentenceIndex < _enrollmentSentences.length - 1) {
      setState(() {
        _sentenceIndex++;
        _state = _EnrollState.intro;
      });
    } else {
      await _submitEnrollment();
    }
  }

  Future<void> _submitEnrollment() async {
    setState(() => _state = _EnrollState.processing);
    try {
      final api = ref.read(apiClientProvider);
      // Send all enrollment audios to ML service for embedding extraction
      final resp = await api.post('/ml/speaker-enroll', {
        'audio_paths': _recordedPaths,
      });
      final embedding = (resp['embedding'] as List).cast<double>();
      await api.post('/user/enroll-speaker', {'embedding': embedding});

      // Cleanup temp files
      for (final p in _recordedPaths) {
        File(p).deleteSync();
      }

      setState(() => _state = _EnrollState.done);
    } catch (e) {
      setState(() { _state = _EnrollState.error; _errorMsg = e.toString(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return switch (_state) {
      _EnrollState.intro => _IntroStep(
          sentenceIndex: _sentenceIndex,
          total: _enrollmentSentences.length,
          sentence: _enrollmentSentences[_sentenceIndex],
          onStart: _startRecording,
          onSkip: () => context.go('/dashboard'),
        ),
      _EnrollState.recording => _RecordingStep(
          sentenceIndex: _sentenceIndex,
          sentence: _enrollmentSentences[_sentenceIndex],
          onStop: _stopRecording,
        ),
      _EnrollState.processing => _ProcessingStep(),
      _EnrollState.done => _DoneStep(onContinue: () => context.go('/dashboard')),
      _EnrollState.error => _ErrorStep(
          message: _errorMsg,
          onRetry: () => setState(() { _state = _EnrollState.intro; _sentenceIndex = 0; _recordedPaths.clear(); }),
          onSkip: () => context.go('/dashboard'),
        ),
      _EnrollState.skipped => const SizedBox.shrink(),
    };
  }
}

class _IntroStep extends StatelessWidget {
  final int sentenceIndex;
  final int total;
  final String sentence;
  final VoidCallback onStart;
  final VoidCallback onSkip;

  const _IntroStep({required this.sentenceIndex, required this.total, required this.sentence, required this.onStart, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacer(),
        Text('Rozpoznání hlasu', style: AppTypography.heading),
        const SizedBox(height: 8),
        Text(
          'Aby aplikace věděla, že nahrávku vždy pořizuješ ty, '
          'přečti prosím tyto věty. Záznam slouží pouze k vytvoření '
          'vzoru hlasu — raw audio se neukládá.',
          style: AppTypography.body,
        ),
        const SizedBox(height: 40),

        // Progress
        Text('${sentenceIndex + 1} / $total', style: AppTypography.label),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.accent.withOpacity(0.3)),
          ),
          child: Text(sentence, style: AppTypography.dialogQuestion),
        ),
        const SizedBox(height: 32),

        AppButton(label: 'Začít nahrávat', onPressed: onStart),
        const SizedBox(height: 16),
        AppButton(
          label: 'Přeskočit (lze nastavit kdykoli v Settings)',
          onPressed: onSkip,
          secondary: true,
        ),
        const Spacer(),
      ],
    );
  }
}

class _RecordingStep extends StatelessWidget {
  final int sentenceIndex;
  final String sentence;
  final VoidCallback onStop;

  const _RecordingStep({required this.sentenceIndex, required this.sentence, required this.onStop});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.mic_rounded, color: AppColors.accent, size: 48),
        const SizedBox(height: 8),
        const _PulseDot(),
        const SizedBox(height: 32),
        Text('Čti pomalu a přirozeně:', style: AppTypography.bodySm),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20)),
          child: Text(sentence, style: AppTypography.dialogQuestion),
        ),
        const SizedBox(height: 40),
        AppButton(label: 'Hotovo', onPressed: onStop),
      ],
    );
  }
}

class _PulseDot extends StatefulWidget {
  const _PulseDot();

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..repeat(reverse: true);
    _scale = Tween(begin: 0.8, end: 1.2).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => ScaleTransition(
    scale: _scale,
    child: Container(width: 16, height: 16, decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle)),
  );
}

class _ProcessingStep extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(color: AppColors.accent),
        SizedBox(height: 16),
        Text('Zpracovávám hlas…', style: TextStyle(color: AppColors.textSecondary)),
      ],
    ),
  );
}

class _DoneStep extends StatelessWidget {
  final VoidCallback onContinue;
  const _DoneStep({required this.onContinue});

  @override
  Widget build(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Icon(Icons.check_circle_outline_rounded, color: AppColors.accent, size: 64),
      const SizedBox(height: 24),
      Text('Hlas byl rozpoznán.', style: AppTypography.heading),
      const SizedBox(height: 8),
      Text('Teď tě aplikace pozná, kdykoliv budeš nahrávat.', style: AppTypography.body),
      const SizedBox(height: 40),
      AppButton(label: 'Přejít do aplikace', onPressed: onContinue),
    ],
  );
}

class _ErrorStep extends StatelessWidget {
  final String? message;
  final VoidCallback onRetry;
  final VoidCallback onSkip;

  const _ErrorStep({this.message, required this.onRetry, required this.onSkip});

  @override
  Widget build(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text('Enrollment se nezdařil.', style: AppTypography.headingMd),
      const SizedBox(height: 8),
      Text('Zkus to znovu nebo přeskoč — enrollment lze nastavit kdykoli v Settings.', style: AppTypography.body),
      const SizedBox(height: 40),
      AppButton(label: 'Zkusit znovu', onPressed: onRetry),
      const SizedBox(height: 16),
      AppButton(label: 'Přeskočit', onPressed: onSkip, secondary: true),
    ],
  );
}
