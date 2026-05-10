import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../session/data/models/item_model.dart';
import '../../../session/data/models/person_model.dart';
import '../../../../core/utils/currency_formatter.dart';
import 'person_chip.dart';

class AssignItemTile extends StatelessWidget {
  final ItemModel item;
  final List<PersonModel> people;
  final String currency;
  final Function(String personId) onToggle;
  final Function(String personId, double share) onLongPress;
  final VoidCallback onAssignEveryone;

  const AssignItemTile({
    super.key,
    required this.item,
    required this.people,
    required this.currency,
    required this.onToggle,
    required this.onLongPress,
    required this.onAssignEveryone,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isNoOneAssigned = item.assignedShares.isEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isNoOneAssigned ? Colors.orangeAccent.withValues(alpha: 0.5) : AppColors.divider,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        CurrencyFormatter.format(item.price, currency: currency),
                        style: AppTypography.bodySmall.copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: onAssignEveryone,
                  icon: const Icon(Icons.group_add_outlined, size: 16),
                  label: const Text('Everyone', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                ),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: people.map((person) {
                final isSelected = item.assignedShares.containsKey(person.id);
                final share = item.assignedShares[person.id] ?? 0.0;
                
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    PersonChip(
                      name: person.name,
                      isSelected: isSelected,
                      onTap: () => onToggle(person.id),
                    ),
                    if (isSelected && share != 1.0)
                      Positioned(
                        right: -4,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'x${share.toStringAsFixed(1)}',
                            style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
          if (isNoOneAssigned)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.orangeAccent.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, size: 14, color: Colors.orangeAccent),
                  SizedBox(width: 8),
                  Text('No one assigned to this item', style: TextStyle(color: Colors.orangeAccent, fontSize: 12)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
