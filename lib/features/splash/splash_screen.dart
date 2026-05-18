import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        context.go('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.auto_awesome,
              size: 80,
              color: Colors.white,
            ).appScaleIn(),
            AppSpacing.vLg,
            Text(
              'TDMU SmartDoc',
              style: Theme.of(
                context,
              ).textTheme.displayMedium?.copyWith(color: Colors.white),
            ).appEntrance(delay: const Duration(milliseconds: 120)),
            AppSpacing.vSm,
            Text(
              'Your AI Learning Assistant',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.white70),
            ).appEntrance(delay: const Duration(milliseconds: 200)),
          ],
        ),
      ),
    );
  }
}
