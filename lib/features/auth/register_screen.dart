import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../shared/widgets/widgets.dart';
import 'providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (email.isEmpty || password.isEmpty) return;

    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu xác nhận không khớp.')),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(email, password, name);

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
                    'Tạo tài khoản',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ).appEntrance(delay: const Duration(milliseconds: 80)),
                  AppSpacing.vXs,
                  Text(
                    'Đăng ký để bắt đầu với TDMU SmartDoc',
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
                          controller: _nameController,
                          hintText: 'Họ và tên',
                          prefixIcon: Icons.person_outline,
                          onChanged: (_) => authProvider.clearError(),
                        ),
                        AppSpacing.vMd,
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
                          hintText: 'Mật khẩu (ít nhất 6 ký tự)',
                          prefixIcon: Icons.lock_outline,
                          isPassword: true,
                          onChanged: (_) => authProvider.clearError(),
                        ),
                        AppSpacing.vMd,
                        CustomTextField(
                          controller: _confirmController,
                          hintText: 'Xác nhận mật khẩu',
                          prefixIcon: Icons.lock_outline,
                          isPassword: true,
                          onChanged: (_) => authProvider.clearError(),
                        ),
                        if (authProvider.errorMessage != null) ...[
                          AppSpacing.vSm,
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
                    label: 'Đăng ký',
                    onPressed: _handleRegister,
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
                        'Đã có tài khoản?',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () => context.pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Đăng nhập',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ).appEntrance(delay: const Duration(milliseconds: 320)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
