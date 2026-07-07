// ============================================================================
// QUIZ PAGE - Daily Check In flow (phần của Khôi)
// Gồm: DailyCheckInCard (khung hồng ở trang chủ), CheckInFlowScreen
// (4 bước câu hỏi + progress) và CheckInCompletedView (màn hoàn thành).
// ============================================================================

import 'package:flutter/material.dart';
import '../../shared/checkin_common.dart';

/// Giữ đúng naming convention của team: quizPage = màn daily check-in.
/// (Thực chất là wrapper của CheckInFlowScreen.)
class quizPage extends StatelessWidget {
  const quizPage({super.key});

  @override
  Widget build(BuildContext context) => const CheckInFlowScreen();
}

/// Card mint "DAILY CHECK IN / How are you today?" + nút hồng Check-in.
/// Được đặt ở trang chủ (flower.dart).
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

/// Luồng Daily Check In 4 bước: mood → energy → feelings → need.
/// Navigator.pop trả về 'journal' nếu người dùng bấm "View Journal".
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

/// Màn "Completed Check In": nền xanh + card trắng với 2 nút.
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
                // Trả 'journal' về nơi mở flow (flower.dart xử lý tiếp).
                onPressed: () => Navigator.of(context).pop('journal'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
