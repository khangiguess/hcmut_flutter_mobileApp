// Shared constants, data model, per-user Firestore store and animated reusable widgets for the Daily Check-in and Journal features.

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


// Only this account receives the fake demo check-ins on first sign-in.
const String kDemoAccountEmail = 'tranphandangkhoi205@gmail.com';

// App color palette.
class ZenColors {
  static const headerGreen = Color(0xFF64795C);
  static const completedGreen = Color(0xFFA3BC93);
  static const textGreen = Color(0xFF44603D);
  static const mintCard = Color(0xFFEAF0E4);
  static const chipLavender = Color(0xFFF4F1FC);
  static const pinkDark = Color(0xFFF08C9C);
  static const pinkLight = Color(0xFFF7D3D6);
}

const String kSerifFont = 'serif';

// One selectable option with a label and an icon asset.
class MoodOption {
  final String label;
  final String asset;
  const MoodOption(this.label, this.asset);
}

// The 5 mood levels shown as PNG faces (perfect-circle versions).
const List<MoodOption> kMoods = [
  MoodOption('Terrible', 'assets/1red.png'),
  MoodOption('Sad', 'assets/2grey.png'),
  MoodOption('Normal', 'assets/3purple.png'),
  MoodOption('Happy', 'assets/4green.png'),
  MoodOption('Joyful', 'assets/5yellow.png'),
];

// Energy level options (PNG icons because the Figma SVGs embed raster images).
const List<MoodOption> kEnergyOptions = [
  MoodOption('Drained', 'assets/Low Battery.png'),
  MoodOption('Tired', 'assets/Napping.png'),
  MoodOption('Steady', 'assets/Lightning Bolt.png'),
  MoodOption('Energised', 'assets/Sparkling.png'),
];

// "What do you need most today?" options.
const List<MoodOption> kNeedOptions = [
  MoodOption('Rest/Quiet', 'assets/Crescent Moon.png'),
  MoodOption('Connection', 'assets/Handshake.png'),
  MoodOption('Movement', 'assets/Accompany.png'),
  MoodOption('Energised', 'assets/Thinking Bubble.png'),
];

// Feeling chips for the multi-select question.
const List<String> kFeelings = [
  'Anxious', 'Sad', 'Angry', 'Happy',
  'Calm', 'Hopeful', 'Confused', 'Lonely',
  'Certain', 'Confident', 'Excited', 'Let-down',
  'Crushed', 'Envious', 'Content', 'Peaceful',
];

// One daily check-in record (mood, energy, feelings, need and an optional note).
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

  // Serializes this entry into a Firestore document.
  Map<String, dynamic> toMap() => {
        'date': Timestamp.fromDate(DateTime(date.year, date.month, date.day)),
        'mood': mood,
        'energy': energy,
        'feelings': feelings.toList(),
        'need': need,
        'note': note,
      };

  // Builds an entry from a Firestore document.
  factory CheckInEntry.fromMap(Map<String, dynamic> map) => CheckInEntry(
        date: (map['date'] as Timestamp).toDate(),
        mood: map['mood'] as int,
        energy: map['energy'] as int,
        feelings: Set<String>.from(map['feelings'] as List? ?? const []),
        need: map['need'] as int,
        note: map['note'] as String? ?? '',
      );
}

// Per-user Firestore store: mirrors users/{uid}/checkins into a local cache and follows sign-in/sign-out.
class CheckInStore extends ChangeNotifier {
  CheckInStore._() {
    FirebaseAuth.instance.authStateChanges().listen(_onAuthChanged);
  }

  static final CheckInStore instance = CheckInStore._();

  final Map<String, CheckInEntry> _entries = {};
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;
  CollectionReference<Map<String, dynamic>>? _collection;
  bool _seedChecked = false;

