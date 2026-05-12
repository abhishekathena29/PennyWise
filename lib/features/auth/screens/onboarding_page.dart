import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../../../widgets/app_logo.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key, required this.onComplete, this.userName});

  final String? userName;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _OnboardingFlow(userName: userName, onComplete: onComplete),
    );
  }
}

class _OnboardingFlow extends StatefulWidget {
  const _OnboardingFlow({required this.onComplete, this.userName});

  final String? userName;
  final VoidCallback onComplete;

  @override
  State<_OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<_OnboardingFlow> {
  final _pageController = PageController();
  int _currentSlide = 0;

  final List<_OnboardingSlide> _slides = const [
    _OnboardingSlide(
      icon: Icons.account_balance_wallet_outlined,
      title: 'Track money without noise',
      description:
          'A calm dashboard for expenses, income, and activity synced to your account.',
      color: Color(0xFF25B8A3),
      accent: 'Live activity',
      stat: '24/7 sync',
    ),
    _OnboardingSlide(
      icon: Icons.trending_up,
      title: 'Know what is safe to spend',
      description:
          'Home metrics update from your cash flow and reserve money for goals automatically.',
      color: Color(0xFF29B6F6),
      accent: 'Smart balance',
      stat: 'Daily insight',
    ),
    _OnboardingSlide(
      icon: Icons.flag_outlined,
      title: 'Automate your saving rhythm',
      description:
          'Set a goal once and PennyWise calculates how much to set aside per day and month.',
      color: Color(0xFFF2A23A),
      accent: 'Auto plan',
      stat: 'Goal pacing',
    ),
    _OnboardingSlide(
      icon: Icons.lock_outline,
      title: 'Private by default',
      description:
          'Email authentication keeps each user profile, transactions, and goals separate.',
      color: Color(0xFF24B37E),
      accent: 'Secure account',
      stat: 'Firebase Auth',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (_currentSlide < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 360),
        curve: Curves.easeOutCubic,
      );
      return;
    }
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_currentSlide];
    final isLast = _currentSlide == _slides.length - 1;

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF3FAF8), Color(0xFFF8FDFC), Color(0xFFFFFFFF)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -120,
            right: -60,
            child: _GlowOrb(color: slide.color, size: 260),
          ),
          Positioned(
            bottom: 180,
            left: -70,
            child: _GlowOrb(color: const Color(0xFFB6EEE6), size: 220),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.72),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.white),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const AppLogo(
                                size: 34,
                                padding: 5,
                                backgroundColor: Colors.transparent,
                                borderRadius: BorderRadius.all(Radius.circular(12)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'PennyWise',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                      if (!isLast)
                        TextButton(
                          onPressed: widget.onComplete,
                          child: const Text('Skip'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (_currentSlide == 0 && widget.userName != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        'Welcome, ${widget.userName}!',
                        style: const TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _slides.length,
                      onPageChanged: (index) =>
                          setState(() => _currentSlide = index),
                      itemBuilder: (context, index) {
                        final item = _slides[index];
                        return Column(
                          children: [
                            Expanded(
                              child: Center(
                                child: _OnboardingVisual(slide: item),
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.88),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(color: Colors.white),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x12000000),
                                    blurRadius: 32,
                                    offset: Offset(0, 20),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: item.color.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      '${item.accent} • ${item.stat}',
                                      style: TextStyle(
                                        color: item.color,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    item.title,
                                    style: const TextStyle(
                                      fontSize: 28,
                                      height: 1.12,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    item.description,
                                    style: const TextStyle(
                                      color: AppTheme.mutedForeground,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Row(
                        children: [
                          for (var index = 0; index < _slides.length; index++)
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              width: index == _currentSlide ? 26 : 8,
                              height: 8,
                              margin: const EdgeInsets.only(right: 6),
                              decoration: BoxDecoration(
                                color: index == _currentSlide
                                    ? slide.color
                                    : AppTheme.muted,
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                        ],
                      ),
                      const Spacer(),
                      SizedBox(
                        width: 172,
                        child: ElevatedButton.icon(
                          onPressed: _handleNext,
                          icon: Icon(
                            isLast ? Icons.check : Icons.arrow_forward_rounded,
                          ),
                          label: Text(isLast ? 'Start Tracking' : 'Continue'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10221F),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingSlide {
  const _OnboardingSlide({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.accent,
    required this.stat,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final String accent;
  final String stat;
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: 0.18),
              color.withValues(alpha: 0.0),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingVisual extends StatelessWidget {
  const _OnboardingVisual({required this.slide});

  final _OnboardingSlide slide;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 280,
          height: 280,
          decoration: BoxDecoration(
            color: slide.color.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
        ),
        Transform.rotate(
          angle: -0.12,
          child: Container(
            width: 228,
            height: 260,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(34),
              border: Border.all(color: Colors.white),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 24,
                  offset: Offset(0, 18),
                ),
              ],
            ),
          ),
        ),
        Container(
          width: 228,
          height: 260,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF10221F),
            borderRadius: BorderRadius.circular(34),
            boxShadow: [
              BoxShadow(
                color: slide.color.withValues(alpha: 0.22),
                blurRadius: 30,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: slide.color.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(slide.icon, color: Colors.white, size: 30),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _VisualMetric(
                        label: slide.accent,
                        value: slide.stat,
                      ),
                    ),
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: slide.color,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.arrow_upward_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _VisualMetric extends StatelessWidget {
  const _VisualMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 12),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}
