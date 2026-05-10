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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  String _activeFilter = 'All'; // All, Today, Week, Month

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<SessionProvider>();

    final filteredSessions = provider.recentSessions.where((s) {
      final matchesSearch = s.name.toLowerCase().contains(_searchQuery.toLowerCase());
      bool matchesFilter = true;
      final now = DateTime.now();
      
      if (_activeFilter == 'Today') {
        matchesFilter = s.createdAt.year == now.year && s.createdAt.month == now.month && s.createdAt.day == now.day;
      } else if (_activeFilter == 'Week') {
        matchesFilter = now.difference(s.createdAt).inDays <= 7;
      } else if (_activeFilter == 'Month') {
        matchesFilter = now.difference(s.createdAt).inDays <= 30;
      }
      
      return matchesSearch && matchesFilter;
    }).toList();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.homeGreeting,
                    style: AppTypography.h1.copyWith(
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
                    icon: const Icon(Icons.settings_outlined, color: AppColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.homeSubtext,
                style: AppTypography.bodyLarge.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              
              // Search Bar
              TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Search sessions...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  filled: true,
                  fillColor: isDark ? AppColors.surfaceDark : AppColors.fieldFill,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
              const SizedBox(height: 16),
              
              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['All', 'Today', 'Week', 'Month'].map((filter) {
                    final isActive = _activeFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text(filter),
                        selected: isActive,
                        onSelected: (v) => setState(() => _activeFilter = filter),
                        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.fieldFill,
                        selectedColor: AppColors.primary.withValues(alpha: 0.2),
                        checkmarkColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: isActive ? AppColors.primary : (isDark ? Colors.white70 : Colors.black87),
                          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
              
              CustomButton(
                text: AppStrings.newSession,
                icon: Icons.add_circle_outline,
                onPressed: () {
                  provider.startNewSession();
                  Navigator.pushNamed(context, AppRoutes.createSession);
                },
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.recentSessions,
                    style: AppTypography.h3.copyWith(
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    ),
                  ),
                  if (filteredSessions.isNotEmpty)
                    Text(
                      '${filteredSessions.length}',
                      style: AppTypography.bodySmall,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredSessions.isEmpty
                        ? EmptyStateWidget(
                            title: _searchQuery.isEmpty && _activeFilter == 'All' ? 'No Sessions' : 'No Results',
                            message: _searchQuery.isEmpty && _activeFilter == 'All' 
                                ? AppStrings.noRecentSessions 
                                : 'No sessions match your search or filter.',
                          )
                        : ListView.builder(
                            itemCount: filteredSessions.length,
                            padding: const EdgeInsets.only(bottom: 24),
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              final session = filteredSessions[index];
                              return SessionCard(
                                session: session,
                                onTap: () {
                                  provider.loadSession(session);
                                  Navigator.pushNamed(context, AppRoutes.result);
                                },
                                onEdit: () {
                                  provider.loadSession(session);
                                  Navigator.pushNamed(context, AppRoutes.createSession);
                                },
                                onDelete: () {
                                  provider.deleteRecentSession(session.id);
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
