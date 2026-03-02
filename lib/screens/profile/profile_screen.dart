import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          children: [
            const SizedBox(height: 48),
            const Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.surface,
                    child: Icon(Icons.person_rounded, size: 50, color: Colors.white70),
                  ),
                  SizedBox(height: 16),
                  Text('User Name', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text('Basic Account', style: TextStyle(color: Colors.white54)),
                ],
              ),
            ),
            const SizedBox(height: 48),
            _SectionHeader(title: 'PREFERENCES'),
            const _SettingTile(icon: Icons.palette, title: 'Theme', trailing: Text('Monochrome', style: TextStyle(color: AppColors.textSecondary))),
            _SectionHeader(title: 'SUBSCRIPTION'),
            _SubscriptionCard(state: state),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white24, letterSpacing: 2)),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon; final String title; final Widget trailing;
  const _SettingTile({required this.icon, required this.title, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.white70),
      title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      trailing: trailing,
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  final AppState state;
  const _SubscriptionCard({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.diamond_rounded, color: Colors.amberAccent),
              const SizedBox(width: 8),
              const Text('PRO PLAN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              if (state.isPro) ...[
                const Spacer(),
                const Icon(Icons.check_circle, color: Colors.greenAccent),
              ],
            ],
          ),
          const SizedBox(height: 12),
          const Text('Unlock all features including unlimited translations.', style: TextStyle(color: Colors.white54, fontSize: 13)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => state.togglePro(!state.isPro),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(state.isPro ? 'MANAGE' : 'UPGRADE NOW'),
            ),
          ),
        ],
      ),
    );
  }
}
