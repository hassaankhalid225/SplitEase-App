import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../services/auth/app_lock_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AppLockService _lockService = AppLockService();
  bool _lockEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final enabled = await _lockService.isEnabled();
    setState(() => _lockEnabled = enabled);
  }

  Future<void> _toggleLock(bool value) async {
    if (value) {
      final success = await _lockService.authenticate();
      if (success) {
        await _lockService.setEnabled(true);
        setState(() => _lockEnabled = true);
      }
    } else {
      final success = await _lockService.authenticate();
      if (success) {
        await _lockService.setEnabled(false);
        setState(() => _lockEnabled = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          // Text('Security', style: AppTypography.h3),
          // const SizedBox(height: 16),
          // Container(
          //   decoration: BoxDecoration(
          //     color: isDark ? AppColors.surfaceDark : Colors.white,
          //     borderRadius: BorderRadius.circular(20),
          //     boxShadow: [
          //       BoxShadow(
          //         color: Colors.black.withValues(alpha: 0.04),
          //         blurRadius: 10,
          //         offset: const Offset(0, 4),
          //       ),
          //     ],
          //   ),
          //   child: ListTile(
          //     leading: const Icon(Icons.fingerprint, color: AppColors.primary),
          //     title: const Text('App Lock', style: TextStyle(fontWeight: FontWeight.w600)),
          //     subtitle: const Text('Require biometric to open app'),
          //     trailing: Switch.adaptive(
          //       value: _lockEnabled,
          //       activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
          //       activeThumbColor: AppColors.primary,
          //       onChanged: _toggleLock,
          //     ),
          //   ),
          // ),
          // const SizedBox(height: 40),
          Text('About', style: AppTypography.h3),
          const SizedBox(height: 16),
          const ListTile(
            title: Text('Version'),
            trailing: Text('1.0.0'),
          ),
          const ListTile(
            title: Text('Developer'),
            trailing: Text('SplitEase Team'),
          ),
        ],
      ),
    );
  }
}
