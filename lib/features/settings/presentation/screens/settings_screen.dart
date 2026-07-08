import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const List<String> _currencies = ['PKR', 'USD', 'EUR', 'GBP', 'INR', 'AED'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = context.watch<SettingsProvider>();
    final cardColor = isDark ? AppColors.surfaceDark : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Appearance', style: AppTypography.h3),
          const SizedBox(height: 16),
          _card(
            cardColor,
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.palette_outlined, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Text(
                        'Theme',
                        style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _ThemeSelector(
                    current: settings.themeMode,
                    onChanged: (mode) => settings.setThemeMode(mode),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          Text('Preferences', style: AppTypography.h3),
          const SizedBox(height: 16),
          _card(
            cardColor,
            ListTile(
              leading: const Icon(Icons.attach_money, color: AppColors.primary),
              title: const Text('Default Currency', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Used when you start a new session'),
              trailing: DropdownButton<String>(
                value: _currencies.contains(settings.defaultCurrency)
                    ? settings.defaultCurrency
                    : _currencies.first,
                underline: const SizedBox.shrink(),
                borderRadius: BorderRadius.circular(16),
                dropdownColor: isDark ? AppColors.surfaceDark : Colors.white,
                items: _currencies
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) settings.setDefaultCurrency(v);
                },
              ),
            ),
          ),
          const SizedBox(height: 32),

          Text('About', style: AppTypography.h3),
          const SizedBox(height: 16),
          _card(
            cardColor,
            const Column(
              children: [
                ListTile(
                  title: Text('Version'),
                  trailing: Text('1.1.0'),
                ),
                ListTile(
                  title: Text('Developer'),
                  trailing: Text('SplitEase Team'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(Color color, Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  final ThemeMode current;
  final ValueChanged<ThemeMode> onChanged;

  const _ThemeSelector({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const options = [
      (ThemeMode.light, 'Light', Icons.light_mode_outlined),
      (ThemeMode.dark, 'Dark', Icons.dark_mode_outlined),
      (ThemeMode.system, 'System', Icons.brightness_auto_outlined),
    ];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: options.map((opt) {
        final selected = current == opt.$1;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(opt.$1),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : (isDark ? Colors.white10 : AppColors.fieldFill),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected ? AppColors.primary : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    opt.$3,
                    size: 22,
                    color: selected
                        ? AppColors.primary
                        : (isDark ? Colors.white70 : AppColors.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    opt.$2,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                      color: selected
                          ? AppColors.primary
                          : (isDark ? Colors.white70 : AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
