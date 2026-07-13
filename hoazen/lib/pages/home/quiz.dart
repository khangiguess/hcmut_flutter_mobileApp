// Daily Check-In flow: home card, 4-step question flow with progress, and the completion screen.

import 'package:flutter/material.dart';
import '../../shared/checkin_common.dart';

// Team naming convention wrapper: quizPage is the daily check-in screen.
class quizPage extends StatelessWidget {
  const quizPage({super.key});

  @override
  Widget build(BuildContext context) => const CheckInFlowScreen();
}

// Mint "DAILY CHECK IN" card on the home page that launches the check-in flow.
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

// 4-step check-in flow (mood → energy → feelings → need); pops with 'journal' when "View Journal" is tapped.
class CheckInFlowScreen extends StatefulWidget {
  const CheckInFlowScreen({super.key});

  @override
  State<CheckInFlowScreen> createState() => _CheckInFlowScreenState();
}

class _CheckInFlowScreenState extends State<CheckInFlowScreen> {
  int _step = 0;
  bool _completed = false;
  int? _mood;
  int? _energy;
  final Set<String> _feelings = {};
  int? _need;

  // True when the current step has an answer, enabling the Next/Submit button.
  bool get _stepAnswered => switch (_step) {
        0 => _mood != null,
        1 => _energy != null,
        2 => _feelings.isNotEmpty,
        _ => _need != null,
      };

  // Advances to the next step, or saves today's entry to Firestore on the last step.
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

  // Goes back one step, or exits the flow from the first step.
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
    // Builds the question widget for the current step.
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

// Completion screen shown after submitting a check-in, with return and view-journal actions.
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
                // Returns 'journal' to the caller so it can open the calendar.
                onPressed: () => Navigator.of(context).pop('journal'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
