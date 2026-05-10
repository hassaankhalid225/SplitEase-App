import 'package:flutter/material.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/session/presentation/screens/create_session_screen.dart';
import '../features/session/presentation/screens/add_items_screen.dart';
import '../features/session/presentation/screens/assign_items_screen.dart';
import '../features/session/presentation/screens/result_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String createSession = '/create-session';
  static const String addItems = '/add-items';
  static const String assignItems = '/assign-items';
  static const String result = '/result';
  static const String onboarding = '/onboarding';

  static Map<String, WidgetBuilder> get routes => {
        home: (context) => const HomeScreen(),
        createSession: (context) => const CreateSessionScreen(),
        addItems: (context) => const AddItemsScreen(),
        assignItems: (context) => const AssignItemsScreen(),
        result: (context) => const ResultScreen(),
        onboarding: (context) => const OnboardingScreen(),
      };

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final WidgetBuilder? builder = routes[settings.name];
    if (builder != null) {
      return PageRouteBuilder(
        settings: settings,
        pageBuilder: (context, animation, secondaryAnimation) => builder(context),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var slideTween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var fadeTween = Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(slideTween),
            child: FadeTransition(
              opacity: animation.drive(fadeTween),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      );
    }
    return MaterialPageRoute(builder: (context) => const HomeScreen());
  }
}
