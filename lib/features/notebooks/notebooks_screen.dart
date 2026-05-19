import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../shared/widgets/widgets.dart';
import 'providers/notebook_provider.dart';
import '../chat/providers/chat_provider.dart';

class NotebooksScreen extends StatefulWidget {
  const NotebooksScreen({super.key});

  @override
  State<NotebooksScreen> createState() => _NotebooksScreenState();
}

class _NotebooksScreenState extends State<NotebooksScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<NotebookProvider>().loadNotebooks();
    });
  }

  Future<void> _showCreateDialog() async {
    final nameController = TextEditingController();
    String selectedColor = '#6750A4';
    const colors = [
      '#6750A4', '#006874', '#7D5260', '#B1416B',
      '#386A20', '#984716',
    ];

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
          title: const Text('Tạo notebook mới'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Tên notebook...',
                  border: OutlineInputBorder(borderRadius: AppRadius.control),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppRadius.control,
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppRadius.control,
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  contentPadding: AppSpacing.inputPadding,
                ),
              ),
              AppSpacing.vMd,
              Text('Màu sắc', style: Theme.of(ctx).textTheme.labelMedium),
              AppSpacing.vSm,
              Wrap(
                spacing: 10,
                children: colors.map((hex) {
                  final color = _parseColor(hex);
                  final isSelected = hex == selectedColor;
                  return GestureDetector(
                    onTap: () => setModalState(() => selectedColor = hex),
                    child: AnimatedContainer(
                      duration: AppMotion.fast,
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? AppColors.onSurface : Colors.transparent,
                          width: 2.5,
                        ),
                        boxShadow: isSelected ? AppShadows.card : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white, size: 16)
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Huỷ'),
            ),
            FilledButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) return;
                Navigator.of(ctx).pop();
                final nb = await context.read<NotebookProvider>().createNotebook(name, selectedColor);
                if (mounted && nb == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Tạo notebook thất bại'),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: AppRadius.control),
                      margin: const EdgeInsets.all(AppSpacing.md),
                    ),
                  );
                }
              },
              child: const Text('Tạo'),
            ),
          ],
        ),
      ),
    );
    nameController.dispose();
  }

  Future<void> _confirmDelete(Notebook nb) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
        title: const Text('Xoá notebook?'),
        content: Text(
          'Notebook "${nb.name}" sẽ bị xoá. Các tài liệu bên trong vẫn được giữ lại.',
          style: Theme.of(ctx).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Huỷ'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Xoá'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<NotebookProvider>().deleteNotebook(nb.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotebookProvider>();
    final pagePadding = AppBreakpoints.pagePadding(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tạo mới', style: TextStyle(fontWeight: FontWeight.w600)),
      ).appScaleIn(delay: const Duration(milliseconds: 300)),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => provider.refresh(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: pagePadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notebooks',
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ).appEntrance(),
                      AppSpacing.vXs,
                      Text(
                        'Gom nhóm tài liệu và nhận tóm tắt từ AI.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ).appEntrance(delay: const Duration(milliseconds: 60)),
                      AppSpacing.vLg,
                    ],
                  ),
                ),
              ),
              if (provider.isLoading)
                _buildSkeletonGrid(pagePadding)
              else if (provider.notebooks.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyNotebooks(onCreate: _showCreateDialog),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: pagePadding.horizontal / 2,
                  ).copyWith(bottom: AppSpacing.xxl * 2),
                  sliver: SliverLayoutBuilder(
                    builder: (context, constraints) {
                      final cols = AppBreakpoints.documentGridColumns(
                        constraints.crossAxisExtent,
                      );
                      return SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: cols,
                          mainAxisSpacing: AppSpacing.md,
                          crossAxisSpacing: AppSpacing.md,
                          childAspectRatio: 1.05,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _NotebookCard(
                            notebook: provider.notebooks[index],
                            index: index,
                            onDelete: () => _confirmDelete(provider.notebooks[index]),
                            onChat: () {
                              final nb = provider.notebooks[index];
                              context.read<ChatProvider>().setActiveNotebook(
                                nb.id,
                                notebookName: nb.name,
                              );
                              context.go('/chat');
                            },
                          ),
                          childCount: provider.notebooks.length,
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  SliverPadding _buildSkeletonGrid(EdgeInsets pagePadding) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: pagePadding.horizontal / 2),
      sliver: SliverLayoutBuilder(
        builder: (context, constraints) {
          final cols = AppBreakpoints.documentGridColumns(constraints.crossAxisExtent);
          return SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              childAspectRatio: 1.05,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => const DocumentCardSkeleton()
                  .appEntrance(delay: AppMotion.stagger(index)),
              childCount: 4,
            ),
          );
        },
      ),
    );
  }
}

