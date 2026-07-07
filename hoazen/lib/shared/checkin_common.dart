// ============================================================================
// SHARED - Dùng chung cho Daily Check-in (quiz.dart) và Journal
// (calendar.dart / journal.dart). Phần của Khôi.
// Gồm: bảng màu, hằng số lựa chọn, model + store dữ liệu, và các widget
// chọn đáp án được tái sử dụng ở nhiều màn hình.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// ---------------------------------------------------------------------------
// Màu + font
// ---------------------------------------------------------------------------

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

// ---------------------------------------------------------------------------
// Các lựa chọn trong daily check-in
// ---------------------------------------------------------------------------

class MoodOption {
  final String label;
  final String asset;
  const MoodOption(this.label, this.asset);
}

/// 5 mức tâm trạng — SVG vector thật nên dùng SvgPicture.
const List<MoodOption> kMoods = [
  MoodOption('Terrible', 'assets/Terrible.svg'), // red
  MoodOption('Sad', 'assets/sad.svg'), // gray
  MoodOption('Normal', 'assets/Normal.svg'), // purple
  MoodOption('Happy', 'assets/Happy.svg'), // green
  MoodOption('Joyful', 'assets/Joyful.svg'), // yellow
];

// LƯU Ý: các icon dưới đây là SVG Figma chứa PNG nhúng (flutter_svg không
// render được) nên dùng bản .png đã tách sẵn trong assets.
const List<MoodOption> kEnergyOptions = [
  MoodOption('Drained', 'assets/Low Battery.png'),
  MoodOption('Tired', 'assets/Napping.png'),
  MoodOption('Steady', 'assets/Lightning Bolt.png'),
  MoodOption('Energised', 'assets/Sparkling.png'),
];

const List<MoodOption> kNeedOptions = [
  MoodOption('Rest/Quiet', 'assets/Crescent Moon.png'),
  MoodOption('Connection', 'assets/Handshake.png'),
  MoodOption('Movement', 'assets/Accompany.png'),
  MoodOption('Energised', 'assets/Thinking Bubble.png'),
];

const List<String> kFeelings = [
  'Anxious', 'Sad', 'Angry', 'Happy',
  'Calm', 'Hopeful', 'Confused', 'Lonely',
  'Certain', 'Confident', 'Excited', 'Let-down',
  'Crushed', 'Envious', 'Content', 'Peaceful',
];

// ---------------------------------------------------------------------------
// Model + Store (in-memory, chờ nối Firestore)
// ---------------------------------------------------------------------------

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
/// TODO(firebase): switch this store to Firestore and keep the rest of the UI
/// unchanged, because the screens already read and write through CheckInStore.
/// Suggested collection: 'users/{uid}/checkins' with document id 'yyyy-MM-dd'.
class CheckInStore extends ChangeNotifier {
  CheckInStore._() {
    _seedMockData();
  }

  static final CheckInStore instance = CheckInStore._();

  final Map<String, CheckInEntry> _entries = {};

  String _key(DateTime d) => '${d.year}-${d.month}-${d.day}';

  CheckInEntry? entryFor(DateTime d) => _entries[_key(d)];

  /// TODO(firebase): replace with Firestore writes, then notifyListeners().
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
        final r = (d * 17 + month.month * 5) % 91;
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

String monthName(int m) => const [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ][m - 1];

// ---------------------------------------------------------------------------
// Widget dùng chung
// ---------------------------------------------------------------------------

/// Nút hồng bo tròn (Check-in, Next, Submit, Add Notes…).
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

/// Tiêu đề câu hỏi serif xanh.
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

/// Thanh progress + dòng "Progress X%".
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

/// Hàng 5 mặt cảm xúc SVG. onChanged = null → read-only (dùng ở journal).
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

/// Hàng 4 ô vuông icon + nhãn (dùng cho câu Energy và câu Need).
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
                // Icon .png (tách từ SVG Figma) — dùng Image.asset.
                Image.asset(options[i].asset, width: 26, height: 26),
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

class EnergySelector extends StatelessWidget {
  final int? selected;
  final ValueChanged<int>? onChanged;
  const EnergySelector({super.key, required this.selected, this.onChanged});

  @override
  Widget build(BuildContext context) => SquareOptionRow(
      options: kEnergyOptions, selected: selected, onChanged: onChanged);
}

class NeedSelector extends StatelessWidget {
  final int? selected;
  final ValueChanged<int>? onChanged;
  const NeedSelector({super.key, required this.selected, this.onChanged});

  @override
  Widget build(BuildContext context) => SquareOptionRow(
      options: kNeedOptions, selected: selected, onChanged: onChanged);
}

/// Lưới chip cảm xúc (chọn nhiều).
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
