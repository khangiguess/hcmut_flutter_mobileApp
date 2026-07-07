import 'dart:async';
import 'package:flutter/material.dart';

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
          _savedGlobalFrameIndex = _currentFrameIndex; // Save the current frame index globally
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Pure white background match
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 50.0),
          child: Align(
            alignment: Alignment.topCenter, // Positions at the top middle
            child: const ImageAnimationWidget(), // Placed the interactive widget here
          ),
        ),
      ),
    );
  }
}