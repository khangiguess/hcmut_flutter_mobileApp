// Journal detail page: shows one day's check-in answers, editable in place, plus an editable note.

import 'package:flutter/material.dart';
import '../../shared/checkin_common.dart';
import 'package:google_fonts/google_fonts.dart';


// Detail view for a single day; embedded by calendarPage so the bottom nav stays visible.
class journalPage extends StatefulWidget {
  final DateTime date;
  final VoidCallback onBack;
  const journalPage({super.key, required this.date, required this.onBack});

  @override
  State<journalPage> createState() => _journalPageState();
}

class _journalPageState extends State<journalPage> {
  @override
  Widget build(BuildContext context) {
    final entry = CheckInStore.instance.entryFor(widget.date);
    // Fallback to the calendar when the day has no data.
    if (entry == null) {
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
            Text(
              'Daily Check In',
              style: GoogleFonts.lora(
                fontSize: 36,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 28),
            // Answers of the 4 check-in questions, editable in place and saved on every change.
            const QuestionTitle('How are you feeling today?'),
            const SizedBox(height: 20),
            MoodSelector(
              selected: entry.mood,
              onChanged: (v) => _updateEntry(entry, () => entry.mood = v),
            ),
            const SizedBox(height: 34),
            const QuestionTitle('How is your energy today?'),
            const SizedBox(height: 20),
            EnergySelector(
              selected: entry.energy,
              onChanged: (v) => _updateEntry(entry, () => entry.energy = v),
            ),
            const SizedBox(height: 34),
            const QuestionTitle('What is on your heart?'),
            const SizedBox(height: 4),
            Text('Choose all that applies',
                style: GoogleFonts.poppins(color: ZenColors.textGreen, fontSize: 13)),
            const SizedBox(height: 20),
            FeelingSelector(
              selected: entry.feelings,
              onToggle: (f) => _updateEntry(entry, () {
                entry.feelings.contains(f)
                    ? entry.feelings.remove(f)
                    : entry.feelings.add(f);
              }),
            ),
            const SizedBox(height: 34),
            const QuestionTitle('What do you need most today?'),
            const SizedBox(height: 20),
            NeedSelector(
              selected: entry.need,
              onChanged: (v) => _updateEntry(entry, () => entry.need = v),
            ),
            const SizedBox(height: 40),
            // Note card of the day; tapping it opens the note editor popup directly.
            const QuestionTitle('Write a note for today'),
            const SizedBox(height: 16),
            TapScale(
              onTap: () => _openNoteDialog(entry),
              pressedScale: 0.97,
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 130),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: ZenColors.mintCard,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Text(
                  hasNote ? entry.note : 'Tap to write something…',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    height: 1.5,
                    color: Colors.black.withValues(alpha: hasNote ? 0.55 : 0.35),
                  ),
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

  // Applies an in-place edit to the entry, refreshes the UI and saves it to Firestore.
  void _updateEntry(CheckInEntry entry, VoidCallback change) {
    setState(change);
    CheckInStore.instance.save(entry);
  }

  // Opens the note dialog with a scale/fade popup effect and persists the result to Firestore.
  Future<void> _openNoteDialog(CheckInEntry entry) async {
    final newNote = await showGeneralDialog<String>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Note',
      barrierColor: const Color.fromRGBO(163, 188, 147, 1),
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (_, __, ___) => NoteDialog(initialText: entry.note),
      transitionBuilder: (_, animation, __, child) {
        final curved =
            CurvedAnimation(parent: animation, curve: Curves.easeOutBack);
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.85, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
    );
    if (newNote != null) {
      entry.note = newNote;
      CheckInStore.instance.save(entry);
      setState(() {});
    }
  }
}

// Dialog with a multiline text field for writing or editing the day's note.
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
                Text(
                  'Write a note for today',
                  style: GoogleFonts.lora(
                    fontSize: 18,
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
