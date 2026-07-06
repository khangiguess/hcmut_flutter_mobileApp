import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

/// Widget gốc của toàn bộ app: khai báo theme (màu, font) và màn hình đầu tiên.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hoazen',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: ZenColors.headerGreen),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      home: const RootShell(),
    );
  }
}

// ============================================================================
// constant & color
// ============================================================================

/// Bảng màu lấy theo thiết kế Figma.
class ZenColors {
  static const headerGreen = Color(0xFF64795C); // nav bar
  static const completedGreen = Color(0xFFA3BC93); // Completed screen
  static const textGreen = Color(0xFF44603D); // question
  static const mintCard = Color(0xFFEAF0E4); // mint 
  static const chipLavender = Color(0xFFF4F1FC); // emotion chip
  static const pinkDark = Color(0xFFF08C9C); // dark pink gradient button
  static const pinkLight = Color(0xFFF7D3D6); // light pink gradient button
  static const navYellow = Color(0xFFF0E9AF); // icon yellow nav bar
  static const dotYellow = Color(0xFFE4E39B); // dot decoration scatted on header
}

/// font 
const String kSerifFont = 'serif';

// Emotion
class MoodOption {
  final String label;
  final String asset;
  const MoodOption(this.label, this.asset);
}

/// 5 levels of moods

const List<MoodOption> kMoods = [
  MoodOption('Terrible', 'assets/Terrible.svg'), // red
  MoodOption('Sad', 'assets/sad.svg'), // gray
  MoodOption('Normal', 'assets/Normal.svg'), // purple
  MoodOption('Happy', 'assets/Happy.svg'), // blue
  MoodOption('Joyful', 'assets/Joyful.svg'), // yellow
];

/// 4 levels of energy

const List<MoodOption> kEnergyOptions = [
  MoodOption('Drained', 'assets/Low Battery.svg'),
  MoodOption('Tired', 'assets/Napping.svg'),
  MoodOption('Steady', 'assets/Lightning Bolt.svg'),
  MoodOption('Energised', 'assets/Sparkling.svg'),
];

/// 4 needs
const List<MoodOption> kNeedOptions = [
  MoodOption('Rest/Quiet', 'assets/Crescent Moon.svg'),
  MoodOption('Connection', 'assets/Handshake.svg'),
  MoodOption('Movement', 'assets/Accompany.svg'),
  MoodOption('Energised', 'assets/Thinking Bubble.svg'),
];

/// multiple choice feelings
const List<String> kFeelings = [
  'Anxious', 'Sad', 'Angry', 'Happy',
  'Calm', 'Hopeful', 'Confused', 'Lonely',
  'Certain', 'Confident', 'Excited', 'Let-down',
  'Crushed', 'Envious', 'Content', 'Peaceful',
];

// ============================================================================
// Firebase connection (alter to Firestore later)ó kh
// ============================================================================

class CheckInEntry {
  final DateTime date;
  int mood; 
  int energy; 
  Set<String> feelings; 
  int need; 
  String note;

  CheckInEntry({
    required this.date,
    required this.mood,
    required this.energy,
    required this.feelings,
    required this.need,
    this.note = '',
  });

  // TODO(firebase): add these two helpers when connecting to Firestore:
  //   Map<String, dynamic> toMap() => {...};
  //   factory CheckInEntry.fromMap(Map<String, dynamic> m) => ...;
}

/// In-memory check-in store for the demo app.
///
/// TODO(firebase): switch this store to Firestore and keep the rest of the UI unchanged,
/// because the screens already read and write through CheckInStore.
/// Suggested collection: 'users/{uid}/checkins' with document id 'yyyy-MM-dd'.
class CheckInStore extends ChangeNotifier {
  CheckInStore._() {
    _seedMockData();
  }

  /// Singleton
  static final CheckInStore instance = CheckInStore._();

  final Map<String, CheckInEntry> _entries = {};

  String _key(DateTime d) => '${d.year}-${d.month}-${d.day}';

  /// Lấy check-in của 1 ngày (null nếu ngày đó chưa check-in).
  CheckInEntry? entryFor(DateTime d) => _entries[_key(d)];

  /// Save or overwrite a check-in entry.
  /// TODO(firebase): replace this with Firestore writes and then call notifyListeners().
  void save(CheckInEntry entry) {
    _entries[_key(entry.date)] = entry;
    notifyListeners();
  }

