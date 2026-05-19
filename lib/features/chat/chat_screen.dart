import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../shared/widgets/widgets.dart';
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
      if (mounted) context.read<ChatProvider>().loadHistory();
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
                    if (chatProvider.activeDocTitle != null)
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
                  return (message.isAi
                          ? AIChatBubble(
                              text: message.text,
                              citations: message.citations,
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

  /// Drawer bên phải — danh sách tất cả hội thoại của user.
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
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
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
                            style: Theme.of(context).textTheme.bodyMedium
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
                                    ?.copyWith(
                                      color: AppColors.textTertiary,
                                    ),
                              )
                            : null,
                        trailing: Text(
                          _formatTime(conv.updatedAt),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
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

  Widget _buildInputArea(BuildContext context) {
    final isCompact = AppBreakpoints.isCompact(context);

    return Container(
      padding: EdgeInsets.all(isCompact ? AppSpacing.sm : AppSpacing.md)
          .copyWith(
            bottom: (isCompact ? AppSpacing.sm : AppSpacing.md) +
                MediaQuery.of(context).padding.bottom,
          ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: AppShadows.up,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  minLines: 1,
                  maxLines: 5,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _handleSend(context),
                  decoration: InputDecoration(
                    hintText: context.watch<ChatProvider>().activeDocId != null
                        ? 'Hỏi về tài liệu...'
                        : 'Chọn tài liệu để bắt đầu...',
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
                        color: hasText ? Colors.white : AppColors.textTertiary,
                      ),
                      onPressed: hasText ? () => _handleSend(context) : null,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
