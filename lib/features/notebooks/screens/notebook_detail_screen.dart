import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants.dart';
import '../../../shared/widgets/widgets.dart';
import '../providers/notebook_provider.dart';
import '../../home/providers/document_provider.dart';
import '../../chat/providers/chat_provider.dart';

class NotebookDetailScreen extends StatelessWidget {
  final String notebookId;

  const NotebookDetailScreen({
    super.key,
    required this.notebookId,
  });

  IconData _iconFromKey(String key) {
    switch (key) {
      case 'school': return Icons.school_rounded;
      case 'book': return Icons.menu_book_rounded;
      case 'science': return Icons.science_rounded;
      case 'math': return Icons.calculate_rounded;
      case 'economics': return Icons.trending_up_rounded;
      case 'computer': return Icons.computer_rounded;
      case 'medical': return Icons.medical_services_rounded;
      case 'history': return Icons.history_edu_rounded;
      case 'art': return Icons.palette_rounded;
      case 'language': return Icons.translate_rounded;
      case 'law': return Icons.gavel_rounded;
      case 'idea': return Icons.lightbulb_rounded;
      default: return Icons.auto_stories_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final notebookProvider = context.watch<NotebookProvider>();
    final docProvider = context.watch<DocumentProvider>();
    
    // Find the current notebook
    final notebook = notebookProvider.notebooks.firstWhere(
      (nb) => nb.id == notebookId,
      orElse: () => Notebook(
        id: notebookId,
        name: 'Notebook',
        color: '#6750A4',
        updatedAt: DateTime.now(),
      ),
    );

    final nbColor = notebook.flutterColor;
    
    // Filter documents belonging to this notebook
    final notebookDocs = docProvider.documents
        .where((doc) => doc.notebookId == notebookId)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          notebook.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 🔮 Premium Card Header with Ambient Glow
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      nbColor.withValues(alpha: 0.15),
                      nbColor.withValues(alpha: 0.03),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: AppRadius.card,
                  border: Border.all(
                    color: nbColor.withValues(alpha: 0.25),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: nbColor.withValues(alpha: 0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: nbColor.withValues(alpha: 0.2),
                            borderRadius: AppRadius.card,
                          ),
                          child: Icon(
                            _iconFromKey(notebook.icon),
                            color: nbColor,
                            size: 32,
                          ),
                        ),
                        AppSpacing.hMd,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notebook.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              AppSpacing.vXs,
                              Text(
                                '${notebookDocs.length} tài liệu học thuật',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.vLg,
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            label: 'Tải lên thêm',
                            icon: Icons.add_rounded,
                            variant: ButtonVariant.outline,
                            onPressed: () {
                              context.push('/upload?notebook_id=$notebookId');
                            },
                          ),
                        ),
                        AppSpacing.hMd,
                        Expanded(
                          child: CustomButton(
                            label: 'Chat AI',
                            icon: Icons.chat_bubble_outline_rounded,
                            onPressed: () {
                              context.read<ChatProvider>().setActiveNotebook(
                                notebook.id,
                                notebookName: notebook.name,
                              );
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (context.mounted) context.go('/chat');
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ).appEntrance(delay: const Duration(milliseconds: 50)),
              
              AppSpacing.vLg,

              // 📖 AI SUMMARY SECTION
              Text(
                'Tóm tắt AI toàn cảnh',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ).appEntrance(delay: const Duration(milliseconds: 100)),
              AppSpacing.vSm,
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: AppRadius.card,
                  border: Border.all(color: AppColors.border),
                  boxShadow: AppShadows.soft,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          color: AppColors.primary,
                          size: 18,
                        ),
                        AppSpacing.hSm,
                        Text(
                          'AI TỔNG HỢP NỘI DUNG',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.vSm,
                    Text(
                      notebook.summary.isNotEmpty
                          ? notebook.summary
                          : 'Chưa có tóm tắt. Hãy tải lên tài liệu học tập PDF/TXT để AI tự động lập chỉ mục và tóm tắt toàn bộ notebook.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: notebook.summary.isNotEmpty
                            ? AppColors.textPrimary
                            : AppColors.textTertiary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ).appEntrance(delay: const Duration(milliseconds: 150)),

              AppSpacing.vLg,

              // ⚡ SUGGESTION CHIPS SECTION ("Hỏi Ngay")
              if (notebook.suggestions.isNotEmpty) ...[
                Text(
                  'Câu hỏi gợi ý từ AI',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ).appEntrance(delay: const Duration(milliseconds: 200)),
                AppSpacing.vSm,
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: notebook.suggestions.map((suggestion) {
                    return InkWell(
                      onTap: () {
                        final chatProvider = context.read<ChatProvider>();
                        chatProvider.setActiveNotebook(
                          notebook.id,
                          notebookName: notebook.name,
                        );
                        chatProvider.sendMessage(suggestion);
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (context.mounted) context.go('/chat');
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                          boxShadow: AppShadows.soft,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.lightbulb_outline_rounded,
                              size: 16,
                              color: nbColor,
                            ),
                            AppSpacing.hSm,
                            Flexible(
                              child: Text(
                                suggestion,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            AppSpacing.hXs,
                            const Icon(
                              Icons.arrow_forward_rounded,
                              size: 14,
                              color: AppColors.textTertiary,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ).appEntrance(delay: const Duration(milliseconds: 250)),
                AppSpacing.vLg,
              ],

              // 📂 LIST OF DOCUMENTS
              Text(
                'Danh sách tài liệu học tập',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ).appEntrance(delay: const Duration(milliseconds: 300)),
              AppSpacing.vSm,
              
              if (notebookDocs.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: AppRadius.card,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.folder_open_rounded,
                        size: 40,
                        color: AppColors.textTertiary.withValues(alpha: 0.6),
                      ),
                      AppSpacing.vSm,
                      Text(
                        'Chưa có tài liệu nào trong notebook này.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ).appEntrance(delay: const Duration(milliseconds: 350))
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: notebookDocs.length,
                  separatorBuilder: (_, __) => AppSpacing.vSm,
                  itemBuilder: (context, index) {
                    final doc = notebookDocs[index];
                    final isPdf = doc.type == 'pdf';
                    final docColor = isPdf ? AppColors.documentPdf : AppColors.documentSlide;

                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: AppRadius.card,
                        border: Border.all(color: AppColors.border),
                        boxShadow: AppShadows.soft,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: AppRadius.card,
                        child: InkWell(
                          onTap: () {
                            context.read<ChatProvider>().setActiveDoc(doc.id, docTitle: doc.title);
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (context.mounted) context.go('/chat');
                            });
                          },
                          borderRadius: AppRadius.card,
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: docColor.withValues(alpha: 0.12),
                                    borderRadius: AppRadius.control,
                                  ),
                                  child: Icon(
                                    isPdf ? Icons.picture_as_pdf_rounded : Icons.slideshow_rounded,
                                    color: docColor,
                                    size: 20,
                                  ),
                                ),
                                AppSpacing.hMd,
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        doc.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      AppSpacing.vXs,
                                      Text(
                                        '${doc.pageCount} trang · ${doc.date}',
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 14,
                                  color: AppColors.textTertiary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ).appEntrance(delay: AppMotion.stagger(index));
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