  /// Seed demo data only for past days so future dates remain blank.
  void _seedMockData() {
    final now = DateTime.now();
    final months = [
      DateTime(now.year, now.month - 1, 1),
      DateTime(now.year, now.month, 1),
    ];
    for (final month in months) {
      final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
      for (int d = 1; d <= daysInMonth; d++) {
        final date = DateTime(month.year, month.month, d);
        if (date.isAfter(now)) continue;
        if (isSameDay(date, now)) continue;
        final r = (d * 17 + month.month * 5) % 91; // random
        _entries[_key(date)] = CheckInEntry(
          date: date,
          mood: r % 5,
          energy: r % 4,
          feelings: {
            kFeelings[r % kFeelings.length],
            kFeelings[(r * 3 + 2) % kFeelings.length],
          },
          need: (r ~/ 3) % 4,
          note: d % 6 == 0
              ? 'I am keen for the presentation and to see the fireworks later today.'
              : '',
        );
      }
    }
  }
}

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String weekdayName(DateTime date) {
  const names = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  return names[date.weekday - 1];
}

String weekdayShortName(DateTime date) {
  const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return names[date.weekday - 1];
}

// ============================================================================
// ROOT SHELL - NAVIGATION BAR
// ============================================================================

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _tabIndex = 0; // 0 = Home, 1 = Journal, 2 = Breathe

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(onOpenJournal: () => setState(() => _tabIndex = 1)),
      const JournalScreen(),
      // ------------------------------------------------------------------
      // Breathe here
      // ------------------------------------------------------------------
      const PlaceholderScreen(title: 'Breathe'),
    ];

    final bgColor =
        _tabIndex == 2 ? Colors.white : ZenColors.headerGreen;

    return Scaffold(
      backgroundColor: bgColor,
      body: IndexedStack(index: _tabIndex, children: screens),
      bottomNavigationBar: ZenBottomNavBar(
        currentIndex: _tabIndex,
        onTap: (i) => setState(() => _tabIndex = i),
      ),
    );
  }
}

/// Thanh điều hướng dưới cùng: nền xanh, 3 icon vàng (Home / Journal / Breathe).
class ZenBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const ZenBottomNavBar(
      {super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const iconAssets = [
      'assets/Home.svg',
      'assets/Book.svg',
      'assets/Breathe.svg',
    ];

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: ZenColors.headerGreen,
      selectedItemColor: ZenColors.navYellow,
      unselectedItemColor: ZenColors.navYellow.withValues(alpha: 0.55),
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      elevation: 0,
      items: List.generate(iconAssets.length, (i) {
        return BottomNavigationBarItem(
          icon: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Opacity(
              opacity: i == currentIndex ? 1 : 0.6,
              child: SvgPicture.asset(
                iconAssets[i],
                width: 26,
                height: 26,
              ),
            ),
          ),
          label: '',
        );
      }),
    );
  }
}

// ============================================================================
// HOME SCREEN
// ============================================================================

class HomeScreen extends StatelessWidget {
  final VoidCallback onOpenJournal;
  const HomeScreen({super.key, required this.onOpenJournal});

