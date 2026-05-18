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
    await authProvider.login(_emailController.text, _passwordController.text);

    if (mounted) {
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
                    'Welcome back',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ).appEntrance(delay: const Duration(milliseconds: 80)),
                  AppSpacing.vXs,
                  Text(
                    'Log in to continue to TDMU SmartDoc',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ).appEntrance(delay: const Duration(milliseconds: 140)),
                  AppSpacing.vXxl,

                  AppCard(
                    padding: AppSpacing.cardPaddingCompact,
                    child: Column(
                      children: [
                        CustomTextField(
                          controller: _emailController,
                          hintText: 'Email address',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        AppSpacing.vMd,
                        CustomTextField(
                          controller: _passwordController,
                          hintText: 'Password',
                          prefixIcon: Icons.lock_outline,
                          isPassword: true,
                        ),
                      ],
                    ),
                  ).appEntrance(delay: const Duration(milliseconds: 200)),

                  AppSpacing.vLg,

                  CustomButton(
                    label: 'Continue',
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
                        "Don't have an account?",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Sign up',
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
                          'OR',
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

                  OutlinedButton(
                    onPressed: _handleGoogleLogin,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 54),
                      backgroundColor: AppColors.surfaceElevated,
                      foregroundColor: AppColors.textPrimary,
                      side: BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.control,
                      ),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.g_mobiledata, size: 32),
                        AppSpacing.hSm,
                        Flexible(
                          child: Text(
                            'Continue with Google',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
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
