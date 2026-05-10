import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/routes.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../providers/session_provider.dart';
import '../widgets/item_card.dart';
import '../widgets/person_chip.dart';

class AddItemsScreen extends StatefulWidget {
  const AddItemsScreen({super.key});

  @override
  State<AddItemsScreen> createState() => _AddItemsScreenState();
}

class _AddItemsScreenState extends State<AddItemsScreen> {
  final _itemFormKey = GlobalKey<FormState>();
  final _taxFormKey = GlobalKey<FormState>();
  final _itemNameController = TextEditingController();
  final _itemPriceController = TextEditingController();
  final _taxController = TextEditingController();
  final _serviceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final provider = context.read<SessionProvider>();
    if (provider.currentSession != null) {
      _taxController.text = provider.currentSession!.taxPercent.toString();
      _serviceController.text = provider.currentSession!.serviceChargePercent.toString();
    }
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _itemPriceController.dispose();
    _taxController.dispose();
    _serviceController.dispose();
    super.dispose();
  }

  void _addItem() {
    if (_itemFormKey.currentState!.validate()) {
      context.read<SessionProvider>().addItem(
            _itemNameController.text.trim(),
            double.parse(_itemPriceController.text.trim()),
          );
      _itemNameController.clear();
      _itemPriceController.clear();
    }
  }

  void _updateTaxes() {
    if (_taxFormKey.currentState!.validate()) {
      final tax = double.tryParse(_taxController.text) ?? 0.0;
      final service = double.tryParse(_serviceController.text) ?? 0.0;
      context.read<SessionProvider>().updateTaxAndService(tax, service);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<SessionProvider>();
    final session = provider.currentSession;

    if (session == null) return const Scaffold();

    double subtotal = session.items.fold(0, (sum, item) => sum + item.price);
    double total = subtotal * (1 + (session.taxPercent + session.serviceChargePercent) / 100);

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
                      'Step 2 of 3',
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
                      'Add Items 🍔',
                      style: AppTypography.h2.copyWith(
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: session.people.map((p) => PersonChip(name: p.name)).toList(),
                    ),
                    const SizedBox(height: 32),
                    Form(
                      key: _itemFormKey,
                      child: Column(
                        children: [
                          CustomTextField(
                            label: 'Item Name',
                            hint: 'e.g. Zinger Burger',
                            controller: _itemNameController,
                            validator: (v) => Validators.required(v, fieldName: 'Item name'),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  label: 'Price (${session.currency})',
                                  hint: '0.00',
                                  controller: _itemPriceController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  validator: (v) => Validators.amount(v),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                height: 56,
                                width: 100,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: TextButton(
                                  onPressed: _addItem,
                                  child: const Text('Add', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Items List',
                          style: AppTypography.h3,
                        ),
                        Text(
                          '${session.items.length} items',
                          style: AppTypography.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (session.items.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text('No items added yet.', style: TextStyle(color: AppColors.textSecondary)),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: session.items.length,
                        itemBuilder: (context, index) {
                          final item = session.items[index];
                          return ItemCard(
                            item: item,
                            currency: session.currency,
                            onDelete: () => provider.removeItem(item.id),
                          );
                        },
                      ),
                    const SizedBox(height: 32),
                    Text(
                      'Taxes & Charges',
                      style: AppTypography.h3,
                    ),
                    const SizedBox(height: 16),
                    Form(
                      key: _taxFormKey,
                      child: Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              label: 'Tax %',
                              hint: '0',
                              controller: _taxController,
                              keyboardType: TextInputType.number,
                              validator: (v) => Validators.percent(v),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextField(
                              label: 'Service %',
                              hint: '0',
                              controller: _serviceController,
                              keyboardType: TextInputType.number,
                              validator: (v) => Validators.percent(v),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _updateTaxes,
                      child: const Text('Update Totals', style: TextStyle(color: AppColors.primary)),
                    ),
                    const SizedBox(height: 120), // Bottom padding
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Bill:', style: AppTypography.bodyLarge),
                Text(
                  CurrencyFormatter.format(total, currency: session.currency),
                  style: AppTypography.h3.copyWith(color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Continue',
              onPressed: () {
                if (session.items.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please add at least one item')),
                  );
                  return;
                }
                _updateTaxes();
                Navigator.pushNamed(context, AppRoutes.assignItems);
              },
            ),
          ],
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
