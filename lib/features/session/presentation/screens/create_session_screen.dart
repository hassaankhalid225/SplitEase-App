import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/routes.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/utils/validators.dart';
import '../providers/session_provider.dart';
import '../widgets/person_chip.dart';

class CreateSessionScreen extends StatefulWidget {
  const CreateSessionScreen({super.key});

  @override
  State<CreateSessionScreen> createState() => _CreateSessionScreenState();
}

class _CreateSessionScreenState extends State<CreateSessionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _personController = TextEditingController();
  String _selectedCurrency = 'PKR';
  bool _isEditMode = false;

  final List<String> _currencies = ['PKR', 'USD', 'EUR', 'GBP', 'INR', 'AED'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<SessionProvider>();
      if (provider.currentSession != null && provider.currentSession!.name.isNotEmpty) {
        setState(() {
          _isEditMode = true;
          _nameController.text = provider.currentSession!.name;
          _selectedCurrency = provider.currentSession!.currency;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _personController.dispose();
    super.dispose();
  }

  void _addPerson() {
    final name = _personController.text.trim();
    if (name.isNotEmpty) {
      context.read<SessionProvider>().addPerson(name);
      _personController.clear();
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      final image = await picker.pickImage(source: source);
      if (image != null && mounted) {
        context.read<SessionProvider>().updateReceiptImage(image.path);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<SessionProvider>();

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
              if (_isEditMode)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  color: AppColors.primary,
                  child: Text(
                    'Editing: ${provider.currentSession?.name}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
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
                      'Step 1 of 3',
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isEditMode ? 'Edit Session ✏️' : 'Start a Session 📝',
                        style: AppTypography.h2.copyWith(
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Give your bill a name and add your group.',
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 32),
                      CustomTextField(
                        label: 'Session Name',
                        hint: 'e.g. Dinner at Savour',
                        controller: _nameController,
                        validator: (v) => Validators.required(v, fieldName: 'Session name'),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Currency',
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : AppColors.fieldFill,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCurrency,
                            isExpanded: true,
                            borderRadius: BorderRadius.circular(16),
                            dropdownColor: isDark ? AppColors.surfaceDark : Colors.white,
                            items: _currencies.map((c) => DropdownMenuItem(
                              value: c,
                              child: Text(c, style: AppTypography.bodyLarge),
                            )).toList(),
                            onChanged: (v) {
                              if (v != null) setState(() => _selectedCurrency = v);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Receipt Photo (Optional)',
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: double.infinity,
                          height: 120,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceDark : AppColors.fieldFill,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              style: provider.currentSession?.receiptImagePath == null ? BorderStyle.solid : BorderStyle.none,
                              width: 1,
                            ),
                          ),
                          child: provider.currentSession?.receiptImagePath != null
                              ? Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Image.file(
                                        File(provider.currentSession!.receiptImagePath!),
                                        width: double.infinity,
                                        height: 120,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: GestureDetector(
                                        onTap: () => provider.updateReceiptImage(null),
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: Colors.black54,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.close, color: Colors.white, size: 16),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.camera_alt_outlined, color: AppColors.primary, size: 32),
                                    const SizedBox(height: 8),
                                    Text('Tap to attach receipt photo', style: AppTypography.bodySmall),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: CustomTextField(
                              label: 'Add People',
                              hint: "Enter person's name",
                              controller: _personController,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            height: 56,
                            width: 56,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: IconButton(
                              onPressed: _addPerson,
                              icon: const Icon(Icons.add, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: provider.currentSession?.people.map((person) => PersonChip(
                          name: person.name,
                          onDeleted: () => provider.removePerson(person.id),
                        )).toList() ?? [],
                      ),
                      if (provider.currentSession?.people.isEmpty ?? true)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'At least 2 people required to split.',
                            style: AppTypography.bodySmall.copyWith(color: Colors.orangeAccent),
                          ),
                        ),
                      const SizedBox(height: 100), // Space for bottom button
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24.0),
        child: CustomButton(
          text: _isEditMode ? 'Update & Continue' : 'Continue',
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              if ((provider.currentSession?.people.length ?? 0) < 2) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please add at least 2 people')),
                );
                return;
              }
              provider.updateSessionInfo(_nameController.text.trim(), _selectedCurrency);
              Navigator.pushNamed(context, AppRoutes.addItems);
            }
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
            title: Text(_isEditMode ? 'Discard Edits?' : 'Discard Changes?'),
            content: Text(_isEditMode ? 'Are you sure you want to discard your edits?' : 'Are you sure you want to exit? You will lose the current session data.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                child: Text(_isEditMode ? 'Discard' : 'Exit', style: const TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ) ??
        false;
  }
}