  Future<void> _startCheckIn(BuildContext context) async {
    // Mở luồng Daily Check In (route toàn màn hình).
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const CheckInFlowScreen()),
    );
    if (result == 'journal') onOpenJournal();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ---- Header xanh: logo sen + lời chào + chấm vàng trang trí ----
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Stack(
              children: [
                const DecorativeDots(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.spa_outlined,
                        size: 44,
                        color: ZenColors.pinkDark.withValues(alpha: 0.9)),
                    const SizedBox(height: 12),
                    const Text(
                      'Hello, Jess',
                      style: TextStyle(
                        fontFamily: kSerifFont,
                        fontSize: 40,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // ---- Tấm trắng bo góc trên, chứa nội dung chính ----
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 40, 28, 24),
              child: Column(
                children: [
                  // Nụ hoa sen hồng (vẽ bằng CustomPaint).
                  const SizedBox(
                    width: 90,
                    height: 130,
                    child: CustomPaint(painter: LotusBudPainter()),
                  ),
                  const SizedBox(height: 48),
                  DailyCheckInCard(onCheckIn: () => _startCheckIn(context)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class DecorativeDots extends StatelessWidget {
  const DecorativeDots({super.key});

  @override
  Widget build(BuildContext context) {
    Widget dot(double size, double left, double top, double alpha) =>
        Positioned(
          left: left,
          top: top,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ZenColors.dotYellow.withValues(alpha: alpha),
            ),
          ),
        );
    return SizedBox(
      height: 120,
      width: double.infinity,
      child: Stack(
        children: [
          dot(8, 180, 6, .9),
          dot(14, 230, 40, .6),
          dot(6, 280, 14, .9),
          dot(10, 305, 70, .8),
          dot(16, 250, 95, .5),
          dot(7, 320, 40, .9),
        ],
      ),
    );
  }
}

class LotusBudPainter extends CustomPainter {
  const LotusBudPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFF9BCC5), Color(0xFFEF8AA0)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    final bud = Path()
      ..moveTo(w / 2, 0)
      ..cubicTo(w * 0.95, h * 0.35, w * 0.92, h * 0.75, w / 2, h)
      ..cubicTo(w * 0.08, h * 0.75, w * 0.05, h * 0.35, w / 2, 0)
      ..close();
    canvas.drawPath(bud, paint);

    // Đường gân giữa 2 cánh (màu hồng đậm hơn, mờ).
    final line = Paint()
      ..color = const Color(0xFFD96F86).withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final vein = Path()
      ..moveTo(w / 2, h * 0.18)
      ..quadraticBezierTo(w * 0.38, h * 0.6, w * 0.46, h * 0.95);
    canvas.drawPath(vein, line);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DailyCheckInCard extends StatelessWidget {
  final VoidCallback onCheckIn;
  const DailyCheckInCard({super.key, required this.onCheckIn});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 90),
      decoration: BoxDecoration(
        color: ZenColors.mintCard,
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'DAILY CHECK IN',
            style: TextStyle(
              color: ZenColors.textGreen,
              fontSize: 16,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'How are you today?',
            style: TextStyle(
              fontFamily: kSerifFont,
              fontSize: 26,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 22),
          PinkPillButton(label: 'Check-in', onPressed: onCheckIn),
        ],
      ),
    );
  }
}

class PinkPillButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final double width;
  const PinkPillButton(
      {super.key, required this.label, this.onPressed, this.width = 280});

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: width,
          height: 58,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [ZenColors.pinkDark, ZenColors.pinkLight],
            ),
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: ZenColors.pinkDark.withValues(alpha: 0.45),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// [6] CHECK-IN FLOW 
// ============================================================================
class CheckInFlowScreen extends StatefulWidget {
  const CheckInFlowScreen({super.key});

  @override
  State<CheckInFlowScreen> createState() => _CheckInFlowScreenState();
}

class _CheckInFlowScreenState extends State<CheckInFlowScreen> {
  int _step = 0; // 0..3
  bool _completed = false;
  int? _mood;
  int? _energy;
  final Set<String> _feelings = {};
  int? _need;

  bool get _stepAnswered => switch (_step) {
        0 => _mood != null,
        1 => _energy != null,
        2 => _feelings.isNotEmpty,
        _ => _need != null,
      };

  void _next() {
    if (_step < 3) {
      setState(() => _step++);
    } else {
      CheckInStore.instance.save(CheckInEntry(
        date: DateTime.now(),
        mood: _mood!,
        energy: _energy!,
        feelings: Set.of(_feelings),
        need: _need!,
      ));
      setState(() => _completed = true);
    }
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step--);
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_completed) return const CheckInCompletedView();
    final Widget question = switch (_step) {
      0 => Column(children: [
          const QuestionTitle('How are you today?'),
          const SizedBox(height: 20),
          MoodSelector(
            selected: _mood,
            onChanged: (v) => setState(() => _mood = v),
          ),
        ]),
      1 => Column(children: [
          const QuestionTitle('How is your energy today?'),
          const SizedBox(height: 20),
          EnergySelector(
            selected: _energy,
            onChanged: (v) => setState(() => _energy = v),
          ),
        ]),
      2 => Column(children: [
          const QuestionTitle('What is on your heart?'),
          const SizedBox(height: 4),
          const Text('Choose all that applies',
              style: TextStyle(color: ZenColors.textGreen, fontSize: 13)),
          const SizedBox(height: 16),
          FeelingSelector(
            selected: _feelings,
            onToggle: (f) => setState(() {
              _feelings.contains(f) ? _feelings.remove(f) : _feelings.add(f);
            }),
          ),
        ]),
      _ => Column(children: [
          const QuestionTitle('What do you need most today?'),
          const SizedBox(height: 20),
          NeedSelector(
            selected: _need,
            onChanged: (v) => setState(() => _need = v),
          ),
        ]),
    };

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: _back,
                  icon: const Icon(Icons.chevron_left,
                      size: 32, color: ZenColors.textGreen),
                ),
              ),
              const Text(
                'Daily Check In',
                style: TextStyle(fontFamily: kSerifFont, fontSize: 36),
              ),
              const SizedBox(height: 20),
              CheckInProgressBar(progress: _step / 4),
              const Spacer(),
              question,
              const Spacer(flex: 2),
              PinkPillButton(
                label: _step < 3 ? 'Next' : 'Submit',
                onPressed: _stepAnswered ? _next : null,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class QuestionTitle extends StatelessWidget {
  final String text;
  const QuestionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontFamily: kSerifFont,
        fontSize: 28,
        color: ZenColors.textGreen,
      ),
    );
  }
}