Color _parseColor(String hex) {
  try {
    return Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
  } catch (_) {
    return const Color(0xFF6750A4);
  }
}

// ── Notebook Card ─────────────────────────────────────────────────────────────

class _NotebookCard extends StatelessWidget {
  final Notebook notebook;
  final int index;
  final VoidCallback onDelete;
  final VoidCallback onChat;

  const _NotebookCard({
    required this.notebook,
    required this.index,
    required this.onDelete,
    required this.onChat,
  });

  @override
  Widget build(BuildContext context) {
    final nbColor = notebook.flutterColor;
    final hasSummary = notebook.summary.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.card,
        child: InkWell(
          onTap: onChat,
          borderRadius: AppRadius.card,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Colored header strip
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: nbColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: AppSpacing.cardPaddingCompact,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: nbColor.withValues(alpha: 0.12),
                              borderRadius: AppRadius.control,
                            ),
                            child: Icon(
                              Icons.auto_stories_rounded,
                              size: 18,
                              color: nbColor,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.more_vert, size: 18),
                            color: AppColors.textSecondary,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                            onPressed: () => _showOptions(context),
                          ),
                        ],
                      ),
                      AppSpacing.vSm,
                      Text(
                        notebook.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                      if (hasSummary) ...[
                        AppSpacing.vXs,
                        Expanded(
                          child: Text(
                            notebook.summary,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ] else
                        const Spacer(),
                      if (notebook.suggestions.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Row(
                            children: [
                              Icon(
                                Icons.lightbulb_outline_rounded,
                                size: 13,
                                color: nbColor,
                              ),
                              AppSpacing.hXs,
                              Text(
                                '${notebook.suggestions.length} gợi ý',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: nbColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).appEntrance(delay: AppMotion.stagger(index));
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.chat_bubble_outline_rounded),
              title: const Text('Chat với notebook này'),
              onTap: () {
                Navigator.of(context).pop();
                onChat();
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline_rounded, color: AppColors.error),
              title: Text('Xoá notebook', style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.of(context).pop();
                onDelete();
              },
            ),
            AppSpacing.vSm,
          ],
        ),
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyNotebooks extends StatelessWidget {
  final VoidCallback onCreate;
  const _EmptyNotebooks({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: const BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_stories_rounded,
                size: 48,
                color: AppColors.primary,
              ),
            ).appScaleIn(),
            AppSpacing.vLg,
            Text(
              'Chưa có notebook nào',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ).appEntrance(delay: const Duration(milliseconds: 100)),
            AppSpacing.vSm,
            Text(
              'Tạo notebook để nhóm tài liệu theo chủ đề\nvà nhận tóm tắt thông minh từ AI.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
            ).appEntrance(delay: const Duration(milliseconds: 160)),
            AppSpacing.vXl,
            CustomButton(
              label: 'Tạo notebook đầu tiên',
              onPressed: onCreate,
              icon: Icons.add_rounded,
            ).appEntrance(delay: const Duration(milliseconds: 220)),
          ],
        ),
      ),
    );
  }
}
