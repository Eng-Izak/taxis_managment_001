import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'routes.dart';
import '../../features/splash/ui/splash_screen.dart';
import '../../features/auth/ui/login_screen.dart';
import '../../features/home/ui/home_dashboard_screen.dart';
import '../../features/assets_managment/ui/assets_managment_screen.dart';
import '../../features/shareholders/ui/shareholders_screen.dart';
import '../../features/financial_analysis/ui/financial_analysis_screen.dart';
import '../../features/profile/ui/profile_screen.dart';
import '../../features/settings/ui/settings_screen.dart';
import '../../features/security/ui/security_screen.dart';
import '../shared/widgets/custom_bottom_nav_bar.dart';

class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: Routes.splash,
    routes: [
      GoRoute(
        path: Routes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: Routes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: Routes.dashboard,
        builder: (context, state) => const MainShellScreen(),
      ),
      GoRoute(
        path: Routes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: Routes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: Routes.security,
        builder: (context, state) => const SecurityScreen(),
      ),
    ],
  );
}

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  // Index 2 is the centered Home Dashboard tab
  int _currentIndex = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const AssetsManagmentScreen(),
          const ShareholdersScreen(),
          HomeDashboardScreen(
            onNavigateToAssets: () => setState(() => _currentIndex = 0),
            onNavigateToFinancials: () => setState(() => _currentIndex = 3),
          ),
          const FinancialAnalysisScreen(),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
