import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../shared/widgets/widgets.dart';
import 'providers/upload_provider.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  void _startMockUpload() {
    context.read<UploadProvider>().startMockUpload(() {
      _showSuccessAndNavigate();
    });
  }

  void _showSuccessAndNavigate() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Document processed successfully!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.control),
          margin: const EdgeInsets.all(AppSpacing.lg),
        ),
      );
      context.go('/chat');
    }
  }

  void _cancelUpload() {
    context.read<UploadProvider>().cancelUpload();
  }

  @override
  Widget build(BuildContext context) {
    final uploadProvider = context.watch<UploadProvider>();
    final pagePadding = AppBreakpoints.pagePadding(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Upload Material')),
      body: SingleChildScrollView(
        padding: pagePadding,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: AppBreakpoints.isCompact(context) ? 520 : 680,
            ),
            child: AnimatedSwitcher(
              duration: AppMotion.slow,
              switchInCurve: AppMotion.curve,
              switchOutCurve: AppMotion.curve,
              child: uploadProvider.isUploading
                  ? _buildUploadingState(uploadProvider)
                  : _buildIdleState(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIdleState() {
    return Column(
      key: const ValueKey('idle'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Drag and Drop Area
        LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < AppBreakpoints.compact;
            return InkWell(
              onTap: _startMockUpload,
              borderRadius: AppRadius.card,
              child: Container(
                padding: EdgeInsets.all(
                  isCompact ? AppSpacing.xl : AppSpacing.xxl,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: AppRadius.card,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 2,
                  ),
                  boxShadow: AppShadows.card,
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.cloud_upload_outlined,
                        size: 48,
                        color: AppColors.primary,
                      ),
                    ).appScaleIn(),
                    AppSpacing.vLg,
                    Text(
                      'Tap or drag files here',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    AppSpacing.vSm,
                    Text(
                      'Support PDF, PPTX, DOCX up to 50MB',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    AppSpacing.vLg,
                    CustomButton(
                      label: 'Browse Files',
                      onPressed: _startMockUpload,
                      icon: Icons.folder_open,
                      isFullWidth: isCompact,
                    ),
                  ],
                ),
              ),
            );
          },
        ).appEntrance(),

        AppSpacing.vXl,

        Text(
          'Supported Formats',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ).appEntrance(delay: const Duration(milliseconds: 160)),

        AppSpacing.vMd,

        LayoutBuilder(
          builder: (context, constraints) {
            return Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: [
                _buildFormatChip(
                  context,
                  'PDF',
                  Icons.picture_as_pdf,
                  AppColors.documentPdf,
                  constraints.maxWidth,
                ),
                _buildFormatChip(
                  context,
                  'Word',
                  Icons.description,
                  AppColors.primary,
                  constraints.maxWidth,
                ),
                _buildFormatChip(
                  context,
                  'PowerPoint',
                  Icons.slideshow,
                  AppColors.documentSlide,
                  constraints.maxWidth,
                ),
              ],
            );
          },
        ).appEntrance(delay: const Duration(milliseconds: 220)),
      ],
    );
  }

  Widget _buildFormatChip(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    double parentWidth,
  ) {
    final isSingleColumn = parentWidth < 420;
    final width = isSingleColumn
        ? parentWidth
        : (parentWidth - (AppSpacing.md * 2)) / 3;

    return SizedBox(
      width: width,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: isSingleColumn ? AppSpacing.md : AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: AppRadius.card,
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadows.card,
        ),
        child: isSingleColumn
            ? Row(
                children: [
                  Icon(icon, color: color, size: 28),
                  AppSpacing.hMd,
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  Icon(icon, color: color, size: 32),
                  AppSpacing.vSm,
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildUploadingState(UploadProvider provider) {
    return Container(
      key: const ValueKey('uploading'),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          AIProcessingLoader(
            message: provider.progress < 0.7
                ? 'Preparing your document'
                : 'SmartDoc AI is indexing',
            detail: provider.currentStep,
          ),
          AppSpacing.vXl,

          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.documentPdf.withValues(alpha: 0.1),
                  borderRadius: AppRadius.control,
                ),
                child: const Icon(
                  Icons.picture_as_pdf,
                  color: AppColors.documentPdf,
                ),
              ),
              AppSpacing.hMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI_Research_Paper_2026.pdf',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    AppSpacing.vXs,
                    Text(
                      '3.4 MB',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),

          AppSpacing.vXl,

          ClipRRect(
            borderRadius: AppRadius.chip,
            child: Stack(
              children: [
                LinearProgressIndicator(
                  value: provider.progress,
                  minHeight: 10,
                  backgroundColor: AppColors.surfaceVariant,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                ),
                if (provider.progress < 1)
                  const Positioned.fill(
                    child: IgnorePointer(
                      child: Shimmer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(color: Colors.white24),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          AppSpacing.vMd,

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  provider.currentStep,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
              AppSpacing.hMd,
              Text(
                '${(provider.progress * 100).toInt()}%',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),

          AppSpacing.vXl,
          _buildProcessingTimeline(provider.progress),

          AppSpacing.vXxl,

          CustomButton(
            label: 'Cancel Upload',
            onPressed: _cancelUpload,
            variant: ButtonVariant.outline,
            isFullWidth: true,
          ),
        ],
      ),
    ).appEntrance();
  }

  Widget _buildProcessingTimeline(double progress) {
    final steps = [
      (label: 'Upload', threshold: 0.05, icon: Icons.cloud_done_outlined),
      (label: 'Extract', threshold: 0.4, icon: Icons.article_outlined),
      (label: 'Embed', threshold: 0.7, icon: Icons.hub_outlined),
      (label: 'Finalize', threshold: 0.9, icon: Icons.auto_awesome),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 430;
        return Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: steps.map((step) {
            final isDone = progress >= step.threshold;
            final isActive =
                !isDone && progress >= (step.threshold - 0.3).clamp(0, 1);
            final color = isDone || isActive
                ? AppColors.primary
                : AppColors.textTertiary;

            return SizedBox(
              width: isCompact
                  ? constraints.maxWidth
                  : (constraints.maxWidth - AppSpacing.sm * 3) / 4,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: isDone || isActive
                      ? AppColors.primaryContainer
                      : AppColors.surfaceVariant,
                  borderRadius: AppRadius.control,
                  border: Border.all(
                    color: isDone || isActive
                        ? AppColors.primary.withValues(alpha: 0.2)
                        : AppColors.border,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: isCompact
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.center,
                  children: [
                    Icon(step.icon, size: 18, color: color),
                    AppSpacing.hXs,
                    Flexible(
                      child: isActive
                          ? const SkeletonBox(height: 12)
                          : Text(
                              step.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: color,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
