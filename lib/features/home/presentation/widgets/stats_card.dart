import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../session/data/models/session_model.dart';
import '../../../../core/utils/currency_formatter.dart';

class StatsCard extends StatelessWidget {
  final List<SessionModel> sessions;
  final String defaultCurrency;

  const StatsCard({
    super.key,
    required this.sessions,
    required this.defaultCurrency,
  });

  double _grandTotal(SessionModel session) {
    final subtotal = session.items.fold(0.0, (sum, item) => sum + item.price);
    return subtotal * (1 + (session.taxPercent + session.serviceChargePercent + session.tipPercent) / 100);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final currencySessions = sessions.where((s) => s.currency == defaultCurrency).toList();

    double totalSpent = 0;
    double monthSpent = 0;
    for (var session in currencySessions) {
      final total = _grandTotal(session);
      totalSpent += total;
      if (session.createdAt.year == now.year && session.createdAt.month == now.month) {
        monthSpent += total;
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.secondary],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.insights_outlined, color: Colors.white70, size: 18),
              const SizedBox(width: 6),
              Text(
                'Your Spending',
                style: AppTypography.bodySmall.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '$defaultCurrency only',
                style: AppTypography.bodySmall.copyWith(color: Colors.white60, fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            CurrencyFormatter.format(totalSpent, currency: defaultCurrency),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  icon: Icons.calendar_month_outlined,
                  label: 'This Month',
                  value: CurrencyFormatter.format(monthSpent, currency: defaultCurrency),
                ),
              ),
              Container(width: 1, height: 32, color: Colors.white24),
              Expanded(
                child: _StatTile(
                  icon: Icons.receipt_long_outlined,
                  label: 'Sessions',
                  value: '${sessions.length}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(width: 8),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.bodySmall.copyWith(color: Colors.white60, fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                value,
                style: AppTypography.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
