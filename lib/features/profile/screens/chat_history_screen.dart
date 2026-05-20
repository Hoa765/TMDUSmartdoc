import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants.dart';
import '../../chat/providers/chat_provider.dart';

class ChatHistoryScreen extends StatefulWidget {
  const ChatHistoryScreen({super.key});

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final conversations = chatProvider.conversations;

    // Filter conversations
    final filteredConversations = conversations.where((c) {
      final query = _searchQuery.toLowerCase();
      final title = c.title.toLowerCase();
      final lastMsg = c.lastMessage.toLowerCase();
      return title.contains(query) || lastMsg.contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Nhật ký trò chuyện',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Styled Search input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadius.control,
                  border: Border.all(color: AppColors.border, width: 0.8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.trim();
                    });
                  },
                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm cuộc trò chuyện cũ...',
                    hintStyle: const TextStyle(color: AppColors.textTertiary),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.cancel_rounded, size: 18, color: AppColors.textTertiary),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
            ),

            // Conversations List
            Expanded(
              child: chatProvider.isLoadingConversations
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    )
                  : filteredConversations.isEmpty
                      ? _buildEmptyState(chatProvider)
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
                          itemCount: filteredConversations.length,
                          itemBuilder: (context, index) {
                            final c = filteredConversations[index];
                            return _ChatHistoryCard(
                              conversation: c,
                              onDelete: () => _confirmDelete(context, chatProvider, c.docId),
                              onTap: () {
                                chatProvider.setActiveDoc(c.docId, docTitle: c.title);
                                context.go('/chat');
                              },
                            ).appEntrance(delay: AppMotion.stagger(index));
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ChatProvider chatProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.08),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.accent.withValues(alpha: 0.12), width: 1.5),
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                size: 72,
                color: AppColors.accent.withValues(alpha: 0.6),
              ),
            ),
            AppSpacing.vXl,
            Text(
              _searchQuery.isNotEmpty ? 'Không tìm thấy kết quả' : 'Chưa có nhật ký chat',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
            ),
            AppSpacing.vSm,
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: Text(
                _searchQuery.isNotEmpty
                    ? 'Hãy thử tìm kiếm với tên tài liệu khác hoặc xóa kí tự đang nhập.'
                    : 'Nhật ký trò chuyện sẽ được tự động lưu trữ tại đây khi bạn gửi tin hỏi đáp về các tài liệu học tập của mình.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary, height: 1.5, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, ChatProvider provider, String docId) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xoá lịch sử chat?'),
        content: const Text('Hành động này sẽ xoá vĩnh viễn toàn bộ tin nhắn trong cuộc hội thoại này trên đám mây.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Huỷ', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await provider.deleteConversation(docId);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã xoá hội thoại thành công'),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Xoá', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _ChatHistoryCard extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ChatHistoryCard({
    required this.conversation,
    required this.onTap,
    required this.onDelete,
  });

  String _formatRelativeTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) {
      return 'Vừa xong';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} phút trước';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} giờ trước';
    } else if (diff.inDays == 1) {
      return 'Hôm qua';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeLabel = _formatRelativeTime(conversation.updatedAt);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.card,
          border: Border.all(color: AppColors.border, width: 0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.015),
              blurRadius: 8,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: AppRadius.card,
          child: InkWell(
            onTap: onTap,
            child: Row(
              children: [
                // Premium left decorative colored bar
                Container(
                  width: 4,
                  height: 96,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 14),

                // Conversation Icon circle
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.question_answer_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),

                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                conversation.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Text(
                                timeLabel,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Text(
                            conversation.lastMessage.isNotEmpty
                                ? conversation.lastMessage
                                : 'Chưa có cuộc trò chuyện nào.',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AppColors.textSecondary,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Delete button
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.error),
                  onPressed: onDelete,
                  splashRadius: 20,
                  tooltip: 'Xoá lịch sử chat',
                ),
                const SizedBox(width: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
