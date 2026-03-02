import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';

class PricingPage extends StatefulWidget {
  const PricingPage({super.key});

  @override
  State<PricingPage> createState() => _PricingPageState();
}

class _PricingPageState extends State<PricingPage> {
  bool _isAnnual = true;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Pricing'), foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'Choose Your Plan',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.0,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Unlock the full power of SpeechSync',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Monthly',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Colors.white)),
                Switch(
                    value: _isAnnual,
                    onChanged: (v) => setState(() => _isAnnual = v),
                    thumbColor: WidgetStateProperty.all(AppColors.accent),
                    trackColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? AppColors.accent.withValues(alpha: 0.5) : null),
                ),
                const Text('Yearly',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Colors.white)),
                const SizedBox(width: 8),
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12)),
                    child: const Text('Save 20%',
                        style: TextStyle(
                            color: AppColors.accent,
                            fontSize: 10,
                            fontWeight: FontWeight.w900))),
              ],
            ),
            const SizedBox(height: 32),
            _PlanCard(
              title: 'Free',
              price: '\$0',
              period: 'forever',
              features: const [
                '3 AI Rewrites / Day',
                'Limited Voice Appends',
                'Basic Storage'
              ],
              isPro: false,
              isSelected: !state.isPro,
            ),
            const SizedBox(height: 20),
            _PlanCard(
              title: 'Pro',
              price: _isAnnual ? '\$4.99' : '\$7.99',
              period: 'per month',
              features: const [
                'Unlimited Rewrites',
                'Unlimited File Uploads',
                'PDF & MD Export',
                'Offline Privacy Mode'
              ],
              isPro: true,
              isSelected: state.isPro,
              onTap: () async {
                await state.togglePro(true);
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final String period;
  final List<String> features;
  final bool isPro;
  final bool isSelected;
  final VoidCallback? onTap;

  const _PlanCard({
    required this.title,
    required this.price,
    required this.period,
    required this.features,
    this.isPro = false,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: isPro ? AppColors.accent : AppColors.surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: isPro ? Colors.white24 : Colors.white10),
          boxShadow: [
            BoxShadow(
                color: isPro
                    ? AppColors.accent.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10))
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Row(
            textBaseline: TextBaseline.alphabetic,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            children: [
              Text(price,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900)),
              const SizedBox(width: 4),
              Text(period,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 13,
                      fontWeight: FontWeight.w700)),
            ],
          ),
          const Divider(height: 32, color: Colors.white12),
          ...features.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(children: [
                Icon(Icons.check_circle_rounded,
                    size: 18, color: isPro ? Colors.white : AppColors.accent),
                const SizedBox(width: 10),
                Text(f,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700))
              ]))),
          const SizedBox(height: 12),
          SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: isSelected ? null : onTap,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: isPro ? Colors.white : AppColors.accent,
                      foregroundColor: isPro ? AppColors.accent : Colors.white,
                      disabledBackgroundColor: Colors.white12,
                      disabledForegroundColor: Colors.white24,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16))),
                  child: Text(isSelected ? 'CURRENT PLAN' : 'SELECT PLAN',
                      style: const TextStyle(
                          fontWeight: FontWeight.w900, fontSize: 12)))),
        ],
      ),
    );
  }
}
