import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/notebooks')) return 1;
    if (location.startsWith('/upload')) return 2;
    if (location.startsWith('/chat')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/notebooks');
        break;
      case 2:
        context.go('/upload');
        break;
      case 3:
        context.go('/chat');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);

    return Scaffold(
      extendBody: true, // Allows content to flow behind floating nav bar
      body: child,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: _buildFloatingNavBar(context, selectedIndex),
        ),
      ),
    );
  }

  Widget _buildFloatingNavBar(BuildContext context, int selectedIndex) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.18),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(5, (index) {
                final isActive = selectedIndex == index;
                return _buildNavItem(context, index, isActive);
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, bool isActive) {
    final List<IconData> activeIcons = [
      Icons.home_rounded,
      Icons.auto_stories_rounded,
      Icons.upload_file_rounded,
      Icons.chat_bubble_rounded,
      Icons.person_rounded,
    ];
    final List<IconData> inactiveIcons = [
      Icons.home_outlined,
      Icons.auto_stories_outlined,
      Icons.upload_file_outlined,
      Icons.chat_bubble_outline_rounded,
      Icons.person_outline_rounded,
    ];
    final List<String> labels = [
      'Trang chủ',
      'Notebooks',
      'Tải lên',
      'Chat',
      'Hồ sơ',
    ];

    final color = isActive ? AppColors.primary : AppColors.textSecondary;

    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(index, context),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: isActive ? 1.15 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isActive ? activeIcons[index] : inactiveIcons[index],
                  color: color,
                  size: 23,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                labels[index],
                style: TextStyle(
                  color: color,
                  fontSize: 9.5,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  letterSpacing: 0.1,
                ),
              ),
              const SizedBox(height: 2),
              // Floating glowing bar indicator below
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isActive ? 12 : 0,
                height: 2.5,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(1.25),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          )
                        ]
                      : [],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
