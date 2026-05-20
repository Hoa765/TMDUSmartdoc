import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../auth/providers/auth_provider.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/saved_answers_screen.dart';
import 'screens/chat_history_screen.dart';
import 'screens/help_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final pagePadding = AppBreakpoints.pagePadding(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: const Padding(
          padding: EdgeInsets.only(left: 4),
          child: Text(
            'Hồ sơ học tập',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 24,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: pagePadding.copyWith(top: AppSpacing.sm, bottom: 100), // Reserve space for floating nav bar
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: [
                // Futuristic Glassmorphic Header Card
                _buildHeaderCard(context, authProvider).appEntrance(),
                AppSpacing.vLg,

                // Section Title
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 16,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Không gian cá nhân',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                                letterSpacing: 0.2,
                              ),
                        ),
                      ],
                    ),
                  ),
                ).appEntrance(delay: const Duration(milliseconds: 100)),
                AppSpacing.vMd,

                // Premium action tiles grid
                _buildActionGrid(context).appEntrance(delay: const Duration(milliseconds: 150)),
                AppSpacing.vXl,

                // Highlighted Premium Logout Action Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.error.withValues(alpha: 0.14),
                          AppColors.error.withValues(alpha: 0.04),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.25),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.error.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        onTap: () => _showLogoutDialog(context, authProvider),
                        splashColor: AppColors.error.withValues(alpha: 0.1),
                        highlightColor: AppColors.error.withValues(alpha: 0.05),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.logout_rounded,
                                color: AppColors.error,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Đăng xuất tài khoản',
                                style: TextStyle(
                                  color: AppColors.error,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ).appEntrance(delay: const Duration(milliseconds: 200)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, AuthProvider authProvider) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Layered gradient ambient blobs for modern depth
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.secondary.withValues(alpha: 0.15),
                      AppColors.secondary.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: -40,
              bottom: -40,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.12),
                      AppColors.primary.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),

            // Translucent card overlay containing details
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.88),
                    AppColors.secondary.withValues(alpha: 0.88),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  // Upper right edit button
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.15),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
                        ),
                        child: const Icon(Icons.edit_rounded, color: Colors.white, size: 16),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                        );
                      },
                      tooltip: 'Chỉnh sửa cấu hình',
                    ),
                  ),

                  // Header card content
                  Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Large Cyber-Glowing Avatar preset
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                              );
                            },
                            child: _buildAvatar(authProvider.avatarIndex),
                          ),
                          const SizedBox(width: 20),

                          // Text detail blocks
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        authProvider.userName ?? 'Học viên',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Platinum SmartDoc Pro badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.white30, width: 0.8),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.auto_awesome, color: Colors.amber, size: 10),
                                          SizedBox(width: 3),
                                          Text(
                                            'Pro',
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  authProvider.faculty,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Pill Badge Row
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        authProvider.academicYear,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.white24,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Text(
                                        'SmartDoc AI member',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(String index) {
    final List<Map<String, dynamic>> avatarPresets = [
      {
        'colors': [const Color(0xFF2563EB), const Color(0xFF60A5FA)],
        'icon': Icons.person_rounded,
      },
      {
        'colors': [const Color(0xFF7C3AED), const Color(0xFFC084FC)],
        'icon': Icons.school_rounded,
      },
      {
        'colors': [const Color(0xFF059669), const Color(0xFF34D399)],
        'icon': Icons.science_rounded,
      },
      {
        'colors': [const Color(0xFFDC2626), const Color(0xFFF87171)],
        'icon': Icons.psychology_rounded,
      },
      {
        'colors': [const Color(0xFFD97706), const Color(0xFFFBBF24)],
        'icon': Icons.menu_book_rounded,
      },
      {
        'colors': [const Color(0xFF0891B2), const Color(0xFF22D3EE)],
        'icon': Icons.computer_rounded,
      },
    ];

    int idx = 0;
    try {
      idx = int.parse(index);
    } catch (_) {}
    if (idx < 0 || idx >= avatarPresets.length) {
      idx = 0;
    }

    final preset = avatarPresets[idx];
    final colors = preset['colors'] as List<Color>;
    final icon = preset['icon'] as IconData;

    return Container(
      width: 88,
      height: 88,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Colors.cyanAccent, Colors.purpleAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.cyanAccent.withValues(alpha: 0.25),
            blurRadius: 10,
            spreadRadius: 1,
          )
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(44),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 40,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionGrid(BuildContext context) {
    final List<Map<String, dynamic>> actions = [
      {
        'title': 'Thống kê học tập',
        'subtitle': 'Xem tiến trình học thuật & nhận xét từ AI',
        'icon': Icons.analytics_rounded,
        'gradient': const [Color(0xFF2563EB), Color(0xFF3B82F6)],
        'screen': const StatisticsScreen(),
      },
      {
        'title': 'Câu trả lời đã lưu',
        'subtitle': 'Xem lại, tìm kiếm câu trả lời hữu ích đã lưu',
        'icon': Icons.bookmark_rounded,
        'gradient': const [Color(0xFF7C3AED), Color(0xFF8B5CF6)],
        'screen': const SavedAnswersScreen(),
      },
      {
        'title': 'Lịch sử trò chuyện',
        'subtitle': 'Tiếp tục trò chuyện xoay quanh các tài liệu cũ',
        'icon': Icons.forum_rounded,
        'gradient': const [Color(0xFF06B6D4), Color(0xFF0891B2)],
        'screen': const ChatHistoryScreen(),
      },
      {
        'title': 'Trợ giúp & Hỗ trợ',
        'subtitle': 'Giải đáp thắc mắc, gửi phản hồi ý kiến',
        'icon': Icons.help_center_rounded,
        'gradient': const [Color(0xFFF59E0B), Color(0xFFD97706)],
        'screen': const HelpScreen(),
      },
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final act = actions[index];
        final gradient = act['gradient'] as List<Color>;

        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.3), width: 0.8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.015),
                blurRadius: 12,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => act['screen'] as Widget),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      // Rich modern gradient icon capsule
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: gradient,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: gradient[0].withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            )
                          ],
                        ),
                        child: Icon(
                          act['icon'] as IconData,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Text info
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              act['title'] as String,
                              style: const TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              act['subtitle'] as String,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: AppColors.textSecondary,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.textTertiary,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Đăng xuất?'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng học tập SmartDoc?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Huỷ bỏ', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await authProvider.logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
            child: const Text(
              'Đăng xuất',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
