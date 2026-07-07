import 'dart:async';
import 'package:flutter/material.dart';
import '../../shared/checkin_common.dart';
import 'quiz.dart';
import '../journal/calendar.dart';

int _savedGlobalFrameIndex = 0;

class ImageAnimationWidget extends StatefulWidget {
  const ImageAnimationWidget({super.key});

  @override
  State<ImageAnimationWidget> createState() => _ImageAnimationWidgetState();
}

class _ImageAnimationWidgetState extends State<ImageAnimationWidget> {
  final List<String> _frames = [
    'images/flower1.png',
    'images/flower2.png',
    'images/flower3.png',
    'images/flower4.png',
    'images/flower5.png',
    'images/flower6.png',
    'images/flower7.png',
    'images/flower8.png',
    'images/flower9.png',
    'images/flower10.png',
    'images/flower11.png',
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
          // --- REAL FLOWER ANIMATION REPLACES PLACEHOLDER ---
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: Center(
              child: ImageAnimationWidget(),
            ),
          ),
          
          const SizedBox(height: 12),

          // (Phần của Khôi) Card DAILY CHECK IN — khung hồng/mint dẫn vào luồng check-in
          DailyCheckInCard(onCheckIn: () => _startCheckIn(context)),
        ],
      ),
    );
  }
}