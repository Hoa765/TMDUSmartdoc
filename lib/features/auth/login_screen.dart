import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../shared/widgets/widgets.dart';
import 'providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      context.go('/home');
    }
  }

  void _handleGoogleLogin() async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signInWithGoogle();

    if (success && mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final pagePadding = AppBreakpoints.pagePadding(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: pagePadding,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: AppBreakpoints.isCompact(context) ? 420 : 460,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    size: 48,
                    color: AppColors.primary,
                  ).appScaleIn(),
                  AppSpacing.vLg,
                  Text(
                    'Chào mừng quay trở lại',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ).appEntrance(delay: const Duration(milliseconds: 80)),
                  AppSpacing.vXs,
                  Text(
                    'Đăng nhập để tiếp tục với TDMU SmartDoc',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ).appEntrance(delay: const Duration(milliseconds: 140)),
                  AppSpacing.vXxl,

                  AppCard(
                    padding: AppSpacing.cardPaddingCompact,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CustomTextField(
                          controller: _emailController,
                          hintText: 'Địa chỉ Email',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (_) => authProvider.clearError(),
                        ),
                        AppSpacing.vMd,
                        CustomTextField(
                          controller: _passwordController,
                          hintText: 'Mật khẩu',
                          prefixIcon: Icons.lock_outline,
                          isPassword: true,
                          onChanged: (_) => authProvider.clearError(),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => context.push('/forgot-password'),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xs,
                                vertical: AppSpacing.xs,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text('Quên mật khẩu?'),
                          ),
                        ),
                        if (authProvider.errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: AppRadius.control,
                            ),
                            child: Text(
                              authProvider.errorMessage!,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.error),
                            ),
                          ),
                          AppSpacing.vXs,
                        ],
                      ],
                    ),
                  ).appEntrance(delay: const Duration(milliseconds: 200)),

                  AppSpacing.vLg,

                  CustomButton(
                    label: 'Đăng nhập',
                    onPressed: _handleLogin,
                    isLoading: authProvider.isLoading,
                    isFullWidth: true,
                  ).appEntrance(delay: const Duration(milliseconds: 260)),

                  AppSpacing.vMd,

                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: [
                      Text(
                        "Chưa có tài khoản?",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () => context.push('/register'),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Đăng ký',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ).appEntrance(delay: const Duration(milliseconds: 320)),

                  AppSpacing.vXl,

                  Row(
                    children: [
                      Expanded(child: Divider(color: AppColors.border)),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        child: Text(
                          'HOẶC',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0,
                              ),
                        ),
                      ),
                      Expanded(child: Divider(color: AppColors.border)),
                    ],
                  ).appEntrance(delay: const Duration(milliseconds: 380)),

                  AppSpacing.vXl,

                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: AppRadius.control,
                      border: Border.all(color: AppColors.border, width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: AppRadius.control,
                      child: InkWell(
                        onTap: _handleGoogleLogin,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.network(
                                'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1024px-Google_%22G%22_logo.svg.png',
                                width: 22,
                                height: 22,
                                errorBuilder: (context, error, stackTrace) => const Icon(
                                  Icons.g_mobiledata,
                                  color: Colors.blue,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Tiếp tục với Google',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                  letterSpacing: 0.1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ).appEntrance(delay: const Duration(milliseconds: 440)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
