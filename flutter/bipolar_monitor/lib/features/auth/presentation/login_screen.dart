import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/widgets/app_button.dart';
import 'auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() { _loading = true; _error = null; });
    try {
      await ref.read(currentUserProvider.notifier).login(
            email: _emailCtrl.text.trim(),
            password: _passCtrl.text,
          );
      if (mounted) context.go('/dashboard');
    } catch (e) {
      setState(() { _error = 'Neplatné přihlašovací údaje.'; });
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Text('Vítej zpět.', style: AppTypography.heading),
              const SizedBox(height: 8),
              Text('Přihlas se a pokračuj.', style: AppTypography.body),
              const SizedBox(height: 40),
              _Field(controller: _emailCtrl, label: 'Email', keyboard: TextInputType.emailAddress),
              const SizedBox(height: 16),
              _Field(controller: _passCtrl, label: 'Heslo', obscure: true),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: AppTypography.bodySm.copyWith(color: AppColors.accentWarm)),
              ],
              const SizedBox(height: 32),
              AppButton(
                label: 'Přihlásit se',
                onPressed: _loading ? null : _submit,
                loading: _loading,
              ),
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: () => context.go('/register'),
                  child: Text('Nemáš účet? Zaregistruj se.', style: AppTypography.bodySm.copyWith(color: AppColors.accent)),
                ),
              ),
              const Spacer(),
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
      ),
    );
  }
}
