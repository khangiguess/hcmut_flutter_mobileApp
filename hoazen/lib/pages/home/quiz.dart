// Daily Check-In flow: home card, 4-step animated question flow with progress, and the completion screen.

import 'package:flutter/material.dart';
import '../../shared/checkin_common.dart';
import 'package:google_fonts/google_fonts.dart';


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
          Text(
            'DAILY CHECK IN',
            style: GoogleFonts.poppins(
              color: ZenColors.textGreen,
              fontSize: 16,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'How are you today?',
            style: GoogleFonts.poppins(
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

// 4-step check-in flow (mood → energy → feelings → need) with slide/fade transitions between steps.
class CheckInFlowScreen extends StatefulWidget {
  const CheckInFlowScreen({super.key});

  @override
  State<CheckInFlowScreen> createState() => _CheckInFlowScreenState();
}

class _CheckInFlowScreenState extends State<CheckInFlowScreen> {
  int _step = 0;
  bool _forward = true;
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
      setState(() {
        _forward = true;
        _step++;
      });
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
      setState(() {
        _forward = false;
        _step--;
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  // Builds the question widget for a given step.
  Widget _question(int step) => switch (step) {
        0 => Column(children: [
            const QuestionTitle('What are you feeling today?'),
            const SizedBox(height: 25),
            MoodSelector(
              selected: _mood,
              onChanged: (v) => setState(() => _mood = v),
            ),
          ]),
        1 => Column(children: [
            const QuestionTitle('How is your energy today?'),
            const SizedBox(height: 25),
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
            const SizedBox(height: 25),
            FeelingSelector(
              selected: _feelings,
              onToggle: (f) => setState(() {
                _feelings.contains(f)
                    ? _feelings.remove(f)
                    : _feelings.add(f);
              }),
            ),
          ]),
        _ => Column(children: [
            const QuestionTitle('What do you need most today?'),
            const SizedBox(height: 25),
            NeedSelector(
              selected: _need,
              onChanged: (v) => setState(() => _need = v),
            ),
          ]),
      };

  @override
  Widget build(BuildContext context) {
    // Cross-fades between the question flow and the completion screen.
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: _completed ? const CheckInCompletedView() : _buildFlow(),
    );
  }

  Widget _buildFlow() {
    return Scaffold(
      key: const ValueKey('flow'),
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
              Text(
                'Daily Check In',
                style: GoogleFonts.lora(
                  fontSize: 36,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              CheckInProgressBar(progress: _step / 4),
              const Spacer(),
              // Slides the question in from the direction of navigation.
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 320),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  final incoming = child.key == ValueKey(_step);
                  final beginX = incoming
                      ? (_forward ? 0.25 : -0.25)
                      : (_forward ? -0.25 : 0.25);
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(beginX, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey(_step),
                  child: _question(_step),
                ),
              ),
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

// Completion screen with a gentle scale-in card and return/view-journal actions.
class CheckInCompletedView extends StatelessWidget {
  const CheckInCompletedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey('completed'),
      backgroundColor: ZenColors.completedGreen,
      body: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.85, end: 1.0),
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeOutBack,
          builder: (context, scale, child) =>
              Transform.scale(scale: scale, child: child),
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
                Text(
                  'Completed\nCheck In',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lora(     // 👈 Replace TextStyle with GoogleFonts\
                  fontSize: 36,
                  fontWeight: FontWeight.w500,
                  ),
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
      ),
    );
  }
}
