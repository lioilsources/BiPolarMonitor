import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/network/api_client.dart';
import '../../../features/auth/presentation/auth_provider.dart';
import '../../../shared/widgets/app_button.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _reminderEnabled = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);
  bool _analysisNotifications = true;
  bool _speakerVerification = true;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text('Nastavení', style: AppTypography.headingMd),
        titleSpacing: 20,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
        children: [
          // Profil
          _Section(title: 'Profil', children: [
            _InfoRow(label: 'Jméno', value: user?.displayName ?? '–'),
            _InfoRow(label: 'Email', value: user?.email ?? '–'),
            _InfoRow(label: 'Celkem záznamů', value: '${user?.totalMeasurements ?? 0}'),
            _SettingsTile(
              label: 'Rozpoznání hlasu',
              subtitle: user?.hasSpeakerEmbedding == true ? 'Aktivní' : 'Nenastaveno',
              onTap: () => context.push('/enrollment'),
            ),
            _SettingsTile(
              label: 'Rozpoznání obličeje',
              subtitle: user?.hasFaceEmbedding == true ? 'Aktivní' : 'Nenastaveno',
              onTap: () => context.push('/face-enrollment'),
            ),
          ]),

          // Nahrávání
          _Section(title: 'Nahrávání', children: [
            _SwitchTile(
              label: 'Ověření hlasu',
              subtitle: 'Upozorní, pokud hlas neodpovídá vzoru',
              value: _speakerVerification,
              onChanged: (v) => setState(() => _speakerVerification = v),
            ),
          ]),

          // Notifikace
          _Section(title: 'Notifikace', children: [
            _SwitchTile(
              label: 'Denní připomínka',
              value: _reminderEnabled,
              onChanged: (v) => setState(() => _reminderEnabled = v),
            ),
            if (_reminderEnabled)
              _SettingsTile(
                label: 'Čas připomínky',
                subtitle: _reminderTime.format(context),
                onTap: () async {
                  final picked = await showTimePicker(context: context, initialTime: _reminderTime,
                    builder: (_, child) => Theme(data: ThemeData.dark(), child: child!));
                  if (picked != null) setState(() => _reminderTime = picked);
                },
              ),
            _SwitchTile(
              label: 'Výsledky analýzy',
              subtitle: 'Push notifikace po zpracování záznamu',
              value: _analysisNotifications,
              onChanged: (v) => setState(() => _analysisNotifications = v),
            ),
          ]),

          // Data
          _Section(title: 'Data', children: [
            _SettingsTile(
              label: 'Export dat (JSON)',
              subtitle: 'Stáhni všechna svá data',
              onTap: _exportData,
            ),
            _SettingsTile(
              label: 'PDF report',
              subtitle: 'Přehled pro lékaře nebo terapeuta',
              onTap: _downloadPdfReport,
            ),
            _SettingsTile(
              label: 'Smazat vše',
              subtitle: 'Okamžité a nevratné',
              destructive: true,
              onTap: () => _confirmDeleteAll(context),
            ),
          ]),

          // O aplikaci
          _Section(title: 'O aplikaci', children: [
            _SettingsTile(
              label: 'Disclaimer',
              onTap: () => _showDisclaimer(context),
            ),
            const _InfoRow(label: 'Verze', value: '1.0.0'),
          ]),

          const SizedBox(height: 24),
          AppButton(
            label: 'Odhlásit se',
            onPressed: () async {
              await ref.read(currentUserProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
            secondary: true,
          ),
        ],
      ),
    );
  }

  Future<void> _downloadPdfReport() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final bytes = await ref.read(apiClientProvider).downloadBytes('/measurements/report');
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/bipolar_report_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(bytes);
      await Share.shareXFiles([XFile(file.path, mimeType: 'application/pdf')], subject: 'BipolarMonitor report');
    } catch (_) {
      messenger.showSnackBar(const SnackBar(content: Text('Stažení reportu se nezdařilo.')));
    }
  }

  Future<void> _exportData() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final data = await ref.read(apiClientProvider).get('/user/export');
      final json = const JsonEncoder.withIndent('  ').convert(data);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/bipolar_export_${DateTime.now().millisecondsSinceEpoch}.json');
      await file.writeAsString(json);
      await Share.shareXFiles([XFile(file.path)], subject: 'BipolarMonitor export');
    } catch (_) {
      messenger.showSnackBar(const SnackBar(content: Text('Export se nezdařil. Zkus to znovu.')));
    }
  }

  Future<void> _confirmDeleteAll(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Smazat veškerá data?', style: AppTypography.headingMd),
        content: Text(
          'Tato akce je nevratná. Budou smazány všechny záznamy, skóre, nastavení a účet.',
          style: AppTypography.body,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Zrušit', style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Smazat vše', style: AppTypography.bodySm.copyWith(color: AppColors.accentWarm))),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      try {
        await ref.read(apiClientProvider).delete('/user/data');
      } catch (_) {
        // Proceed with local logout even if server call fails
      }
      await ref.read(currentUserProvider.notifier).logout();
      if (context.mounted) context.go('/login');
    }
  }

  void _showDisclaimer(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Disclaimer', style: AppTypography.headingMd),
        content: SingleChildScrollView(
          child: Text(
            'Tato aplikace je wellness nástroj a není určena k diagnostice, '
            'léčbě ani prevenci jakéhokoli onemocnění. Pokud máte zdravotní '
            'potíže, kontaktujte svého lékaře.\n\n'
            'Aplikace nenahrazuje odbornou psychiatrickou nebo psychologickou péči.',
            style: AppTypography.body,
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('Zavřít', style: AppTypography.bodySm.copyWith(color: AppColors.accent)))],
      ),
    );
  }
}

// ─── Reusable settings widgets ───────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title.toUpperCase(), style: AppTypography.label),
        ),
        Container(
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return _Tile(
      child: Row(children: [
        Text(label, style: AppTypography.bodyPrimary),
        const Spacer(),
        Text(value, style: AppTypography.bodySm),
      ]),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String label;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool destructive;
  const _SettingsTile({required this.label, this.subtitle, this.onTap, this.destructive = false});

  @override
  Widget build(BuildContext context) {
    return _Tile(
      onTap: onTap,
      child: Row(children: [
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTypography.bodyPrimary.copyWith(color: destructive ? AppColors.accentWarm : AppColors.textPrimary)),
            if (subtitle != null) Text(subtitle!, style: AppTypography.bodySm),
          ],
        )),
        const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 18),
      ]),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SwitchTile({required this.label, this.subtitle, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return _Tile(
      child: Row(children: [
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTypography.bodyPrimary),
            if (subtitle != null) Text(subtitle!, style: AppTypography.bodySm),
          ],
        )),
        Switch(value: value, onChanged: onChanged, activeColor: AppColors.accent),
      ]),
    );
  }
}

class _Tile extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  const _Tile({required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.divider, width: 0.5))),
        child: child,
      ),
    );
  }
}
