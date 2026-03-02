import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../router/app_router.dart';

class PremiumModal extends StatelessWidget {
  const PremiumModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
               color: AppColors.accent.withValues(alpha: 0.1),
               shape: BoxShape.circle,
            ),
            child: const Icon(Icons.star_rounded, size: 40, color: AppColors.accent),
          ),
          const SizedBox(height: 24),
          const Text(
            'Go Premium',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5),
          ),
          const SizedBox(height: 8),
          const Text(
            'Unlock unlimited rewrites, exports,\nand offline privacy mode.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 15, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRouter.pricing);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.all(16),
              ),
              child: const Text('VIEW PLANS', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5)),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('NOT NOW', style: TextStyle(color: AppColors.textHint, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
