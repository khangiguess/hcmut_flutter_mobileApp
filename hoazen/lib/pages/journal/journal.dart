// ============================================================================
// JOURNAL PAGE - Chi tiết check-in của 1 ngày + ghi chú (phần của Khôi)
// Được calendarPage nhúng vào khi người dùng bấm 1 ngày trên lịch
// (giữ nguyên thanh nav dưới). Bấm chevron trái để quay lại lịch.
// ============================================================================

import 'package:flutter/material.dart';
import '../../shared/checkin_common.dart';

/// Giữ naming convention của team: journalPage = màn nhật ký chi tiết 1 ngày.
class journalPage extends StatefulWidget {
  final DateTime date;
  final VoidCallback onBack; // quay lại lịch
  const journalPage({super.key, required this.date, required this.onBack});

  @override
  State<journalPage> createState() => _journalPageState();
}

class _journalPageState extends State<journalPage> {
  @override
  Widget build(BuildContext context) {
    final entry = CheckInStore.instance.entryFor(widget.date);
    if (entry == null) {
      // Phòng hờ: không có dữ liệu thì quay về lịch.
      return Center(
        child: TextButton(onPressed: widget.onBack, child: const Text('Back')),
      );
    }

    final hasNote = entry.note.trim().isNotEmpty;

    return Container(
      color: Colors.white,
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

            // --- Câu 1: mood ---
            const QuestionTitle('How are you today?'),
            const SizedBox(height: 14),
            MoodSelector(selected: entry.mood), // onChanged null = read-only
            const SizedBox(height: 34),

            // --- Câu 2: energy ---
            const QuestionTitle('How is your energy today?'),
            const SizedBox(height: 14),
            EnergySelector(selected: entry.energy),
            const SizedBox(height: 34),

            // --- Câu 3: feelings ---
            const QuestionTitle('What is on your heart?'),
            const SizedBox(height: 4),
            const Text('Choose all that applies',
                style: TextStyle(color: ZenColors.textGreen, fontSize: 13)),
            const SizedBox(height: 14),
            FeelingSelector(selected: entry.feelings),
            const SizedBox(height: 34),

            // --- Câu 4: need ---
            const QuestionTitle('What do you need most today?'),
            const SizedBox(height: 14),
            NeedSelector(selected: entry.need),
            const SizedBox(height: 40),

            // --- Ghi chú của ngày ---
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
    );
  }

  /// Mở hộp thoại viết/sửa ghi chú.
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

/// Hộp thoại "Write a note for today": ô nhập nhiều dòng + nút Add Notes.
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
                  borderSide:
                      const BorderSide(color: ZenColors.textGreen, width: 1.5),
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
