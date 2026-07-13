// Home page: flower/greeting section placeholder and the Daily Check-In card.

import 'package:flutter/material.dart';
import '../../shared/checkin_common.dart';
import 'quiz.dart';
import '../journal/calendar.dart';

class FlowerPage extends StatelessWidget {
  const FlowerPage({super.key});

  // Opens the check-in flow, then the journal calendar if "View Journal" was tapped.
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
          // Placeholder for the flower/greeting section owned by another teammate.
          Container(
            width: double.infinity,
            height: 220,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(
                  color: ZenColors.textGreen.withValues(alpha: 0.35),
                  width: 2),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Text(
              'Flower / greeting section\n(chờ code từ thành viên khác)',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: ZenColors.textGreen),
            ),
          ),
          const SizedBox(height: 32),
          // Daily Check-In card leading into the 4-step flow.
          DailyCheckInCard(onCheckIn: () => _startCheckIn(context)),
        ],
      ),
    );
  }
}
