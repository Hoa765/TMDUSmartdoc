import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../features/chat/providers/chat_provider.dart';
import 'citation_chip.dart';
import 'skeleton_widgets.dart';

class CitationData {
  final String label;
  final String value;
  final String snippet;
  final String filename;

  CitationData(
    this.label,
    this.value, {
    this.snippet = '',
    this.filename = '',
  });
}

class AIChatBubble extends StatelessWidget {
  final String text;
  final List<CitationData> citations;
  final String? question;

  const AIChatBubble({
    super.key,
    required this.text,
    this.citations = const [],
    this.question,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            backgroundColor: AppColors.primaryContainer,
            radius: 16,
            child: Icon(Icons.auto_awesome, color: AppColors.primary, size: 16),
          ),
          AppSpacing.hMd,
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: AppRadius.card.copyWith(
                  topLeft: AppRadius.bubbleTail,
                ),
                border: Border.all(color: AppColors.border),
                boxShadow: AppShadows.card,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.6,
                    ),
                  ),
                  if (citations.isNotEmpty) ...[
                    AppSpacing.vMd,
                    const Divider(),
                    AppSpacing.vSm,
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: citations
                          .map(
                            (c) => CitationChip(
                              label: c.label,
                              value: c.value,
                              onTap: () {},
                            ),
                          )
                          .toList(),
                    ),
                  ],
                  AppSpacing.vMd,
                  const Divider(height: 1),
                  AppSpacing.vXs,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.copy_rounded, size: 16),
                        tooltip: 'Sao chép',
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(),
                        color: AppColors.textTertiary,
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: text));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đã sao chép vào bộ nhớ tạm'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                      if (question != null) ...[
                        AppSpacing.hMd,
                        IconButton(
                          icon: const Icon(Icons.bookmark_add_outlined, size: 17),
                          tooltip: 'Lưu câu trả lời',
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(),
                          color: AppColors.textTertiary,
                          onPressed: () async {
                            final success = await context.read<ChatProvider>().saveAnswer(question!, text);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(success ? 'Đã lưu câu trả lời thành công!' : 'Lưu câu trả lời thất bại'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UserChatBubble extends StatelessWidget {
  final String text;

  const UserChatBubble({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: AppRadius.card.copyWith(
                  topRight: AppRadius.bubbleTail,
                ),
              ),
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  height: 1.6,
                ),
              ),
            ),
          ),
          AppSpacing.hMd,
          const CircleAvatar(
            backgroundColor: AppColors.surfaceVariant,
            radius: 16,
            child: Icon(Icons.person, color: AppColors.textSecondary, size: 16),
          ),
        ],
      ),
    );
  }
}

class TypingIndicator extends StatelessWidget {
  const TypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            backgroundColor: AppColors.primaryContainer,
            radius: 16,
            child: Icon(Icons.auto_awesome, color: AppColors.primary, size: 16),
          ),
          AppSpacing.hMd,
          const Flexible(
            child: AIProcessingLoader(
              message: 'SmartDoc AI đang xử lý',
              detail: 'Đang quét tài liệu tham khảo và soạn câu trả lời ngắn gọn',
            ),
          ),
        ],
      ),
    ).appEntrance();
  }
}
