import 'dart:async';
import 'package:flutter/material.dart';
import '../../shared/checkin_common.dart';
import 'quiz.dart';
import '../journal/calendar.dart';

// Global index variable to keep track of the animation frame state
int _savedGlobalFrameIndex = 0;

class ImageAnimationWidget extends StatefulWidget {
  const ImageAnimationWidget({super.key});

  @override
  State<ImageAnimationWidget> createState() => _ImageAnimationWidgetState();
}

class _ImageAnimationWidgetState extends State<ImageAnimationWidget> {
  final List<String> _frames = [
    'assets/photo/flower1.png',
    'assets/photo/flower2.png',
    'assets/photo/flower3.png',
    'assets/photo/flower4.png',
    'assets/photo/flower5.png',
    'assets/photo/flower6.png',
    'assets/photo/flower7.png',
    'assets/photo/flower8.png',
    'assets/photo/flower9.png',
    'assets/photo/flower10.png',
    'assets/photo/flower11.png',
  ];

  late int _currentFrameIndex;
  Timer? _timer;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _currentFrameIndex = _savedGlobalFrameIndex;
  }

  void _startAnimation() {
    if (_isPlaying) return;

    setState(() {
      _isPlaying = true;
    });

    _timer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      setState(() {
        if (_currentFrameIndex < _frames.length - 1) {
          _currentFrameIndex++;
          _savedGlobalFrameIndex = _currentFrameIndex; 
        } else {
          _timer?.cancel();
          _isPlaying = false;
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _startAnimation,
      child: Image.asset(
        _frames[_currentFrameIndex],
        width: 150,
        height: 150,
        gaplessPlayback: true,
      ),
    );
  }
}

class FlowerPage extends StatelessWidget {
  const FlowerPage({super.key});

  /// Opens the Daily Check In stream. If the user clicks "View Journal"
  /// on the completion screen, open the calendar page directory.
  Future<void> _startCheckIn(BuildContext context) async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const CheckInFlowScreen()),
    );
    if (result == 'journal' && context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(
              title: const Text('Journal'),
              backgroundColor: ZenColors.headerGreen,
              foregroundColor: Colors.white,
            ),
            body: const calendarPage(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
      child: Column(
        children: [
          // 1. Interactive Animated Flower Widget (Replaced the generic placeholder box)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: Center(
              child: ImageAnimationWidget(),
            ),
          ),
          
          const SizedBox(height: 24),

          // 2. Daily Check-In Card Flow Element
          DailyCheckInCard(onCheckIn: () => _startCheckIn(context)),
        ],
      ),
    );
  }
}