import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../shared/widgets/widgets.dart';
import '../auth/providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final pagePadding = AppBreakpoints.pagePadding(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: pagePadding,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 48,
                  backgroundColor: AppColors.primaryLight,
                  child: Icon(Icons.person, size: 48, color: Colors.white),
                ).appScaleIn(),
                AppSpacing.vLg,
                Text(
                  authProvider.userName ?? 'Khách',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.displaySmall,
                ).appEntrance(delay: const Duration(milliseconds: 80)),
                AppSpacing.vXs,
                Text(
                  'Khoa học Máy tính - Năm 3',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ).appEntrance(delay: const Duration(milliseconds: 120)),
                AppSpacing.vXxl,
                AppCard(
                  padding: AppSpacing.cardPaddingCompact,
                  child: Column(
                    children: [
                      _buildProfileItem(
                        Icons.analytics_outlined,
                        'Thống kê học tập',
                      ),
                      const Divider(height: 32),
                      _buildProfileItem(
                        Icons.bookmark_outline,
                        'Câu trả lời đã lưu',
                      ),
                      const Divider(height: 32),
                      _buildProfileItem(Icons.history, 'Lịch sử trò chuyện'),
                      const Divider(height: 32),
                      _buildProfileItem(Icons.help_outline, 'Trợ giúp & Hỗ trợ'),
                    ],
                  ),
                ).appEntrance(delay: const Duration(milliseconds: 180)),
                AppSpacing.vXxl,
                CustomButton(
                  label: 'Đăng xuất',
                  icon: Icons.logout,
                  variant: ButtonVariant.outline,
                  isFullWidth: true,
                  onPressed: () async {
                    await authProvider.logout();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                ).appEntrance(delay: const Duration(milliseconds: 240)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textSecondary),
        AppSpacing.hMd,
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        AppSpacing.hMd,
        const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      ],
    );
  }
}
