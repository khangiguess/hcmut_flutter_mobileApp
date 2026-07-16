import 'dart:async';
import 'dart:convert'; // Required for parsing JSON data
import 'package:flutter/material.dart';
import '../../shared/checkin_common.dart';
import 'quiz.dart';
import '../journal/calendar.dart';
import 'package:http/http.dart' as http; // Required for the network call

// Global index variable to keep track of the animation frame state
int _savedGlobalFrameIndex = 0;
const String _apiBaseUrl = 'https://api.api-ninjas.com/v2/quoteoftheday';
const String apiKey = '9iemY8EQLBceU4osNv0pMItAFdnT79gPE0l301L1';

Future<Map<String, String>> fetchQuoteOfTheDay() async {
  try { 
    final uri = Uri.parse(_apiBaseUrl);
    final response = await http.get(
      uri,
      headers: {
        'X-Api-Key': apiKey,
      },
    ).timeout(const Duration(seconds: 7));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      if (data.isNotEmpty) {
        return {
          'quote': data[0]['quote'] ?? 'Peace comes from within.',
          'author': data[0]['author'] ?? 'Unknown',
        };
      }
    }
  } 
  catch (e, stackTrace) {
    debugPrint("ERROR: $e");
    debugPrint("STACK TRACE:");
    debugPrint(stackTrace.toString());
  }

  // Safe fallback if the user is completely offline
  return {
    'quote': "When you've got nothing, you've got nothing to lose.",
    'author': 'Bob Dylan',
  };
}

// ==========================================================================
// ANIMATED FLOWER WIDGET
// ==========================================================================
class ImageAnimationWidget extends StatefulWidget {
  final VoidCallback onAnimationStart;

  const ImageAnimationWidget({
    super.key,
    required this.onAnimationStart,
  });

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

    // Trigger the parent layout fade-in state
    widget.onAnimationStart(); 

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
// ==========================================================================
// CORE FLOWER PAGE VIEW (Now keeping state alive!)
// ==========================================================================
class FlowerPage extends StatefulWidget {
  const FlowerPage({super.key});

  @override
  State<FlowerPage> createState() => _FlowerPageState();
}

// 1. Added "with AutomaticKeepAliveClientMixin"
class _FlowerPageState extends State<FlowerPage> {
  late Future<Map<String, String>> _quoteFuture;
  bool _showQuote = false;

  // 2. Overrode wantKeepAlive to return true
  
  @override
  void initState() {
    super.initState();
    _quoteFuture = fetchQuoteOfTheDay(); 
  }

  // Opens the check-in flow with a fade/slide transition, then the journal if requested.
  Future<void> _startCheckIn(BuildContext context) async {
    final result = await Navigator.of(context).push<String>(
      FadeSlideRoute(page: const CheckInFlowScreen()),
    );
    if (result == 'journal' && context.mounted) {
      Navigator.of(context).push(
        FadeSlideRoute(
          page: Scaffold(
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
          // 1. Interactive Animated Flower Widget
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Center(
              child: ImageAnimationWidget(
                onAnimationStart: () {
                  setState(() {
                    _showQuote = true;
                  });
                },
              ),
            ),
          ),
          
          const SizedBox(height: 24),

          // 2. Welcome to HoaZen Box (Smoothly transitions from prompt to quote)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20), 
            decoration: BoxDecoration(
              color: ZenColors.headerGreen,
              borderRadius: BorderRadius.circular(30),
            ),
            child: AnimatedCrossFade(
              crossFadeState: !_showQuote 
                  ? CrossFadeState.showFirst 
                  : CrossFadeState.showSecond,
              duration: const Duration(milliseconds: 1800),
              
              firstChild: const SizedBox(
                width: double.infinity,
                child: Text(
                  'Tap on the flower to bloom and reveal your daily quote!',
                  style: TextStyle(
                    color: Colors.white, 
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              secondChild: FutureBuilder<Map<String, String>>(
                future: _quoteFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  }

                  final String quoteText = snapshot.data?['quote'] ?? '';
                  final String authorText = snapshot.data?['author'] ?? '';

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '"$quoteText"',
                        style: const TextStyle(
                          color: Colors.white, 
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (authorText.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          '- $authorText',
                          style: const TextStyle(
                            color: Color(0xFFFFF2B2), 
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 24),
          // 3. Daily Check-In Card Flow Element
          DailyCheckInCard(onCheckIn: () => _startCheckIn(context)),
        ],
      ),
    );
  }
}