/// Thanh progress + dòng "Progress X%" trong luồng check-in.
class CheckInProgressBar extends StatelessWidget {
  final double progress; // 0.0 → 1.0
  const CheckInProgressBar({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 8,
            width: double.infinity,
            child: Stack(children: [
              Container(color: const Color(0xFFDDDDDD)),
              FractionallySizedBox(
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [
                      Color(0xFF9DB68C),
                      Color(0xFF3E5B36),
                    ]),
                  ),
                ),
              ),
            ]),
          ),
        ),
        const SizedBox(height: 8),
        Text('Progress ${(progress * 100).round()}%',
            style: const TextStyle(fontSize: 13, color: Colors.black87)),
      ],
    );
  }
}

class CheckInCompletedView extends StatelessWidget {
  const CheckInCompletedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZenColors.completedGreen,
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 36),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          decoration: BoxDecoration(
            color: const Color(0xFFFBF6FA),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Completed\nCheck In',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: kSerifFont, fontSize: 40),
              ),
              const SizedBox(height: 28),
              PinkPillButton(
                label: 'Return to homepage',
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 16),
              PinkPillButton(
                label: 'View Journal',
                // Trả 'journal' về HomeScreen để RootShell đổi sang tab Journal.
                onPressed: () => Navigator.of(context).pop('journal'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// WIDGET for selection emotion (checkin - journal page)
// ============================================================================

class MoodSelector extends StatelessWidget {
  final int? selected;
  final ValueChanged<int>? onChanged;
  const MoodSelector({super.key, required this.selected, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(kMoods.length, (i) {
        final isSelected = selected == i;
        return GestureDetector(
          onTap: onChanged == null ? null : () => onChanged!(i),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 5),
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? ZenColors.textGreen : Colors.transparent,
                width: 2,
              ),
            ),
            child: SvgPicture.asset(kMoods[i].asset, width: 50, height: 50),
          ),
        );
      }),
    );
  }
}
class SquareOptionRow extends StatelessWidget {
  final List<MoodOption> options;
  final int? selected;
  final ValueChanged<int>? onChanged;
  const SquareOptionRow(
      {super.key,
      required this.options,
      required this.selected,
      this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(options.length, (i) {
        final isSelected = selected == i;
        return GestureDetector(
          onTap: onChanged == null ? null : () => onChanged!(i),
          child: Container(
            width: 80,
            height: 84,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: ZenColors.mintCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? ZenColors.textGreen
                    : Colors.black.withValues(alpha: 0.08),
                width: isSelected ? 1.8 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      )
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(options[i].asset, width: 26, height: 26),
                const SizedBox(height: 6),
                Text(options[i].label,
                    style: const TextStyle(
                        fontSize: 11.5, color: ZenColors.textGreen)),
              ],
            ),
          ),
        );
      }),
    );
  }
}

/// Câu "How is your energy today?" — 4 ô Drained/Tired/Steady/Energised.
class EnergySelector extends StatelessWidget {
  final int? selected;
  final ValueChanged<int>? onChanged;
  const EnergySelector({super.key, required this.selected, this.onChanged});

  @override
  Widget build(BuildContext context) => SquareOptionRow(
      options: kEnergyOptions, selected: selected, onChanged: onChanged);
}

