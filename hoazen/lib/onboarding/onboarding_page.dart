import 'package:flutter/material.dart';
import 'package:liquid_swipe/liquid_swipe.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';



class OnboardingSlide {
  final Color background;
  final String image;
  final String title;
  final String body;

  const OnboardingSlide({
    required this.background,
    required this.image,
    required this.title,
    required this.body,
  });
}

// Removed stray build method that referenced undefined identifiers.

const _slides = <OnboardingSlide>[
  OnboardingSlide(
    background: Color(0xFFAAC29E),
    image: 'assets/Home.png',
    title: 'Daily Bloom',
    body: 'Tap the lotus each day to receive an inspiring quote '
        'and begin your daily check-in.',
  ),

  OnboardingSlide(
    background: Color(0xFFEF91A3),
    image: 'assets/Book.png',
    title: 'Reflect Journal',
    body: 'Log your mood, write a reflection, and watch your '
        'emotional journey bloom over time.',
  ),
  OnboardingSlide(
    background: Color.fromRGBO(205, 195, 252, 1),
    image: 'assets/Breathe.png',
    title: 'Breath',
    body: 'Follow gentle breathing exercises designed to help slow '
        'your mind and ease everyday stress.',
  ),
];

class OnboardingPage extends StatefulWidget {
  /// Called when the user finishes onboarding (Next on the last slide).
  final VoidCallback onFinish;
  const OnboardingPage({super.key, required this.onFinish});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final LiquidController _liquid = LiquidController();
  int _page = 0;

  bool get _isLast => _page == _slides.length - 1;

  void _next() {
    if (_isLast) {
      widget.onFinish();
    } else {
      _liquid.animateToPage(page: _page + 1, duration: 500);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          LiquidSwipe(
            liquidController: _liquid,
            enableLoop: false,
            slideIconWidget: null, // no built-in arrow; we use our own button
            waveType: WaveType.liquidReveal,
            onPageChangeCallback: (i) => setState(() => _page = i),
            pages: [
              for (final s in _slides) _Slide(data: s),
            ],
          ),

          // Page indicator dots — centered near the bottom.
          Positioned(
            left: 0,
            right: 0,
            bottom: 96,
            child: SafeArea(
              top: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_slides.length, (i) {
                  final active = i == _page;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: active ? 24 : 14,
                    height: 5,
                    decoration: BoxDecoration(
                      color: active
                          ? const Color(0xFFE3C878)
                          : const Color(0x66E3C878),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),
          ),

          // Next button — bottom right.
          Positioned(
            right: 28,
            bottom: 28,
            child: SafeArea(
              top: false,
              child: _NextButton(
                label: _isLast ? 'Get Started' : 'Next',
                onTap: _next,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Slide extends StatelessWidget {
  final OnboardingSlide data;
  const _Slide({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: data.background,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 3),

              // Soft translucent bloom with the icon centered.
              Center(
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin:Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0.4),
                        Colors.white.withOpacity(0.0),
                      ],
                      stops: const [0.45, 1.0],
                    ),
                  ),
                  child: Center(
                    child: Image.asset(data.image, width: 110),
                  ),
                ),
              ),

              const Spacer(flex: 3),

              Text(
                data.title,
                style: GoogleFonts.lora( 
                  fontSize: 40,
                  fontWeight: FontWeight.w500,
                  height: 1.1,
                  color: const Color(0xFF3A3A3A), // Added const here since TextStyle isn't const anymore
                ),
              ),


              const SizedBox(height: 16),
              Text(
                data.body,
                style: GoogleFonts.poppins( 
                  fontSize: 17,
                  height: 1.5,
                  color: Color(0xFF4A4A4A),
                ),
              ),

              // Room so the text never sits under the dots / Next button.
              const SizedBox(height: 150),
            ],
          ),
        ),
      ),
    );
  }
}

class _NextButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _NextButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: LinearGradient(
            colors: [
              const Color(0xFFF3A6BA).withOpacity(0.85),
              const Color(0xFFF8C8D5).withOpacity(0.85),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF3A6BA).withOpacity(0.35),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }
}