import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/session/presentation/providers/session_provider.dart';
import 'theme/app_theme.dart';
import 'routes.dart';

class SplitEaseApp extends StatelessWidget {
  final bool showOnboarding;
  
  const SplitEaseApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SessionProvider()),
      ],
      child: MaterialApp(
        title: 'SplitEase',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        initialRoute: showOnboarding ? AppRoutes.onboarding : AppRoutes.home,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}
