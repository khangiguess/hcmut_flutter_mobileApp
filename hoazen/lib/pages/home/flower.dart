import 'package:flutter/material.dart';
import '../../shared/checkin_common.dart';
import 'quiz.dart';
import '../journal/calendar.dart';

class FlowerPage extends StatelessWidget {
  const FlowerPage({super.key});

  /// (Phần của Khôi) Mở luồng Daily Check In; nếu người dùng bấm
  /// "View Journal" ở màn Completed thì mở tiếp trang lịch.
  
  
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
          // ------------------------------------------------------------------
          // KHUNG CHỜ: phần bông hoa / lời chào của trang chủ do thành viên
          // khác phụ trách — thay Container placeholder này bằng widget thật.
          // ------------------------------------------------------------------
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

          // ------------------------------------------------------------------
          // (Phần của Khôi) Card DAILY CHECK IN — khung hồng/mint dẫn vào
          // luồng check-in 4 bước trong quiz.dart.
          // ------------------------------------------------------------------
          DailyCheckInCard(onCheckIn: () => _startCheckIn(context)),
        ],
      ),
    );
  }
}
