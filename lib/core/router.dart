import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/splash/splash_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/home/home_screen.dart';
import '../features/upload/upload_screen.dart';
import '../features/chat/chat_screen.dart';
import '../features/profile/profile_screen.dart';
import '../shared/widgets/main_scaffold.dart';
import 'constants.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      pageBuilder: (context, state) =>
          buildPageTransition(state, const SplashScreen()),
    ),
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) =>
          buildPageTransition(state, const LoginScreen()),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => MainScaffold(child: child),
      routes: [
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) =>
              buildPageTransition(state, const HomeScreen()),
        ),
        GoRoute(
          path: '/upload',
          pageBuilder: (context, state) =>
              buildPageTransition(state, const UploadScreen()),
        ),
        GoRoute(
          path: '/chat',
          pageBuilder: (context, state) =>
              buildPageTransition(state, const ChatScreen()),
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (context, state) =>
              buildPageTransition(state, const ProfileScreen()),
        ),
      ],
    ),
  ],
);

CustomTransitionPage buildPageTransition(GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: AppMotion.page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurveTween(curve: AppMotion.curve).animate(animation),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 0.04),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: AppMotion.curve)),
          child: child,
        ),
      );
    },
  );
}
