import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../shared/widgets/widgets.dart';
import 'providers/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleSend() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.sendPasswordReset(email);

    if (success && mounted) {
      setState(() => _emailSent = true);
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
                  Icon(
                    _emailSent ? Icons.mark_email_read_outlined : Icons.lock_reset,
                    size: 48,
                    color: AppColors.primary,
                  ).appScaleIn(),
                  AppSpacing.vLg,
                  Text(
                    _emailSent ? 'Kiểm tra email' : 'Quên mật khẩu',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ).appEntrance(delay: const Duration(milliseconds: 80)),
                  AppSpacing.vXs,
                  Text(
                    _emailSent
                        ? 'Chúng tôi đã gửi link đặt lại mật khẩu đến ${_emailController.text.trim()}. Vui lòng kiểm tra hộp thư (kể cả thư mục spam).'
                        : 'Nhập email của bạn để nhận link đặt lại mật khẩu.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ).appEntrance(delay: const Duration(milliseconds: 140)),
                  AppSpacing.vXxl,

                  if (!_emailSent) ...[
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
                      label: 'Gửi email đặt lại',
                      onPressed: _handleSend,
                      isLoading: authProvider.isLoading,
                      isFullWidth: true,
                    ).appEntrance(delay: const Duration(milliseconds: 260)),
                  ] else ...[
                    CustomButton(
                      label: 'Gửi lại email',
                      onPressed: () => setState(() => _emailSent = false),
                      isFullWidth: true,
                    ).appEntrance(delay: const Duration(milliseconds: 200)),
                  ],

                  AppSpacing.vMd,

                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text('Quay lại đăng nhập'),
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
