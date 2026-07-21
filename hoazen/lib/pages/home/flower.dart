import 'dart:async';
import 'dart:convert'; // Required for parsing JSON data
import 'package:flutter/material.dart';
import '../../shared/checkin_common.dart';
import 'quiz.dart';
import '../journal/calendar.dart';
import 'package:http/http.dart' as http; // Required for the network call
import 'package:google_fonts/google_fonts.dart';

// ==========================================================================
// GLOBAL MEMORY STATES (Shared across page lifecycles)
// ==========================================================================
Map<String, String>? _cachedGlobalQuote; // Stores the network response in memory
int _savedGlobalFrameIndex = 0;
bool _savedGlobalShowQuote = false;



class LanguageProvider extends ChangeNotifier {
  String _currentLocale = 'en'; // Default language

  String get currentLocale => _currentLocale;

  // Toggle function that components can call from anywhere
  void toggleLanguage() {
    _currentLocale = (_currentLocale == 'en') ? 'vi' : 'en';
    notifyListeners(); 
  }

  // Translation lookup method
  String translate(String key) {
    return _localizedValues[_currentLocale]?[key] ?? key;
  }

  // Your central translation dictionary map
  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'daily_check_in': 'DAILY CHECK IN',
      'how_are_you_today?': 'How are you today',
      'check_in': 'Check-in',
    },
    'vi': {
      'daily_check_in': 'ĐIỂM DANH HÀNG NGÀY',
      'how_are_you_today?': 'Bạn hôm nay thế nào?',
      'check_in': 'Đăng ký vào',
    },
  };
}

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
    ).timeout(const Duration(seconds: 4)); 
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

  // Safe fallback if the API takes too long or fails
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

  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
    for (var frame in _frames){
      precacheImage(AssetImage(frame), context);
    }
  }

  void _startAnimation() {
    if (_isPlaying) return;

    // Trigger the parent layout fade-in state
    widget.onAnimationStart(); 

    setState(() {
      _isPlaying = true;
    });

    _timer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      if (!mounted) return;
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
// CORE FLOWER PAGE VIEW
// ==========================================================================
class FlowerPage extends StatefulWidget {
  const FlowerPage({super.key});

  @override
  State<FlowerPage> createState() => _FlowerPageState();
}

class _FlowerPageState extends State<FlowerPage> with AutomaticKeepAliveClientMixin {
  late Future<Map<String, String>> _quoteFuture;

  @override
  bool get wantKeepAlive => true;
  
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
    super.build(context); // Required by AutomaticKeepAliveClientMixin

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
      child: Column(
        children: [
          // 1. Interactive Animated Flower Widget
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 1.0),
            child: Center(
              child: ImageAnimationWidget(
                onAnimationStart: () {
                  setState(() {
                    _savedGlobalShowQuote = true; // 👈 Updates the global show state
                  });
                },
              ),
            ),
          ),
          
          const SizedBox(height: 24),

          // 2. Welcome to HoaZen Box (Prompt vanishes instantly, box & quote transition smoothly)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20), 
            decoration: BoxDecoration(
              color: ZenColors.headerGreen,
              borderRadius: BorderRadius.circular(30),
            ),
            child: AnimatedCrossFade(
              alignment: Alignment.center,
              crossFadeState: !_savedGlobalShowQuote 
                  ? CrossFadeState.showFirst 
                  : CrossFadeState.showSecond,
              duration: const Duration(milliseconds: 1800), // Smooth 1.8-second transition
              
              // --- FIRST STATE: The Prompt ---
              firstChild: SizedBox(
                width: double.infinity,
                child: !_savedGlobalShowQuote
                    ? Text(
                        'Tap on the flower to bloom and reveal your daily quote!',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      )
                    : const SizedBox.shrink(),
              ),

              // --- SECOND STATE: The Quote ---
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

                  return SizedBox(
                    width: double.infinity,
                    child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '"$quoteText"',
                        style: GoogleFonts.poppins(
                          color: Colors.white, 
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (authorText.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          '- $authorText',
                          style: GoogleFonts.lora(
                            color: Color(0xFFFFF2B2), 
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                    ),
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