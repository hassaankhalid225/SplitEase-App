import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/session/presentation/providers/session_provider.dart';
import 'theme/app_theme.dart';
import 'routes.dart';
import '../services/auth/app_lock_service.dart';

class SplitEaseApp extends StatefulWidget {
  final bool showOnboarding;
  final bool startLocked;
  
  const SplitEaseApp({super.key, required this.showOnboarding, required this.startLocked});

  @override
  State<SplitEaseApp> createState() => _SplitEaseAppState();
}

class _SplitEaseAppState extends State<SplitEaseApp> with WidgetsBindingObserver {
  final AppLockService _lockService = AppLockService();
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // if (widget.startLocked) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     _navigatorKey.currentState?.pushNamed(AppRoutes.lock);
    //   });
    // }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    // if (state == AppLifecycleState.resumed) {
    //   if (AppLockService.isAuthenticating || AppLockService.isLockScreenVisible) return;
    //   
    //   final bool lockEnabled = await _lockService.isEnabled();
    //   if (lockEnabled) {
    //     _navigatorKey.currentState?.pushNamed(AppRoutes.lock);
    //   }
    // }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SessionProvider()),
      ],
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        title: 'SplitEase',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        initialRoute: widget.showOnboarding ? AppRoutes.onboarding : AppRoutes.home,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}
