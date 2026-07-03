import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({
    super.key,
    this.title = 'Preparing your wellness journey',
    this.subtitle = 'We are setting up your personalized plan for today.',
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primaryContainer.withValues(alpha: 0.92),
              colorScheme.surface.withValues(alpha: 0.98),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 152,
                          height: 152,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colorScheme.surface.withValues(alpha: 0.8),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.primary.withValues(
                                  alpha: 0.16,
                                ),
                                blurRadius: 32,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 124,
                          height: 124,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colorScheme.surface,
                            border: Border.all(
                              color: colorScheme.primary.withValues(
                                alpha: 0.14,
                              ),
                              width: 1.4,
                            ),
                          ),
                          child: Icon(
                            Icons.self_improvement,
                            size: 56,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Hoazen',
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: 240,
                      child: LinearProgressIndicator(
                        minHeight: 9,
                        borderRadius: BorderRadius.circular(999),
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        3,
                        (index) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeInOut,
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: index == 1
                                  ? colorScheme.primary
                                  : colorScheme.primary.withValues(alpha: 0.35),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
