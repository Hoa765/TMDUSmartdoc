import 'package:firebase_auth/firebase_auth.dart';
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
    _navigate();
  }

  Future<void> _navigate() async {
    // Chờ đồng thời: animation tối thiểu 500ms + Firebase khôi phục auth từ cache
    final results = await Future.wait([
      Future.delayed(const Duration(milliseconds: 500)),
      FirebaseAuth.instance.authStateChanges().first,
    ]);
    if (!mounted) return;
    final user = results[1] as User?;
    context.go(user != null ? '/home' : '/login');
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
              'Trợ lý Học tập AI của Bạn',
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
