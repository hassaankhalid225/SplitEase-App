import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../services/auth/app_lock_service.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final AppLockService _lockService = AppLockService();

  @override
  void initState() {
    super.initState();
    AppLockService.isLockScreenVisible = true;
    _authenticate();
  }

  @override
  void dispose() {
    AppLockService.isLockScreenVisible = false;
    super.dispose();
  }

  Future<void> _authenticate() async {
    final success = await _lockService.authenticate();
    if (success && mounted) {
      AppLockService.isLockScreenVisible = false;
      // Wait for a tiny bit to ensure the lock screen is popped properly without triggering observer
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        Navigator.pop(context); // Pop the lock screen to return to where user was
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_outline, size: 64, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            Text(
              'SplitEase Locked',
              style: AppTypography.h2.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please authenticate to continue',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 48),
            IconButton(
              onPressed: _authenticate,
              icon: const Icon(Icons.fingerprint, size: 64, color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
