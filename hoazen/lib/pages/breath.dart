import 'package:flutter/material.dart';
import '../../shared/checkin_common.dart';

class breathPage extends StatefulWidget {
  const breathPage({super.key});

  @override
  State<breathPage> createState() => _breathPageState();
}

class _breathPageState extends State<breathPage>
    with TickerProviderStateMixin {
  // Main 16s breathing loop (four 4s stages = four equal 25% segments).
  late final AnimationController _controller;
  late final Animation<double> _scale;

  // Short controller that eases the rings back to rest when paused,
  // so they don't snap from a mid-breath size down to 1.0.
  late final AnimationController _release;

  bool _running = false;
  bool _releasing = false;
  double _pauseScale = 1.0; // scale captured at the moment of pausing

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    );

    // Scale timeline: 1.0 -> 1.4 (in) -> hold -> 1.0 (out) -> hold.
    // Each item weighs 25, so each stage is exactly 25% of the loop.
    _scale = TweenSequence<double>([
      // Stage 1 (0.00–0.25) Breathe In: 1.0 -> 1.4
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.4)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
      // Stage 2 (0.25–0.50) Hold at 1.4
      TweenSequenceItem(tween: ConstantTween(1.4), weight: 25),
      // Stage 3 (0.50–0.75) Breathe Out: 1.4 -> 1.0
      TweenSequenceItem(
        tween: Tween(begin: 1.4, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
      // Stage 4 (0.75–1.00) Hold at 1.0
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 25),
    ]).animate(_controller);

    _release = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() => _releasing = false);
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    _release.dispose();
    super.dispose();
  }

  void _start() {
    _release.stop();
    setState(() {
      _releasing = false;
      _running = true;
    });
    _controller
      ..reset() // always begin a fresh cycle on "Breathe In"
      ..repeat(); // seamless: stage 4 ends at 1.0, stage 1 starts at 1.0
  }

  void _pause() {
    _pauseScale = _scale.value; // freeze current size, then ease it home
    _controller.stop();
    setState(() {
      _running = false;
      _releasing = true;
    });
    _release.forward(from: 0);
  }

  void _toggle() => _running ? _pause() : _start();

  // Scale actually shown on screen for the ring cluster.
  double get _displayScale {
    if (_running) return _scale.value;
    if (_releasing) {
      final t = Curves.easeOut.transform(_release.value);
      return _pauseScale + (1.0 - _pauseScale) * t; // -> settles at 1.0
    }
    return 1.0;
  }

  // Phase label read from the SAME timeline as the scale, so they can't drift.
  String get _phaseLabel {
    if (!_running) return 'Find Stillness';
    final t = _controller.value;
    if (t < 0.25) return 'Breath in';
    if (t < 0.50) return 'Hold';
    if (t < 0.75) return 'Breath out';
    return 'Hold';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 28),
        const Text(
          'Still Waters',
          style: TextStyle(
            fontFamily: 'serif', // swap for Playfair Display via google_fonts
            fontSize: 38,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1A1A1A),
          ),
        ),

        // Animated ring cluster + lotus.
        Expanded(
          child: Center(
            child: AnimatedBuilder(
              animation: Listenable.merge([_controller, _release]),
              builder: (context, _) => _RippleCluster(scale: _displayScale),
            ),
          ),
        ),

        // Phase label + subtitle (below the circle).
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Column(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: Text(
                    _phaseLabel,
                    key: ValueKey(_phaseLabel),
                    style: const TextStyle(
                      fontFamily: 'serif',
                      fontSize: 20,
                      color: Color(0xFF4F5B47),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // "four counts each" only while a session is running.
                AnimatedOpacity(
                  opacity: _running ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: const Text(
                    'four counts each',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 13,
                      color: Color(0xFF9AA394),
                    ),
                  ),
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 20),
        _BeginButton(running: _running, onTap: _toggle),
        const SizedBox(height: 36),
      ],
    );
  }
}

// Three concentric ring PNGs with the lotus centered on top.
class _RippleCluster extends StatelessWidget {
  final double scale;
  const _RippleCluster({required this.scale});

  @override
  Widget build(BuildContext context) {
    // Base sizes — tune to your actual exports. The whole cluster is scaled
    // together, so these are the RESTING (scale 1.0) sizes.
    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.scale(
            scale: scale,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset('assets/breath/breath_circle1.png', width: 280), // outermost
                Image.asset('assets/breath/breath_circle2.png', width: 210), // middle
                Image.asset('assets/breath/breath_circle3.png', width: 150), // innermost
              ],
            ),
          ),
          Image.asset('assets/breath/breath_flower.png', width: 92),   // lotus
        ],
      ),
    );
  }
}

class _BeginButton extends StatelessWidget {
  final bool running;
  final VoidCallback onTap;
  const _BeginButton({required this.running, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 22),
        PinkPillButton(label: running ? 'Pause' : 'Begin', onPressed: onTap),
      ],
    );
    // return GestureDetector(
    //   onTap: onTap,
    //   child: Container(
    //     width: 180,
    //     height: 52,
    //     alignment: Alignment.center,
    //     decoration: BoxDecoration(
    //       borderRadius: BorderRadius.circular(26),
    //       gradient: const LinearGradient(
    //         colors: [Color(0xFFF3A6BA), Color(0xFFF8C8D5)],
    //         begin: Alignment.centerLeft,
    //         end: Alignment.centerRight,
    //       ),
    //       boxShadow: [
    //         BoxShadow(
    //           color: const Color(0xFFF3A6BA).withOpacity(0.4),
    //           blurRadius: 16,
    //           offset: const Offset(0, 6),
    //         ),
    //       ],
    //     ),
    //     child: Text(
    //       running ? 'Pause' : 'Begin',
    //       style: const TextStyle(
    //         color: Colors.white,
    //         fontSize: 16,
    //         fontWeight: FontWeight.w600,
    //         letterSpacing: 0.5,
    //       ),
    //     ),
    //   ),
    // );
  }
}