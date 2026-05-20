import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants.dart';
import '../../chat/providers/chat_provider.dart';

class SavedAnswersScreen extends StatefulWidget {
  const SavedAnswersScreen({super.key});

  @override
  State<SavedAnswersScreen> createState() => _SavedAnswersScreenState();
}

class _SavedAnswersScreenState extends State<SavedAnswersScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.read<ChatProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Thư viện đã lưu',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Styled Premium Search Bar
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
                      _searchQuery = val.trim().toLowerCase();
                    });
                  },
                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm chủ đề, câu hỏi, tài liệu...',
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

            // Answers List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: chatProvider.getSavedAnswersStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    );
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        'Đã xảy ra lỗi khi tải dữ liệu.',
                        style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
                      ),
                    );
                  }

                  final docs = snapshot.data?.docs ?? [];

                  // Lọc theo searchQuery
                  final filteredDocs = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final question = (data['question'] ?? '').toString().toLowerCase();
                    final answer = (data['answer'] ?? '').toString().toLowerCase();
                    final docTitle = (data['docTitle'] ?? '').toString().toLowerCase();
                    return question.contains(_searchQuery) ||
                        answer.contains(_searchQuery) ||
                        docTitle.contains(_searchQuery);
                  }).toList();

                  if (filteredDocs.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      final doc = filteredDocs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final id = doc.id;
                      final question = data['question'] ?? '';
                      final answer = data['answer'] ?? '';
                      final docTitle = data['docTitle'] ?? 'Hỏi đáp tự do';
                      final savedAt = (data['savedAt'] as Timestamp?)?.toDate();

                      return _SavedAnswerCard(
                        id: id,
                        question: question,
                        answer: answer,
                        docTitle: docTitle,
                        savedAt: savedAt,
                        onDelete: () => _confirmDelete(id),
                      ).appEntrance(delay: AppMotion.stagger(index));
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.secondary.withValues(alpha: 0.12), width: 1.5),
              ),
              child: Icon(
                Icons.collections_bookmark_rounded,
                size: 72,
                color: AppColors.secondary.withValues(alpha: 0.6),
              ),
            ),
            AppSpacing.vXl,
            Text(
              _searchQuery.isNotEmpty ? 'Không có kết quả khớp' : 'Chưa có tài liệu lưu trữ',
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
                    ? 'Vui lòng kiểm tra lại chính tả hoặc thử lại bằng từ khóa khác.'
                    : 'Hãy nhấn biểu tượng bookmark ở mỗi câu trả lời trong khung hội thoại AI để lưu lại những thông tin hữu ích tại đây.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary, height: 1.5, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(String docId) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xoá câu trả lời?'),
        content: const Text('Bạn có chắc chắn muốn xoá câu trả lời này khỏi mục thư viện đã lưu không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Huỷ', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await context.read<ChatProvider>().deleteSavedAnswer(docId);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã xoá câu trả lời thành công'),
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

class _SavedAnswerCard extends StatefulWidget {
  final String id;
  final String question;
  final String answer;
  final String docTitle;
  final DateTime? savedAt;
  final VoidCallback onDelete;

  const _SavedAnswerCard({
    required this.id,
    required this.question,
    required this.answer,
    required this.docTitle,
    required this.savedAt,
    required this.onDelete,
  });

  @override
  State<_SavedAnswerCard> createState() => _SavedAnswerCardState();
}

class _SavedAnswerCardState extends State<_SavedAnswerCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final timeStr = widget.savedAt != null
        ? '${widget.savedAt!.day}/${widget.savedAt!.month}/${widget.savedAt!.year}'
        : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.card,
          border: Border.all(color: AppColors.border, width: 0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: AppRadius.card,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row inside Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 10),
                color: AppColors.surfaceVariant.withValues(alpha: 0.4),
                child: Row(
                  children: [
                    // Dynamic Source Tag Capsule
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.12), width: 0.8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.class_rounded, size: 11, color: AppColors.primary),
                          const SizedBox(width: 4),
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.42),
                            child: Text(
                              widget.docTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10.5,
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Date & Delete action
                    Text(
                      timeStr,
                      style: const TextStyle(fontSize: 11, color: AppColors.textTertiary, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                      onPressed: widget.onDelete,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      splashRadius: 18,
                      tooltip: 'Xoá lưu trữ',
                    ),
                  ],
                ),
              ),

              // Q&A Content area
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question block with customized Q-Tag
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Q',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            widget.question,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: AppColors.textPrimary,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.vLg,

                    // Answer block with custom elevated inner container
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: AppRadius.control,
                        border: Border.all(color: AppColors.border.withValues(alpha: 0.6), width: 0.6),
                      ),
                      child: Text(
                        widget.answer,
                        maxLines: _isExpanded ? null : 3,
                        overflow: _isExpanded ? null : TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: AppColors.textSecondary,
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    AppSpacing.vSm,

                    // Expand / Action bottom row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _isExpanded = !_isExpanded;
                            });
                          },
                          icon: Icon(
                            _isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          label: Text(
                            _isExpanded ? 'Thu gọn câu trả lời' : 'Xem toàn bộ câu trả lời',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy_all_rounded, size: 17, color: AppColors.textSecondary),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: 'Hỏi: ${widget.question}\nTrả lời: ${widget.answer}'));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đã sao chép nội dung vào Clipboard'),
                                duration: Duration(milliseconds: 1500),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          tooltip: 'Sao chép nhanh',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
