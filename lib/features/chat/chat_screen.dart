import 'dart:async';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ChatProvider>().loadHistory();
      }
    });
  }

  void _handleSend(BuildContext context) {
    if (_controller.text.trim().isEmpty) return;

    context.read<ChatProvider>().sendMessage(_controller.text);
    _controller.clear();
    _scrollToBottom();

    // Scroll again after mock delay
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
      backgroundColor: AppColors.background,
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
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Tạo hội thoại mới',
            onPressed: () => chatProvider.startNewConversation(),
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
                    return ChatBubbleSkeleton(
                      isUser: index == 1,
                    ).appEntrance(delay: AppMotion.stagger(index));
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

  Widget _buildInputArea(BuildContext context) {
    final isCompact = AppBreakpoints.isCompact(context);

    return Container(
      padding: EdgeInsets.all(isCompact ? AppSpacing.sm : AppSpacing.md)
          .copyWith(
            bottom:
                (isCompact ? AppSpacing.sm : AppSpacing.md) +
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
              if (!isCompact) ...[
                IconButton(
                  icon: const Icon(
                    Icons.add_circle_outline,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () {},
                ),
                AppSpacing.hSm,
              ],
              Expanded(
                child: TextField(
                  controller: _controller,
                  minLines: 1,
                  maxLines: 5,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _handleSend(context),
                  decoration: InputDecoration(
                    hintText: 'Hỏi SmartDoc...',
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
