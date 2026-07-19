// Calendar page: monthly mood calendar; tapping a checked-in day opens its journal detail inline with a fade/slide transition.

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../shared/checkin_common.dart';
import 'journal.dart';
import '../home/quiz.dart';
import 'package:google_fonts/google_fonts.dart';


class calendarPage extends StatefulWidget {
  const calendarPage({super.key});

  @override
  State<calendarPage> createState() => _calendarPageState();
}

class _calendarPageState extends State<calendarPage> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime? _selectedDay;

  // Moves the visible month backward or forward.
  void _changeMonth(int delta) {
    setState(() => _month = DateTime(_month.year, _month.month + delta, 1));
  }

  @override
  Widget build(BuildContext context) {
    // Animates between the calendar and the journal detail of the selected day.
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.04),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
      child: _selectedDay != null
          ? journalPage(
              key: ValueKey('journal-${_selectedDay!}'),
              date: _selectedDay!,
              onBack: () => setState(() => _selectedDay = null),
            )
          : _buildCalendar(),
    );
  }

  Widget _buildCalendar() {
    final today = DateTime.now();
    final todayLabel =
        'Today: ${weekdayName(today)}, ${today.day} ${monthName(today.month)} ${today.year}';

    return Container(
      key: const ValueKey('calendar'),
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        children: [
          Text(
            todayLabel,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: ZenColors.textGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          // Month navigation row: previous / current month / next.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => _changeMonth(-1),
                icon: const Icon(Icons.chevron_left, size: 30),
              ),
              // Fades the month title when navigating between months.
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Text(
                  '${monthName(_month.month)} ${_month.year}',
                  key: ValueKey('${_month.month}-${_month.year}'),
                  style: GoogleFonts.lora(
                      fontSize: 28, fontWeight: FontWeight.w800),
                ),
              ),
              IconButton(
                onPressed: () => _changeMonth(1),
                icon: const Icon(Icons.chevron_right, size: 30),
              ),
            ],
          ),
          const SizedBox(height: 25),
          // Weekday header row (Mon..Sun).
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              children: List.generate(7, (index) {
                final day = DateTime(2024, 1, index + 1);
                return Expanded(
                  child: Center(
                    child: Text(
                      weekdayShortName(day),
                      style: GoogleFonts.poppins(
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
          // Day grid that rebuilds whenever the Firestore-backed store changes.
          Expanded(
            child: ListenableBuilder(
              listenable: CheckInStore.instance,
              builder: (context, _) => AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: MonthCalendarGrid(
                  key: ValueKey('grid-${_month.month}-${_month.year}'),
                  month: _month,
                  onDayTap: _onDayTap,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Opens the day's journal, starts today's check-in, or shows a notice for empty past days.
  void _onDayTap(DateTime day) {
    final entry = CheckInStore.instance.entryFor(day);
    if (entry != null) {
      setState(() => _selectedDay = day);
    } else if (isSameDay(day, DateTime.now())) {
      Navigator.of(context).push(
        FadeSlideRoute(page: const CheckInFlowScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No check-in for this day')),
      );
    }
  }
}

// 7-column month grid: mood face for checked-in days, blank for future days, pink highlight for today.
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

        // Each tappable day cell shrinks slightly on press for tactile feedback.
        return TapScale(
          onTap: isFuture ? null : () => onDayTap(date),
          pressedScale: 0.85,
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
                      style: GoogleFonts.poppins(
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
