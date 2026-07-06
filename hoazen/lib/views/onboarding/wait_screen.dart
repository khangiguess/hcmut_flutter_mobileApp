import 'package:flutter/material.dart';

class WaitScreen extends StatelessWidget {
  const WaitScreen({super.key});

  static const _startGradient = Color(0xFFAAC29E);
  static const _endGradient = Color(0xFF42624B);
  static const _spotColor = Color(0xFFF4E8B1);
  static const _logoStrokeColor = Color(0xFFFFACA9);
  static const iconImage = 'assets/images/hoazen.png';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [_startGradient, _endGradient],
            stops: [0.34, 1],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              const _WelcomeSpot(left: 56, top: 51, size: 6),
              const _WelcomeSpot(left: 231, top: 81, size: 6),
              const _WelcomeSpot(left: 307, top: 35, size: 6),
              const _WelcomeSpot(left: 342, top: 75, size: 6),
              const _WelcomeSpot(left: 313, top: 87, size: 10),
              const _WelcomeSpot(left: 150, top: 54, size: 10),
              const _WelcomeSpot(left: 123, top: 29, size: 6),
              const _WelcomeSpot(left: 313, top: 131, size: 10),
              const _WelcomeSpot(left: 367, top: 19, size: 10),
              const _WelcomeSpot(left: 201, top: 14, size: 15),
              const _WelcomeSpot(left: 352, top: 113, size: 15),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 200),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Image.asset(
                            iconImage,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.spa_outlined,
                                size: 132,
                                color: _logoStrokeColor,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'HoaZen',
                      style: textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -1.0,
                        fontSize: 42,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomeSpot extends StatelessWidget {
  const _WelcomeSpot({
    required this.left,
    required this.top,
    required this.size,
  });

  final double left;
  final double top;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: WaitScreen._spotColor,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
