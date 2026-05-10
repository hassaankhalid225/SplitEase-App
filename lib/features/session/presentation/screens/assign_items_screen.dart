import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/routes.dart';
import '../../../../core/widgets/custom_button.dart';
import '../providers/session_provider.dart';
import '../widgets/assign_item_tile.dart';

class AssignItemsScreen extends StatelessWidget {
  const AssignItemsScreen({super.key});

  void _showShareDialog(BuildContext context, String itemId, String personId, double currentShare) {
    final controller = TextEditingController(text: currentShare.toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Custom Share'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter a multiplier (e.g. 0.5 for half a share)'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              decoration: const InputDecoration(
                hintText: '1.0',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final share = double.tryParse(controller.text) ?? 1.0;
              context.read<SessionProvider>().updatePersonShare(itemId, personId, share);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<SessionProvider>();
    final session = provider.currentSession;

    if (session == null) return const Scaffold();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _showExitConfirmation(context);
        if (shouldPop && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () async {
                        final shouldPop = await _showExitConfirmation(context);
                        if (shouldPop && context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                      icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                    ),
                    const Spacer(),
                    Text(
                      'Step 3 of 3',
                      style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(flex: 2),
                  ],
                ),
              ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Assign Items 🤝',
                      style: AppTypography.h2.copyWith(
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap person to toggle share. Long press for partial shares.',
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 32),
                    ...session.items.map((item) => AssignItemTile(
                      item: item,
                      people: session.people,
                      currency: session.currency,
                      onToggle: (personId) => provider.togglePersonInItem(item.id, personId),
                      onLongPress: (personId, share) => _showShareDialog(context, item.id, personId, share),
                      onAssignEveryone: () => provider.assignItemToEveryone(item.id),
                    )),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: CustomButton(
          text: 'Calculate Split →',
          onPressed: () {
            bool allAssigned = session.items.every((item) => item.assignedShares.isNotEmpty);
            if (!allAssigned) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please assign everyone to items before calculating')),
              );
              return;
            }
            provider.calculateResult();
            Navigator.pushNamed(context, AppRoutes.result);
          },
        ),
      ),
    ),
  );
}

  Future<bool> _showExitConfirmation(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Discard Changes?'),
            content: const Text('Are you sure you want to exit? You will lose the current session data.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                child: const Text('Exit', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ) ??
        false;
  }
}
