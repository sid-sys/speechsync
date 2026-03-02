import 'package:flutter/material.dart';
import '../../models/note_model.dart';
import '../../theme/app_theme.dart';

class NoteDetailScreen extends StatelessWidget {
  final NoteModel note;
  const NoteDetailScreen({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(note.title), foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              note.formattedDate,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 1.0),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white10),
              ),
              child: Text(
                note.content,
                style: const TextStyle(fontSize: 16, height: 1.6, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
            if (note.tone != null) ...[
              const SizedBox(height: 16),
              Chip(
                label: Text('Tone: ${note.tone}'),
                backgroundColor: AppColors.accent.withValues(alpha: 0.2),
                labelStyle: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w900, fontSize: 11),
                side: const BorderSide(color: Colors.white10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
