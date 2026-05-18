import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants.dart';

enum EmptyStateType { noDocuments, noChatHistory, noInternet, uploadFailed }

class EmptyState extends StatelessWidget {
  final EmptyStateType type;
  final VoidCallback? onAction;

  const EmptyState({super.key, required this.type, this.onAction});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color iconColor;
    String title;
    String description;
    String actionLabel;

    switch (type) {
      case EmptyStateType.noDocuments:
        icon = Icons.find_in_page_outlined;
        iconColor = AppColors.primary;
        title = 'No documents yet';
        description =
            'Upload your first PDF or presentation to start exploring and learning with AI.';
        actionLabel = 'Upload Material';
        break;
      case EmptyStateType.noChatHistory:
        icon = Icons.forum_outlined;
        iconColor = AppColors.secondary;
        title = 'It\'s quiet here';
        description =
            'Select a document and ask your first question to spark a conversation.';
        actionLabel = 'Browse Documents';
        break;
      case EmptyStateType.noInternet:
        icon = Icons.wifi_off_rounded;
        iconColor = AppColors.warning;
        title = 'You\'re offline';
        description =
            'Please check your internet connection to continue learning with AI.';
        actionLabel = 'Try Again';
        break;
      case EmptyStateType.uploadFailed:
        icon = Icons.cloud_off_rounded;
        iconColor = AppColors.error;
        title = 'Upload interrupted';
        description =
            'We couldn\'t process your document. Please make sure it is a supported format.';
        actionLabel = 'Retry Upload';
        break;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
                border: Border.all(
                  color: iconColor.withValues(alpha: 0.15),
                  width: 2,
                ),
              ),
              child:
                  Icon(icon, size: 80, color: iconColor.withValues(alpha: 0.8))
                      .animate(
                        onPlay: (controller) =>
                            controller.repeat(reverse: true),
                      )
                      .moveY(
                        begin: -4,
                        end: 4,
                        duration: 2000.ms,
                        curve: Curves.easeInOutSine,
                      ),
            ).appScaleIn(),

            AppSpacing.vXl,

            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ).appEntrance(delay: const Duration(milliseconds: 160)),

            AppSpacing.vSm,

            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Text(
                description,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ).appEntrance(delay: const Duration(milliseconds: 220)),
            ),

            AppSpacing.vXl,

            if (onAction != null)
              ElevatedButton.icon(
                onPressed: onAction,
                icon: Icon(
                  type == EmptyStateType.noInternet ||
                          type == EmptyStateType.uploadFailed
                      ? Icons.refresh_rounded
                      : Icons.arrow_forward_rounded,
                  size: 18,
                ),
                label: Text(
                  actionLabel,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.lg,
                  ),
                  backgroundColor: iconColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.control,
                  ),
                ),
              ).appEntrance(delay: const Duration(milliseconds: 280)),
          ],
        ),
      ),
    );
  }
}