/// Câu "What do you need most today?" — 4 ô Rest/Connection/Movement/Energised.
class NeedSelector extends StatelessWidget {
  final int? selected;
  final ValueChanged<int>? onChanged;
  const NeedSelector({super.key, required this.selected, this.onChanged});

  @override
  Widget build(BuildContext context) => SquareOptionRow(
      options: kNeedOptions, selected: selected, onChanged: onChanged);
}

/// Multiple choice (what is in your heart)
class FeelingSelector extends StatelessWidget {
  final Set<String> selected;
  final ValueChanged<String>? onToggle;
  const FeelingSelector({super.key, required this.selected, this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 10,
      children: kFeelings.map((f) {
        final isSelected = selected.contains(f);
        return GestureDetector(
          onTap: onToggle == null ? null : () => onToggle!(f),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
            decoration: BoxDecoration(
              color: ZenColors.chipLavender,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected
                    ? ZenColors.textGreen
                    : Colors.black.withValues(alpha: 0.10),
                width: isSelected ? 1.6 : 1,
              ),
            ),
            child: Text(f,
                style:
                    const TextStyle(fontSize: 13.5, color: Colors.black87)),
          ),
        );
      }).toList(),
    );
  }
}

// ============================================================================
// [8] JOURNAL 
// ============================================================================

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime? _selectedDay; // != null → check for specific day

  void _changeMonth(int delta) {
    setState(() => _month = DateTime(_month.year, _month.month + delta, 1));
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedDay != null) {
      return DayDetailScreen(
        date: _selectedDay!,
        onBack: () => setState(() => _selectedDay = null),
      );
    }

    final today = DateTime.now();
    final todayLabel =
        'Today: ${weekdayName(today)}, ${today.day} ${_monthName(today.month)} ${today.year}';

    return Column(
      children: [
        const SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(24, 8, 24, 30),
            child: DecorativeDots(),
          ),
        ),
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
            ),
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
            child: Column(
              children: [
                Text(
                  todayLabel,
                  style: const TextStyle(
                    fontSize: 14,
                    color: ZenColors.textGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => _changeMonth(-1),
                      icon: const Icon(Icons.chevron_left, size: 30),
                    ),
                    Text(
                      '${_monthName(_month.month)} ${_month.year}',
                      style: const TextStyle(
                          fontSize: 28, fontWeight: FontWeight.w800),
                    ),
                    IconButton(
                      onPressed: () => _changeMonth(1),
                      icon: const Icon(Icons.chevron_right, size: 30),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Row(
                    children: List.generate(7, (index) {
                      final day = DateTime(2024, 1, index + 1);
                      return Expanded(
                        child: Center(
                          child: Text(
                            weekdayShortName(day),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: ZenColors.textGreen.withValues(alpha: 0.78),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: ListenableBuilder(
                    listenable: CheckInStore.instance,
                    builder: (context, _) => MonthCalendarGrid(
                      month: _month,
                      onDayTap: _onDayTap,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _onDayTap(DateTime day) {
    final entry = CheckInStore.instance.entryFor(day);
    if (entry != null) {
      setState(() => _selectedDay = day);
    } else if (isSameDay(day, DateTime.now())) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const CheckInFlowScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No check-in for this day')),
      );
    }
  }

  String _monthName(int m) => const [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December',
      ][m - 1];
}
class MonthCalendarGrid extends StatelessWidget {
  final DateTime month; 
  final ValueChanged<DateTime> onDayTap;
  const MonthCalendarGrid(
      {super.key, required this.month, required this.onDayTap});

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final firstWeekday = month.weekday; 
    final leadingEmpty = firstWeekday - 1; 
    final today = DateTime.now();

    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 0.68,
      ),
      itemCount: leadingEmpty + daysInMonth,
      itemBuilder: (context, index) {
        if (index < leadingEmpty) return const SizedBox.shrink();
        final day = index - leadingEmpty + 1;
        final date = DateTime(month.year, month.month, day);
        final entry = CheckInStore.instance.entryFor(date);
        final isToday = isSameDay(date, today);
        final isFuture = date.isAfter(today);

        return GestureDetector(
          onTap: isFuture ? null : () => onDayTap(date),
          child: Container(
            color: isFuture ? Colors.white : null,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!isFuture)
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isToday
                            ? ZenColors.pinkDark
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: entry != null
                        ? SvgPicture.asset(kMoods[entry.mood].asset,
                            width: 34, height: 34)
                        : Container(
                            width: 34,
                            height: 34,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFEDEDED),
                            ),
                          ),
                  )
                else
                  const SizedBox(height: 34),
                const SizedBox(height: 3),
                Container(
                  padding: const EdgeInsets.only(bottom: 2),
                  decoration: isToday
                      ? const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                                color: ZenColors.pinkDark, width: 2),
                          ),
                        )
                      : null,
                  child: Text('$day',
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ============================================================================
// DAY DETAIL - JOURNAL
// ============================================================================

class DayDetailScreen extends StatefulWidget {
  final DateTime date;
  final VoidCallback onBack; // return back
  const DayDetailScreen(
      {super.key, required this.date, required this.onBack});

  @override
  State<DayDetailScreen> createState() => _DayDetailScreenState();
}

class _DayDetailScreenState extends State<DayDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final entry = CheckInStore.instance.entryFor(widget.date);
    if (entry == null) {
      return Center(
        child: TextButton(onPressed: widget.onBack, child: const Text('Back')),
      );
    }

    final hasNote = entry.note.trim().isNotEmpty;

    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: widget.onBack,
                  icon: const Icon(Icons.chevron_left,
                      size: 32, color: ZenColors.textGreen),
                ),
              ),
              const Text('Daily Check In',
                  style: TextStyle(fontFamily: kSerifFont, fontSize: 36)),
              const SizedBox(height: 28),

              // --- Question 1: mood ---
              const QuestionTitle('How are you today?'),
              const SizedBox(height: 14),
              MoodSelector(selected: entry.mood), // onChanged null = read-only
              const SizedBox(height: 34),

              // --- Question 2: energy ---
              const QuestionTitle('How is your energy today?'),
              const SizedBox(height: 14),
              EnergySelector(selected: entry.energy),
              const SizedBox(height: 34),

              // --- Question 3: feelings ---
              const QuestionTitle('What is on your heart?'),
              const SizedBox(height: 4),
              const Text('Choose all that applies',
                  style:
                      TextStyle(color: ZenColors.textGreen, fontSize: 13)),
              const SizedBox(height: 14),
              FeelingSelector(selected: entry.feelings),
              const SizedBox(height: 34),

              // --- Question 4: need ---
              const QuestionTitle('What do you need most today?'),
              const SizedBox(height: 14),
              NeedSelector(selected: entry.need),
              const SizedBox(height: 40),

              // --- Note ---
              const QuestionTitle('Write a note for today'),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 130),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: ZenColors.mintCard,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Text(
                  hasNote ? entry.note : '',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Colors.black.withValues(alpha: 0.55),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              PinkPillButton(
                label: hasNote ? 'Edit Notes' : 'Add Notes',
                onPressed: () => _openNoteDialog(entry),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openNoteDialog(CheckInEntry entry) async {
    final newNote = await showDialog<String>(
      context: context,
      builder: (_) => NoteDialog(initialText: entry.note),
    );
    if (newNote != null) {
      entry.note = newNote;
      CheckInStore.instance.save(entry); // TODO(firebase): sẽ ghi Firestore
      setState(() {});
    }
  }
}

class NoteDialog extends StatefulWidget {
  final String initialText;
  const NoteDialog({super.key, required this.initialText});

  @override
  State<NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<NoteDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialText);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFFBF6FA),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Tiêu đề + nút back đóng dialog.
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.chevron_left,
                      size: 26, color: ZenColors.textGreen),
                ),
                const SizedBox(width: 4),
                const Text(
                  'Write a note for today',
                  style: TextStyle(
                    fontFamily: kSerifFont,
                    fontSize: 22,
                    color: ZenColors.textGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Ô nhập ghi chú.
            TextField(
              controller: _controller,
              maxLines: 9,
              decoration: InputDecoration(
                hintText: 'Type something…',
                filled: true,
                fillColor: ZenColors.mintCard,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: ZenColors.textGreen),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(
                      color: ZenColors.textGreen.withValues(alpha: 0.6)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(
                      color: ZenColors.textGreen, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 20),
            PinkPillButton(
              label: 'Add Notes',
              width: 240,
              onPressed: () =>
                  Navigator.of(context).pop(_controller.text.trim()),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// BREATHE
// ============================================================================
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            border: Border.all(
                color: ZenColors.textGreen.withValues(alpha: 0.4),
                width: 2,
                style: BorderStyle.solid),
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
    );
  }
}
