import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../app/routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../session/presentation/providers/session_provider.dart';
import '../widgets/session_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Text(
                AppStrings.homeGreeting,
                style: AppTypography.h1.copyWith(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.homeSubtext,
                style: AppTypography.bodyLarge.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 40),
              CustomButton(
                text: AppStrings.newSession,
                icon: Icons.add_circle_outline,
                onPressed: () {
                  context.read<SessionProvider>().startNewSession();
                  Navigator.pushNamed(context, AppRoutes.createSession);
                },
              ),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.recentSessions,
                    style: AppTypography.h3.copyWith(
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    ),
                  ),
                  if (context.watch<SessionProvider>().recentSessions.isNotEmpty)
                    Text(
                      '${context.watch<SessionProvider>().recentSessions.length}',
                      style: AppTypography.bodySmall,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Consumer<SessionProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (provider.recentSessions.isEmpty) {
                      return const EmptyStateWidget(
                        title: 'No Sessions',
                        message: AppStrings.noRecentSessions,
                      );
                    }
                    return ListView.builder(
                      itemCount: provider.recentSessions.length,
                      padding: const EdgeInsets.only(bottom: 24),
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        final session = provider.recentSessions[index];
                        return SessionCard(
                          session: session,
                          onTap: () {
                            provider.loadSession(session);
                            Navigator.pushNamed(context, AppRoutes.result);
                          },
                          onDelete: () {
                            provider.deleteRecentSession(session.id);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