  // Document id format: yyyy-MM-dd.
  String _key(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // Returns the cached entry for a day, or null if there is no check-in.
  CheckInEntry? entryFor(DateTime d) => _entries[_key(d)];

  // Switches the Firestore subscription to the signed-in user's own collection.
  void _onAuthChanged(User? user) {
    _subscription?.cancel();
    _entries.clear();
    _seedChecked = false;
    _collection = null;
    if (user == null) {
      notifyListeners();
      return;
    }
    _collection = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('checkins');
    _subscription = _collection!.snapshots().listen((snapshot) {
      _entries.clear();
      for (final doc in snapshot.docs) {
        _entries[doc.id] = CheckInEntry.fromMap(doc.data());
      }
      // Seed fake data once, and only for the demo account.
      if (!_seedChecked) {
        _seedChecked = true;
        final isDemo =
            user.email?.toLowerCase() == kDemoAccountEmail.toLowerCase();
        if (isDemo && snapshot.docs.isEmpty) _seedFakeData();
      }
      notifyListeners();
    });
  }

  // Saves an entry locally for instant UI feedback, then writes it to Firestore.
  Future<void> save(CheckInEntry entry) async {
    _entries[_key(entry.date)] = entry;
    notifyListeners();
    await _collection?.doc(_key(entry.date)).set(entry.toMap());
  }

  // Uploads fake check-ins for past days of last month and this month into the demo account.
  Future<void> _seedFakeData() async {
    final collection = _collection;
    if (collection == null) return;
    final now = DateTime.now();
    final batch = FirebaseFirestore.instance.batch();
    final months = [
      DateTime(now.year, now.month - 1, 1),
      DateTime(now.year, now.month, 1),
    ];
    for (final month in months) {
      final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
      for (int d = 1; d <= daysInMonth; d++) {
        final date = DateTime(month.year, month.month, d);
        if (date.isAfter(now) || isSameDay(date, now)) continue;
        final r = (d * 17 + month.month * 5) % 91;
        final entry = CheckInEntry(
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
        batch.set(collection.doc(_key(date)), entry.toMap());
      }
    }
    await batch.commit();
  }
}

// Returns true when two dates fall on the same calendar day.
bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

// Full weekday name for a date.
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

// Short weekday name for a date.
String weekdayShortName(DateTime date) {
  const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return names[date.weekday - 1];
}

// Full month name for a month number (1-12).
String monthName(int m) => const [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ][m - 1];

// Wraps any widget with a springy press-down scale animation for tactile tap feedback.
class TapScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;
  const TapScale(
      {super.key, required this.child, this.onTap, this.pressedScale = 0.93});

  @override
  State<TapScale> createState() => _TapScaleState();
}

class _TapScaleState extends State<TapScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? widget.pressedScale : 1.0,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

// Rounded pink gradient button with press-scale feedback, used across the app.
class PinkPillButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final double width;
  const PinkPillButton(
      {super.key, required this.label, this.onPressed, this.width = 280});

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return AnimatedOpacity(
      opacity: enabled ? 1 : 0.5,
      duration: const Duration(milliseconds: 200),
      child: TapScale(
        onTap: onPressed,
        pressedScale: 0.95,
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
            style: GoogleFonts.poppins(
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

// Green serif title used for every check-in question.
class QuestionTitle extends StatelessWidget {
  final String text;
  const QuestionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: GoogleFonts.poppins(
        fontSize: 24,
        color: ZenColors.textGreen,
      ),
    );
  }
}

// Progress bar that animates smoothly toward the current step percentage.
class CheckInProgressBar extends StatelessWidget {
  final double progress;
  const CheckInProgressBar({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: progress.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) => Column(
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
                  widthFactor: value,
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
          Text('Progress ${(value * 100).round()}%',
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87)),
        ],
      ),
    );
  }
}

// Row of 5 mood faces with animated selection ring and pop effect; onChanged null renders it read-only.
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
        return TapScale(
          onTap: onChanged == null ? null : () => onChanged!(i),
          pressedScale: 0.85,
          child: AnimatedScale(
            scale: isSelected ? 1.12 : 1.0,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutBack,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 5),
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? ZenColors.textGreen : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Image.asset(kMoods[i].asset, width: 50, height: 50),
            ),
          ),
        );
      }),
    );
  }
}

// Row of square icon+label cards with animated border/shadow, shared by the Energy and Need questions.
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
        return TapScale(
          onTap: onChanged == null ? null : () => onChanged!(i),
          pressedScale: 0.9,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            width: 80,
            height: 84,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            transform: Matrix4.translationValues(0, isSelected ? -4 : 0, 0),
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
                Image.asset(options[i].asset, width: 26, height: 26),
                const SizedBox(height: 6),
                Text(options[i].label,
                    style: GoogleFonts.poppins(
                        fontSize: 11.5, color: ZenColors.textGreen)),
              ],
            ),
          ),
        );
      }),
    );
  }
}

// Selector for the energy question.
class EnergySelector extends StatelessWidget {
  final int? selected;
  final ValueChanged<int>? onChanged;
  const EnergySelector({super.key, required this.selected, this.onChanged});

  @override
  Widget build(BuildContext context) => SquareOptionRow(
      options: kEnergyOptions, selected: selected, onChanged: onChanged);
}

// Selector for the need question.
class NeedSelector extends StatelessWidget {
  final int? selected;
  final ValueChanged<int>? onChanged;
  const NeedSelector({super.key, required this.selected, this.onChanged});

  @override
  Widget build(BuildContext context) => SquareOptionRow(
      options: kNeedOptions, selected: selected, onChanged: onChanged);
}

// Multi-select grid of feeling chips with animated highlight color.
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
        return TapScale(
          onTap: onToggle == null ? null : () => onToggle!(f),
          pressedScale: 0.9,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
            decoration: BoxDecoration(
              color: isSelected
                  ? ZenColors.mintCard
                  : ZenColors.chipLavender,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected
                    ? ZenColors.textGreen
                    : Colors.black.withValues(alpha: 0.10),
                width: isSelected ? 1.6 : 1,
              ),
            ),
            child: Text(f,
                    style: GoogleFonts.poppins(fontSize: 13.5, color: Colors.black87)),
          ),
        );
      }).toList(),
    );
  }
}

// Page route with a shared fade + slide-up transition for smoother screen changes.
class FadeSlideRoute<T> extends PageRouteBuilder<T> {
  FadeSlideRoute({required Widget page})
      : super(
          transitionDuration: const Duration(milliseconds: 320),
          reverseTransitionDuration: const Duration(milliseconds: 260),
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved =
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.06),
                  end: Offset.zero,
                ).animate(curved),
                child: child,
              ),
            );
          },
        );
}
