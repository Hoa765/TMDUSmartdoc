import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../shared/widgets/widgets.dart';
import '../home/providers/document_provider.dart';
import '../notebooks/providers/notebook_provider.dart';
import 'providers/chat_provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ChatProvider>().loadHistory();
        context.read<DocumentProvider>().loadDocuments();
        context.read<NotebookProvider>().loadNotebooks();
      }
    });
  }

  void _handleSend(BuildContext context) {
    if (_controller.text.trim().isEmpty) return;
    context.read<ChatProvider>().sendMessage(_controller.text);
    _controller.clear();
    _scrollToBottom();
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: AppMotion.normal,
          curve: AppMotion.curve,
        );
      }
    });
  }

  /// Bottom sheet chọn tài liệu / notebook làm ngữ cảnh hỏi đáp.
  void _showContextPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final docs = context.read<DocumentProvider>().documents;
        final notebooks = context.read<NotebookProvider>().notebooks;
        final chatProvider = context.read<ChatProvider>();

        return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: Row(
                  children: [
                    Text(
                      'Chọn nguồn hỏi đáp',
                      style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    if (chatProvider.activeDocId != null ||
                        chatProvider.activeNotebookId != null)
                      TextButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          chatProvider.clearActiveContext();
                        },
                        icon: const Icon(Icons.clear_rounded, size: 16),
                        label: const Text('Bỏ chọn'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ),
                  ],
                ),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(bottom: 24),
                  children: [
                    // ── Notebooks ────────────────────────────────────────
                    if (notebooks.isNotEmpty) ...[
                      _PickerSectionHeader(
                        icon: Icons.auto_stories_rounded,
                        label: 'Notebooks',
                      ),
                      ...notebooks.map((nb) {
                        final nbColor = nb.flutterColor;
                        final isActive =
                            chatProvider.activeNotebookId == nb.id;
                        return _PickerTile(
                          isActive: isActive,
                          leading: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: nbColor.withValues(alpha: 0.15),
                              borderRadius: AppRadius.control,
                            ),
                            child: Icon(Icons.auto_stories_rounded,
                                size: 18, color: nbColor),
                          ),
                          title: nb.name,
                          subtitle: nb.summary.isNotEmpty
                              ? nb.summary
                              : '${nb.suggestions.length} gợi ý AI',
                          onTap: () {
                            Navigator.pop(ctx);
                            chatProvider.setActiveNotebook(nb.id,
                                notebookName: nb.name);
                          },
                        );
                      }),
                      const SizedBox(height: 8),
                    ],

                    // ── Tài liệu ─────────────────────────────────────────
                    _PickerSectionHeader(
                      icon: Icons.article_outlined,
                      label: 'Tài liệu',
                    ),
                    if (docs.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Text(
                          'Chưa có tài liệu nào. Hãy tải lên trước.',
                          style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textTertiary,
                              ),
                        ),
                      )
                    else
                      ...docs.map((doc) {
                        final isActive = chatProvider.activeDocId == doc.id;
                        return _PickerTile(
                          isActive: isActive,
                          leading: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: (doc.type == 'pdf'
                                      ? AppColors.documentPdf
                                      : AppColors.documentSlide)
                                  .withValues(alpha: 0.12),
                              borderRadius: AppRadius.control,
                            ),
                            child: Icon(
                              doc.type == 'pdf'
                                  ? Icons.picture_as_pdf_rounded
                                  : Icons.slideshow_rounded,
                              size: 18,
                              color: doc.type == 'pdf'
                                  ? AppColors.documentPdf
                                  : AppColors.documentSlide,
                            ),
                          ),
                          title: doc.title,
                          subtitle: '${doc.pageCount} trang · ${doc.date}',
                          onTap: () {
                            Navigator.pop(ctx);
                            chatProvider.setActiveDoc(doc.id,
                                docTitle: doc.title);
                          },
                        );
                      }),
                  ],
                ),
              ),
            ],
          );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final messages = chatProvider.messages;
    final isTyping = chatProvider.isTyping;
    final isLoadingHistory = chatProvider.isLoadingHistory;
    final horizontalPadding = AppBreakpoints.horizontalPadding(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      endDrawer: _buildConversationsDrawer(context),
      appBar: AppBar(
        title: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.primary),
              AppSpacing.hSm,
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'SmartDoc AI',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (chatProvider.activeNotebookName != null)
                      Text(
                        '📚 ${chatProvider.activeNotebookName!}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    else if (chatProvider.activeDocTitle != null)
                      Text(
                        chatProvider.activeDocTitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.surface.withValues(alpha: 0.92),
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history_outlined),
            tooltip: 'Danh sách hội thoại',
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: AppSpacing.md,
                ),
                itemCount: isLoadingHistory
                    ? 3
                    : messages.length + (isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (isLoadingHistory) {
                    return ChatBubbleSkeleton(isUser: index == 1)
                        .appEntrance(delay: AppMotion.stagger(index));
                  }
                  if (index == messages.length && isTyping) {
                    return const TypingIndicator();
                  }
                  final message = messages[index];
                  final String? question = (message.isAi && index > 0 && !messages[index - 1].isAi)
                      ? messages[index - 1].text
                      : null;
                  return (message.isAi
                          ? AIChatBubble(
                              text: message.text,
                              citations: message.citations,
                              question: question,
                            )
                          : UserChatBubble(text: message.text))
                      .appEntrance(delay: AppMotion.stagger(index));
                },
              ),
            ),
            _buildInputArea(context),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final isCompact = AppBreakpoints.isCompact(context);
    final hasContext = chatProvider.activeDocId != null ||
        chatProvider.activeNotebookId != null;

    final contextLabel = chatProvider.activeNotebookName != null
        ? chatProvider.activeNotebookName!
        : chatProvider.activeDocTitle;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? AppSpacing.sm : AppSpacing.md,
        vertical: AppSpacing.sm,
      ).copyWith(
        bottom: AppSpacing.sm + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: AppShadows.up,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Context chip — hiển thị khi đã chọn tài liệu/notebook
              if (hasContext && contextLabel != null) ...[
                GestureDetector(
                  onTap: () => _showContextPicker(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          chatProvider.activeNotebookId != null
                              ? Icons.auto_stories_rounded
                              : Icons.article_outlined,
                          size: 13,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 5),
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth:
                                MediaQuery.of(context).size.width * 0.55,
                          ),
                          child: Text(
                            contextLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        GestureDetector(
                          onTap: () =>
                              context.read<ChatProvider>().clearActiveContext(),
                          child: const Icon(Icons.close_rounded,
                              size: 14, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
              ],

              // Input row
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // "+" button — chọn tài liệu
                  AnimatedContainer(
                    duration: AppMotion.fast,
                    decoration: BoxDecoration(
                      color: hasContext
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : AppColors.surfaceVariant,
                      borderRadius: AppRadius.control,
                      border: Border.all(
                        color: hasContext
                            ? AppColors.primary.withValues(alpha: 0.4)
                            : AppColors.border,
                      ),
                    ),
                    child: IconButton(
                      icon: Icon(
                        hasContext
                            ? Icons.swap_horiz_rounded
                            : Icons.add_rounded,
                        color: hasContext
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        size: 22,
                      ),
                      padding: const EdgeInsets.all(10),
                      constraints: const BoxConstraints(
                          minWidth: 44, minHeight: 44),
                      onPressed: () => _showContextPicker(context),
                    ),
                  ),
                  AppSpacing.hSm,

                  // Text field
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 5,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _handleSend(context),
                      decoration: InputDecoration(
                        hintText: chatProvider.activeNotebookName != null
                            ? 'Hỏi về notebook...'
                            : chatProvider.activeDocTitle != null
                                ? 'Hỏi về tài liệu...'
                                : 'Nhấn + để chọn tài liệu...',
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
                        fillColor: AppColors.surfaceVariant,
                        contentPadding: AppSpacing.inputPadding,
                      ),
                    ),
                  ),
                  AppSpacing.hSm,

                  // Send button
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _controller,
                    builder: (context, value, child) {
                      final hasText = value.text.trim().isNotEmpty;
                      return AnimatedContainer(
                        duration: AppMotion.fast,
                        curve: AppMotion.curve,
                        decoration: BoxDecoration(
                          color: hasText
                              ? AppColors.primary
                              : AppColors.surfaceVariant,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_upward_rounded,
                            color: hasText
                                ? Colors.white
                                : AppColors.textTertiary,
                          ),
                          onPressed:
                              hasText ? () => _handleSend(context) : null,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConversationsDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          AppBar(
            title: const Text('Hội thoại'),
            backgroundColor: AppColors.surface,
            elevation: 0,
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, _) {
                if (chatProvider.isLoadingConversations) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (chatProvider.conversations.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 52,
                            color: AppColors.textTertiary,
                          ),
                          AppSpacing.vMd,
                          Text(
                            'Chưa có hội thoại nào.\nUpload tài liệu để bắt đầu.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                          AppSpacing.vLg,
                          OutlinedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop();
                              context.go('/upload');
                            },
                            icon: const Icon(Icons.upload_file_outlined),
                            label: const Text('Tải tài liệu lên'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () => chatProvider.loadConversations(),
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: chatProvider.conversations.length,
                    separatorBuilder: (_, __) =>
                        Divider(height: 1, color: AppColors.border),
                    itemBuilder: (context, index) {
                      final conv = chatProvider.conversations[index];
                      final isActive = conv.docId == chatProvider.activeDocId;

                      return ListTile(
                        selected: isActive,
                        selectedTileColor:
                            AppColors.primary.withValues(alpha: 0.08),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: (isActive
                                    ? AppColors.primary
                                    : AppColors.textTertiary)
                                .withValues(alpha: 0.1),
                            borderRadius: AppRadius.control,
                          ),
                          child: Icon(
                            Icons.article_outlined,
                            size: 20,
                            color: isActive
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                        ),
                        title: Text(
                          conv.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: isActive
                                ? FontWeight.w600
                                : FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: conv.lastMessage.isNotEmpty
                            ? Text(
                                conv.lastMessage,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: AppColors.textTertiary),
                              )
                            : null,
                        trailing: Text(
                          _formatTime(conv.updatedAt),
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: AppColors.textTertiary,
                                fontSize: 11,
                              ),
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                          context.read<ChatProvider>().setActiveDoc(
                                conv.docId,
                                docTitle: conv.title,
                              );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inHours < 1) return '${diff.inMinutes} phút';
    if (diff.inDays < 1) return '${diff.inHours} giờ';
    if (diff.inDays < 7) return '${diff.inDays} ngày';
    return '${dt.day}/${dt.month}';
  }
}

// ── Picker widgets ─────────────────────────────────────────────────────────────

class _PickerSectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  const _PickerSectionHeader({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
          ),
        ],
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  final Widget leading;
  final String title;
  final String subtitle;
  final bool isActive;
  final VoidCallback onTap;

  const _PickerTile({
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      selected: isActive,
      selectedTileColor: AppColors.primary.withValues(alpha: 0.08),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: leading,
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          color: isActive ? AppColors.primary : AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textTertiary,
            ),
      ),
      trailing: isActive
          ? const Icon(Icons.check_circle_rounded,
              color: AppColors.primary, size: 20)
          : null,
      onTap: onTap,
    );
  }
}
