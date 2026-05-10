import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../session/data/models/person_model.dart';
import '../../../session/data/models/item_model.dart';
import '../../../../core/utils/currency_formatter.dart';
import 'package:url_launcher/url_launcher.dart';

class ResultPersonCard extends StatelessWidget {
  final PersonModel person;
  final double amount;
  final String currency;
  final List<ItemModel> assignedItems;
  final String sessionName;

  const ResultPersonCard({
    super.key,
    required this.person,
    required this.amount,
    required this.currency,
    required this.assignedItems,
    required this.sessionName,
  });

  Future<void> _launchWhatsApp(BuildContext context) async {
    final message = Uri.encodeComponent(
      'Hey ${person.name}! 👋\nYour share for $sessionName is $currency ${amount.toStringAsFixed(2)} 🧾\nPaid via SplitEase'
    );
    final url = Uri.parse('whatsapp://send?text=$message');
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('WhatsApp is not installed')),
        );
      }
    }
  }

  Color _getAvatarColor(String name) {
    final colors = [
      const Color(0xFF6366F1), // Indigo
      const Color(0xFFF43F5E), // Rose
      const Color(0xFF10B981), // Emerald
      const Color(0xFFF59E0B), // Amber
      const Color(0xFF8B5CF6), // Violet
      const Color(0xFF06B6D4), // Cyan
    ];
    return colors[name.hashCode % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final avatarColor = _getAvatarColor(person.name);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: avatarColor.withValues(alpha: 0.1),
                  child: Text(
                    person.name.isNotEmpty ? person.name[0].toUpperCase() : '?',
                    style: AppTypography.h3.copyWith(color: avatarColor),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        person.name,
                        style: AppTypography.h3.copyWith(
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${assignedItems.length} items shared',
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Owes',
                      style: AppTypography.bodySmall,
                    ),
                    Text(
                      CurrencyFormatter.format(amount, currency: currency),
                      style: AppTypography.h3.copyWith(color: AppColors.primary),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () => _launchWhatsApp(context),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0x1A25D366),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.chat, color: Color(0xFF25D366), size: 20),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (assignedItems.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: assignedItems.map((item) {
                  final share = item.assignedShares[person.id] ?? 1.0;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white10 : AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${item.name}${share != 1.0 ? ' (x$share)' : ''}',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
