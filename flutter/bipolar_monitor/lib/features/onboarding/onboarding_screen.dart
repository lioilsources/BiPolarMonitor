import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../shared/widgets/app_button.dart';

class _OnboardingPage {
  final String title;
  final String body;
  final IconData icon;

  const _OnboardingPage({required this.title, required this.body, required this.icon});
}

const _pages = [
  _OnboardingPage(
    title: 'Ahoj.',
    body: 'Tato aplikace ti pomůže sledovat, jak se mění tvůj hlas '
        'a výraz v čase.\n\nNe diagnózy. Jen tvůj vlastní vzor.',
    icon: Icons.self_improvement_outlined,
  ),
  _OnboardingPage(
    title: 'Jak to funguje.',
    body: 'Jednou denně odpovíš na pět krátkých otázek.\n\n'
        'AI analyzuje tempo řeči, energii hlasu a výraz tváře. '
        'Výsledky vidíš jen ty.',
    icon: Icons.mic_none_rounded,
  ),
  _OnboardingPage(
    title: 'Tvoje data, tvoje pravidla.',
    body: 'Nahrávky se zpracují a smažou do 30 dní.\n\n'
        'Kdykoli můžeš vše smazat — bez podmínek, okamžitě.\n\n'
        'Tato aplikace není náhradou péče lékaře.',
    icon: Icons.lock_outline_rounded,
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  void _next() {
    if (_page < _pages.length - 1) {
      _controller.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeOutCubic);
    } else {
      context.go('/enrollment');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                itemCount: _pages.length,
                itemBuilder: (_, i) => _PageContent(page: _pages[i]),
              ),
            ),

            // Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: i == _page ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: i == _page ? AppColors.accent : AppColors.divider,
                  borderRadius: BorderRadius.circular(3),
                ),
              )),
            ),
            const SizedBox(height: 32),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: AppButton(
                label: _page < _pages.length - 1 ? 'Pokračovat' : 'Začít',
                onPressed: _next,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _PageContent extends StatelessWidget {
  final _OnboardingPage page;
  const _PageContent({required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 60, 32, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(page.icon, color: AppColors.accent, size: 36),
          ),
          const SizedBox(height: 40),
          Text(page.title, style: AppTypography.heading),
          const SizedBox(height: 16),
          Text(page.body, style: AppTypography.body),
        ],
      ),
    );
  }
}
