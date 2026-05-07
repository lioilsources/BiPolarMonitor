import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';

class CrisisButton extends StatelessWidget {
  const CrisisButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showCrisisSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.accentWarm.withOpacity(0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.favorite_border, color: AppColors.accentWarm, size: 15),
            const SizedBox(width: 6),
            Text('Potřebuji pomoc', style: AppTypography.bodySm.copyWith(color: AppColors.accentWarm, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  void _showCrisisSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const _CrisisSheet(),
    );
  }
}

class _CrisisSheet extends StatelessWidget {
  const _CrisisSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Jsi tady a to je dost.', style: AppTypography.headingMd),
          const SizedBox(height: 8),
          Text('Pokud potřebuješ mluvit s někým hned, tato čísla jsou k dispozici 24/7:', style: AppTypography.body),
          const SizedBox(height: 20),
          _CrisisContact(
            label: 'Linka bezpečí',
            number: '116 111',
            description: 'Pro děti, dospívající i dospělé',
          ),
          const SizedBox(height: 12),
          _CrisisContact(
            label: 'Centrum krizové intervence',
            number: '284 016 666',
            description: 'Praha — dostupné 24/7',
          ),
          const SizedBox(height: 12),
          _CrisisContact(
            label: 'Linka první psychické pomoci',
            number: '116 123',
            description: 'Anonymní, bezplatná',
          ),
        ],
      ),
    );
  }
}

class _CrisisContact extends StatelessWidget {
  final String label;
  final String number;
  final String description;

  const _CrisisContact({required this.label, required this.number, required this.description});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => launchUrl(Uri.parse('tel:$number')),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTypography.bodyPrimary.copyWith(fontWeight: FontWeight.w600)),
                  Text(description, style: AppTypography.bodySm),
                ],
              ),
            ),
            Text(number, style: AppTypography.mono.copyWith(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
