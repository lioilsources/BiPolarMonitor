import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/widgets/app_button.dart';
import 'auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  bool _ageConfirmed = false;
  bool _disclaimerAccepted = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  bool get _canSubmit => _ageConfirmed && _disclaimerAccepted && !_loading;

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty || _emailCtrl.text.trim().isEmpty || _passCtrl.text.length < 8) {
      setState(() => _error = 'Vyplň všechna pole. Heslo musí mít alespoň 8 znaků.');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await ref.read(currentUserProvider.notifier).register(
            email: _emailCtrl.text.trim(),
            password: _passCtrl.text,
            displayName: _nameCtrl.text.trim(),
          );
      if (mounted) context.go('/onboarding');
    } catch (e) {
      setState(() => _error = 'Registrace se nezdařila. Zkontroluj email a heslo.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Text('Vytvoř si účet.', style: AppTypography.heading),
              const SizedBox(height: 8),
              Text('Všechna data zůstávají tvoje.', style: AppTypography.body),
              const SizedBox(height: 40),

              _Field(controller: _nameCtrl, label: 'Jméno'),
              const SizedBox(height: 16),
              _Field(controller: _emailCtrl, label: 'Email', keyboard: TextInputType.emailAddress),
              const SizedBox(height: 16),
              _Field(controller: _passCtrl, label: 'Heslo (min. 8 znaků)', obscure: true),
              const SizedBox(height: 24),

              // Age gate
              _CheckRow(
                value: _ageConfirmed,
                onChanged: (v) => setState(() => _ageConfirmed = v),
                label: 'Je mi 18 nebo více let.',
              ),
              const SizedBox(height: 12),

              // Disclaimer
              _CheckRow(
                value: _disclaimerAccepted,
                onChanged: (v) => setState(() => _disclaimerAccepted = v),
                label: 'Souhlasím s tím, že tato aplikace je wellness nástroj a '
                    'není určena k diagnostice ani léčbě žádného onemocnění.',
              ),
              const SizedBox(height: 8),

              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: AppTypography.bodySm.copyWith(color: AppColors.accentWarm)),
              ],
              const SizedBox(height: 32),

              AppButton(
                label: 'Zaregistrovat se',
                onPressed: _canSubmit ? _submit : null,
                loading: _loading,
              ),
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: () => context.go('/login'),
                  child: Text('Máš účet? Přihlas se.', style: AppTypography.bodySm.copyWith(color: AppColors.accent)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscure;
  final TextInputType? keyboard;

  const _Field({required this.controller, required this.label, this.obscure = false, this.keyboard});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboard,
      style: AppTypography.bodyPrimary,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTypography.bodySm,
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String label;

  const _CheckRow({required this.value, required this.onChanged, required this.label});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: value,
            onChanged: (v) => onChanged(v ?? false),
            activeColor: AppColors.accent,
            side: const BorderSide(color: AppColors.textSecondary),
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: AppTypography.bodySm)),
        ],
      ),
    );
  }
}
