// ============================================================================
// CALENDAR PAGE - Lịch cảm xúc theo tháng (phần của Khôi)
// Bấm vào ngày có check-in → hiển thị journalPage (chi tiết ngày) ngay trong
// tab này để giữ nguyên thanh nav dưới.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../shared/checkin_common.dart';
import 'journal.dart';
import '../home/quiz.dart';

class calendarPage extends StatefulWidget {
  const calendarPage({super.key});

  @override
  State<calendarPage> createState() => _calendarPageState();
}

class _calendarPageState extends State<calendarPage> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime? _selectedDay; // != null → đang xem chi tiết 1 ngày

  void _changeMonth(int delta) {
    setState(() => _month = DateTime(_month.year, _month.month + delta, 1));
  }

  @override
  Widget build(BuildContext context) {
    // Đang xem chi tiết 1 ngày → hiển thị journalPage thay cho lịch.
    if (_selectedDay != null) {
      return journalPage(
        date: _selectedDay!,
        onBack: () => setState(() => _selectedDay = null),
      );
    }

    final today = DateTime.now();
    final todayLabel =
        'Today: ${weekdayName(today)}, ${today.day} ${monthName(today.month)} ${today.year}';

    return Container(
      color: Colors.white,
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
          // Hàng điều hướng tháng: <  July 2026  >
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => _changeMonth(-1),
                icon: const Icon(Icons.chevron_left, size: 30),
              ),
              Text(
                '${monthName(_month.month)} ${_month.year}',
                style:
                    const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
              ),
              IconButton(
                onPressed: () => _changeMonth(1),
                icon: const Icon(Icons.chevron_right, size: 30),
              ),
            ],
          ),
          const SizedBox(height: 25),
          // Hàng tên thứ Mon..Sun.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              children: List.generate(7, (index) {
                final day = DateTime(2024, 1, index + 1); // 1/1/2024 = Monday
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
          // Lưới ngày trong tháng.
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
    );
  }

  void _onDayTap(DateTime day) {
    final entry = CheckInStore.instance.entryFor(day);
    if (entry != null) {
      setState(() => _selectedDay = day);
    } else if (isSameDay(day, DateTime.now())) {
      // Hôm nay chưa check-in → mở luồng check-in luôn.
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const CheckInFlowScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No check-in for this day')),
      );
    }
  }
}

/// Lưới 7 cột các ngày trong tháng. Ngày có check-in hiện mặt cảm xúc SVG;
/// ngày tương lai để trống; hôm nay có viền hồng + gạch chân số ngày.
class MonthCalendarGrid extends StatelessWidget {
  final DateTime month; // ngày 1 của tháng
  final ValueChanged<DateTime> onDayTap;
  const MonthCalendarGrid(
      {super.key, required this.month, required this.onDayTap});

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final firstWeekday = month.weekday;
    final leadingEmpty = firstWeekday - 1; // lịch bắt đầu từ Thứ hai
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
                        color:
                            isToday ? ZenColors.pinkDark : Colors.transparent,
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
