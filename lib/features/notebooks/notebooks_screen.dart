import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../shared/widgets/widgets.dart';
import 'providers/notebook_provider.dart';
import '../chat/providers/chat_provider.dart';

// Danh sách icon đại diện cho từng lĩnh vực học thuật
const _nbIcons = <(String, IconData, String)>[
  ('school',     Icons.school_rounded,             'Tổng quát'),
  ('book',       Icons.menu_book_rounded,           'Văn học'),
  ('science',    Icons.science_rounded,             'Khoa học'),
  ('math',       Icons.calculate_rounded,           'Toán'),
  ('economics',  Icons.trending_up_rounded,         'Kinh tế'),
  ('computer',   Icons.computer_rounded,            'Công nghệ'),
  ('medical',    Icons.medical_services_rounded,    'Y tế'),
  ('history',    Icons.history_edu_rounded,         'Lịch sử'),
  ('art',        Icons.palette_rounded,             'Nghệ thuật'),
  ('language',   Icons.translate_rounded,           'Ngoại ngữ'),
  ('law',        Icons.gavel_rounded,               'Pháp luật'),
  ('idea',       Icons.lightbulb_rounded,           'Ý tưởng'),
];

IconData _iconFromKey(String key) =>
    _nbIcons.firstWhere((e) => e.$1 == key, orElse: () => _nbIcons.first).$2;

String _iconLabel(String key) =>
    _nbIcons.firstWhere((e) => e.$1 == key, orElse: () => _nbIcons.first).$3;

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
    String selectedIcon = 'school';
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
          content: SingleChildScrollView(
            child: Column(
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
                  spacing: 12,
                  runSpacing: 12,
                  children: colors.map((hex) {
                    final color = _parseColor(hex);
                    final isSelected = hex == selectedColor;
                    return GestureDetector(
                      onTap: () => setModalState(() => selectedColor = hex),
                      child: AnimatedContainer(
                        duration: AppMotion.fast,
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? AppColors.textPrimary : Colors.transparent,
                            width: 2.5,
                          ),
                          boxShadow: isSelected ? AppShadows.card : null,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white, size: 18)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                AppSpacing.vMd,
                Text('Biểu tượng', style: Theme.of(ctx).textTheme.labelMedium),
                AppSpacing.vSm,
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _nbIcons.map((entry) {
                    final isSelected = entry.$1 == selectedIcon;
                    final accent = _parseColor(selectedColor);
                    return GestureDetector(
                      onTap: () => setModalState(() => selectedIcon = entry.$1),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedContainer(
                            duration: AppMotion.fast,
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: isSelected ? accent : AppColors.surfaceVariant,
                              borderRadius: AppRadius.control,
                              border: Border.all(
                                color: isSelected ? accent : AppColors.border,
                                width: 1.5,
                              ),
                            ),
                            child: Icon(
                              entry.$2,
                              size: 20,
                              color: isSelected ? Colors.white : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            entry.$3,
                            style: TextStyle(
                              fontSize: 9,
                              color: isSelected ? accent : AppColors.textTertiary,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
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
                // Lấy provider & scaffoldMessenger TRƯỚC khi pop (tránh dùng context sau async gap)
                final provider = context.read<NotebookProvider>();
                final messenger = ScaffoldMessenger.of(context);
                Navigator.of(ctx).pop();
                final nb = await provider.createNotebook(
                  name, selectedColor, selectedIcon,
                );
                if (nb == null) {
                  messenger.showSnackBar(
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
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 82),
        child: FloatingActionButton.extended(
          onPressed: _showCreateDialog,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text('Tạo mới', style: TextStyle(fontWeight: FontWeight.w600)),
        ),
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
                            onTap: () {
                              final nb = provider.notebooks[index];
                              context.push('/notebooks/${nb.id}');
                            },
                            onChat: () {
                              final nb = provider.notebooks[index];
                              context.read<ChatProvider>().setActiveNotebook(
                                nb.id,
                                notebookName: nb.name,
                              );
                              // Defer navigation to next frame so notifyListeners()
                              // finishes propagating before the widget tree changes.
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (context.mounted) context.go('/chat');
                              });
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
  final VoidCallback onTap;

  const _NotebookCard({
    required this.notebook,
    required this.index,
    required this.onDelete,
    required this.onChat,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final nbColor = notebook.flutterColor;
    final hasSummary = notebook.summary.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: AppRadius.card,
        border: Border.all(color: nbColor.withValues(alpha: 0.2), width: 1.5),
        boxShadow: AppShadows.card,
      ),
      child: ClipRRect(
        borderRadius: AppRadius.card,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Stack(
              children: [
                // Soft background glow
                Positioned(
                  right: -24,
                  top: -24,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: nbColor.withValues(alpha: 0.06),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: nbColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              _iconFromKey(notebook.icon),
                              size: 26,
                              color: nbColor,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.more_horiz_rounded),
                            color: AppColors.textSecondary,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            onPressed: () => _showOptions(context),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        notebook.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                      if (hasSummary) ...[
                        AppSpacing.vXs,
                        Text(
                          notebook.summary,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ] else ...[
                        AppSpacing.vXs,
                        Text(
                          'Chưa có tài liệu',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textTertiary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                      if (notebook.suggestions.isNotEmpty) ...[
                        AppSpacing.vSm,
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: nbColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.auto_awesome_rounded, size: 12, color: nbColor),
                              const SizedBox(width: 4),
                              Text(
                                '${notebook.suggestions.length} gợi ý AI',
                                style: TextStyle(
                                  color: nbColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).appEntrance(delay: AppMotion.stagger(index));
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
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
              leading: const Icon(Icons.info_outline_rounded),
              title: const Text('Xem chi tiết'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                WidgetsBinding.instance.addPostFrameCallback((_) => onTap());
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat_bubble_outline_rounded),
              title: const Text('Chat với notebook này'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                WidgetsBinding.instance.addPostFrameCallback((_) => onChat());
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline_rounded, color: AppColors.error),
              title: Text('Xoá notebook', style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.of(sheetContext).pop();
                WidgetsBinding.instance.addPostFrameCallback((_) => onDelete());
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
