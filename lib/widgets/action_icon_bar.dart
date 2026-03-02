import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../services/export_service.dart';
import '../router/app_router.dart';
import 'package:flutter/services.dart';

class ActionIconBar extends StatelessWidget {
  const ActionIconBar({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _ActionButton(
            icon: Icons.copy_rounded,
            label: 'COPY',
            onTap: () {
              Clipboard.setData(ClipboardData(text: state.transcription));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied to clipboard'), behavior: SnackBarBehavior.floating),
              );
            },
          ),
          _ActionButton(
            icon: Icons.save_rounded,
            label: 'SAVE',
            onTap: () async {
              await state.saveNote();
              if (context.mounted) {
                 ScaffoldMessenger.of(context).showSnackBar(
                   const SnackBar(content: Text('Saved to History'), behavior: SnackBarBehavior.floating),
                 );
              }
            },
          ),
          _ActionButton(
            icon: Icons.picture_as_pdf_rounded,
            label: 'PDF',
            isPro: true,
            hasPro: state.isPro,
            onTap: () {
              if (state.isPro) {
                ExportService.exportToPdf(state.transcription);
              } else {
                Navigator.pushNamed(context, AppRouter.pricing);
              }
            },
          ),
          _ActionButton(
            icon: Icons.article_rounded,
            label: 'MD',
            isPro: true,
            hasPro: state.isPro,
            onTap: () {
              if (state.isPro) {
                ExportService.exportToMarkdown(state.transcription);
              } else {
                Navigator.pushNamed(context, AppRouter.pricing);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPro;
  final bool hasPro;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPro = false,
    this.hasPro = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, color: Colors.white70, size: 24),
              if (isPro && !hasPro)
                Positioned(
                  top: -8,
                  right: -8,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.star_rounded, size: 10, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
