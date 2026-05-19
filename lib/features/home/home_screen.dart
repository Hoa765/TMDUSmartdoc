import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../shared/widgets/widgets.dart';
import '../../features/chat/providers/chat_provider.dart';
import 'providers/document_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<DocumentProvider>().loadDocuments();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final docProvider = context.watch<DocumentProvider>();
    final docs = docProvider.documents;
    final pagePadding = AppBreakpoints.pagePadding(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/upload'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.cloud_upload_outlined),
        label: const Text(
          'Tải lên',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ).appScaleIn(delay: const Duration(milliseconds: 320)),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => context.read<DocumentProvider>().refresh(),
          child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: pagePadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tài liệu',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.displaySmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              AppSpacing.vXs,
                              Text(
                                'Quản lý và trò chuyện với tài liệu của bạn.',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        AppSpacing.hMd,
                        const CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColors.surface,
                          child: Icon(
                            Icons.person_outline,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ).appEntrance(),
                    AppSpacing.vLg,
                    Container(
                      decoration: BoxDecoration(boxShadow: AppShadows.soft),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => context
                            .read<DocumentProvider>()
                            .setSearchQuery(val),
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm tài liệu...',
                          prefixIcon: const Icon(
                            Icons.search,
                            color: AppColors.textSecondary,
                          ),
                          suffixIcon: docProvider.searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 20),
                                  onPressed: () {
                                    _searchController.clear();
                                    context
                                        .read<DocumentProvider>()
                                        .setSearchQuery('');
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: AppRadius.control,
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: AppRadius.control,
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: AppRadius.control,
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 1.5,
                            ),
                          ),
                          filled: true,
                          fillColor: AppColors.surfaceElevated,
                          contentPadding: AppSpacing.inputPadding,
                        ),
                      ),
                    ).appEntrance(delay: const Duration(milliseconds: 90)),
                    AppSpacing.vLg,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            'Tài liệu gần đây',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        AppSpacing.hMd,
                        Text(
                          'Tổng số: ${docs.length}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColors.textTertiary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ).appEntrance(delay: const Duration(milliseconds: 160)),
                  ],
                ),
              ),
            ),
            if (docProvider.isLoading)
              _buildDocumentSkeletonGrid(pagePadding)
            else if (docs.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  type: EmptyStateType.noDocuments,
                  onAction: () => context.go('/upload'),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: pagePadding.horizontal / 2,
                ).copyWith(bottom: AppSpacing.xxl * 2),
                sliver: SliverLayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.crossAxisExtent;
                    return SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: AppBreakpoints.documentGridColumns(
                          width,
                        ),
                        mainAxisSpacing: AppSpacing.md,
                        crossAxisSpacing: AppSpacing.md,
                        childAspectRatio:
                            AppBreakpoints.documentGridAspectRatio(width),
                      ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final doc = docs[index];
                        return _buildDocumentCard(doc, index);
                      }, childCount: docs.length),
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

  Widget _buildDocumentSkeletonGrid(EdgeInsets pagePadding) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(
        horizontal: pagePadding.horizontal / 2,
      ).copyWith(bottom: AppSpacing.xxl * 2),
      sliver: SliverLayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.crossAxisExtent;
          return SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: AppBreakpoints.documentGridColumns(width),
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              childAspectRatio: AppBreakpoints.documentGridAspectRatio(width),
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => const DocumentCardSkeleton().appEntrance(
                delay: AppMotion.stagger(index),
              ),
              childCount: 6,
            ),
          );
        },
      ),
    );
  }

  Widget _buildDocumentCard(MockDocument doc, int index) {
    IconData icon;
    Color iconColor;

    switch (doc.type) {
      case 'pdf':
        icon = Icons.picture_as_pdf_rounded;
        iconColor = AppColors.documentPdf;
        break;
      case 'ppt':
        icon = Icons.slideshow_rounded;
        iconColor = AppColors.documentSlide;
        break;
      default:
        icon = Icons.description_rounded;
        iconColor = AppColors.primary;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTight = constraints.maxWidth < 180;
        final iconSize = isTight ? 22.0 : 24.0;
        final cardPadding = isTight
            ? const EdgeInsets.all(AppSpacing.sm)
            : AppSpacing.cardPaddingCompact;

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
              onTap: () {
                context.read<ChatProvider>().setActiveDoc(doc.id, docTitle: doc.title);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (context.mounted) context.go('/chat');
                });
              },
              borderRadius: AppRadius.card,
              child: Padding(
                padding: cardPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.all(isTight ? 7 : 8),
                          decoration: BoxDecoration(
                            color: iconColor.withValues(alpha: 0.1),
                            borderRadius: AppRadius.control,
                          ),
                          child: Icon(icon, color: iconColor, size: iconSize),
                        ),
                        Flexible(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              icon: const Icon(Icons.more_vert, size: 20),
                              color: AppColors.textSecondary,
                              onPressed: () {},
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      doc.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                      maxLines: isTight ? 3 : 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    AppSpacing.vSm,
                    Row(
                      children: [
                        Icon(
                          Icons.file_copy_outlined,
                          size: 14,
                          color: AppColors.textTertiary,
                        ),
                        AppSpacing.hXs,
                        Flexible(
                          child: Text(
                            '${doc.pageCount} trang',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.vXs,
                    Text(
                      doc.date,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ).appEntrance(delay: AppMotion.stagger(index));
      },
    );
  }
}
