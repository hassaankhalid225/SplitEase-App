import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/routes.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../providers/session_provider.dart';
import '../widgets/result_person_card.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  void _shareSummary(BuildContext context, SessionProvider provider) {
    final session = provider.currentSession;
    if (session == null) return;

    final result = provider.calculationResult;
    double subtotal = session.items.fold(0, (sum, item) => sum + item.price);
    double total = subtotal * (1 + (session.taxPercent + session.serviceChargePercent) / 100);

    StringBuffer buffer = StringBuffer();
    buffer.writeln('🧾 SplitEase — ${session.name}');
    final tipAmount = subtotal * (provider.tipPercent / 100);
    final finalTotal = total + tipAmount;
    
    buffer.writeln('Total: ${CurrencyFormatter.format(finalTotal, currency: session.currency)}');
    if (provider.tipPercent > 0) {
      buffer.writeln('Included Tip: ${provider.tipPercent}% (${CurrencyFormatter.format(tipAmount, currency: session.currency)})');
    }
    buffer.writeln('─────────────────');

    for (var person in session.people) {
      final amount = result[person.id] ?? 0.0;
      buffer.writeln('${person.name} → ${CurrencyFormatter.format(amount, currency: session.currency)}');
      
      final personItems = session.items.where((i) => i.assignedShares.containsKey(person.id)).toList();
      for (var item in personItems) {
        final share = item.assignedShares[person.id]!;
        buffer.writeln(' • ${item.name} ${share != 1.0 ? '(x$share)' : ''} — ${CurrencyFormatter.format(item.price, currency: session.currency)}');
      }
      
      if (session.taxPercent > 0 || session.serviceChargePercent > 0 || provider.tipPercent > 0) {
        buffer.writeln(' • Tax & Service share included');
      }
      buffer.writeln('─────────────────');
    }

    Share.share(buffer.toString());
  }

  void _viewReceipt(BuildContext context, String path) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: Hero(
              tag: 'receipt_photo',
              child: Image.file(File(path)),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<SessionProvider>();
    final session = provider.currentSession;
    final result = provider.calculationResult;

    if (session == null) return const Scaffold();

    double subtotal = session.items.fold(0, (sum, item) => sum + item.price);
    double total = subtotal * (1 + (session.taxPercent + session.serviceChargePercent + provider.tipPercent) / 100);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                  ),
                  const Spacer(),
                  Text(
                    'The Result',
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Here's the Split 🎉",
                          style: AppTypography.h2.copyWith(
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                          ),
                        ),
                        if (session.receiptImagePath != null)
                          IconButton(
                            onPressed: () => _viewReceipt(context, session.receiptImagePath!),
                            icon: const Hero(
                              tag: 'receipt_photo',
                              child: Icon(Icons.receipt_long, color: AppColors.primary),
                            ),
                            tooltip: 'View Receipt',
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Review the summary below and share with your group.',
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 32),
                    
                    // Session Summary Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
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
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Grand Total', style: TextStyle(color: Colors.white70, fontSize: 14)),
                              Text(
                                CurrencyFormatter.format(total, currency: session.currency),
                                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Divider(color: Colors.white24),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Subtotal: ${CurrencyFormatter.format(subtotal, currency: session.currency)}', 
                                   style: const TextStyle(color: Colors.white70, fontSize: 12)),
                              Text('Tax: ${session.taxPercent}% | Tip: ${provider.tipPercent.toInt()}%', 
                                   style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Tip Slider
                    Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Colors.transparent,
                      ),
                      child: ExpansionTile(
                        title: Text('Add Tip 💰', style: AppTypography.h3),
                        subtitle: Text('Current Tip: ${provider.tipPercent.toInt()}%', style: AppTypography.bodySmall),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                            child: Column(
                              children: [
                                Slider(
                                  value: provider.tipPercent,
                                  min: 0,
                                  max: 30,
                                  divisions: 30,
                                  label: '${provider.tipPercent.toInt()}%',
                                  activeColor: AppColors.primary,
                                  onChanged: (v) => provider.updateTipPercent(v),
                                ),
                                Text(
                                  'Tip Amount: ${CurrencyFormatter.format(subtotal * (provider.tipPercent / 100), currency: session.currency)}',
                                  style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    Text('Individual Breakdown', style: AppTypography.h3),
                    const SizedBox(height: 16),
                    
                    ...session.people.map((person) {
                      final amount = result[person.id] ?? 0.0;
                      final personItems = session.items.where((i) => i.assignedShares.containsKey(person.id)).toList();
                      return ResultPersonCard(
                        person: person,
                        amount: amount,
                        currency: session.currency,
                        assignedItems: personItems,
                        sessionName: session.name,
                      );
                    }),
                    
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomButton(
              text: 'Share Summary',
              icon: Icons.share_outlined,
              onPressed: () => _shareSummary(context, provider),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      await provider.saveCurrentSession();
                      if (context.mounted) {
                        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                      side: const BorderSide(color: AppColors.primary),
                    ),
                    child: const Text('Save & Exit', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      provider.startNewSession();
                      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.createSession, (route) => false);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                      side: const BorderSide(color: AppColors.secondary),
                    ),
                    child: const Text('New Split', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
