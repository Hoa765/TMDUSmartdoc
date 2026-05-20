import 'package:flutter/material.dart';
import '../../../core/constants.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Trợ giúp & Hỗ trợ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xl),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Beautiful support header card
                  _buildSupportHero(context),
                  AppSpacing.vLg,

                  // FAQ Title
                  Row(
                    children: [
                      const Icon(Icons.help_outline_rounded, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Các câu hỏi thường gặp',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                              letterSpacing: 0.2,
                            ),
                      ),
                    ],
                  ),
                  AppSpacing.vMd,

                  // Collapsible FAQ list
                  const _FaqList().appEntrance(delay: const Duration(milliseconds: 100)),
                  AppSpacing.vXxl,

                  // Contact support grid
                  Text(
                    'Bạn cần trợ giúp thêm?',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          letterSpacing: 0.2,
                        ),
                  ),
                  AppSpacing.vMd,
                  _buildContactGrid(context).appEntrance(delay: const Duration(milliseconds: 150)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSupportHero(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.card,
        boxShadow: AppShadows.card,
      ),
      child: ClipRRect(
        borderRadius: AppRadius.card,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chúng tôi có thể giúp gì?',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tìm kiếm câu trả lời nhanh chóng hoặc liên hệ trực tiếp với chúng tôi để nhận hỗ trợ học thuật tốt nhất.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).appEntrance();
  }

  Widget _buildContactGrid(BuildContext context) {
    final List<Map<String, dynamic>> items = [
      {
        'title': 'Gửi ý kiến phản hồi',
        'subtitle': 'Đóng góp ý kiến cải tiến ứng dụng SmartDoc',
        'icon': Icons.rate_review_rounded,
        'color': AppColors.primary,
        'action': (BuildContext ctx) => _showFeedbackDialog(ctx),
      },
      {
        'title': 'Email hỗ trợ',
        'subtitle': 'Gửi mail trực tiếp tới smartdoc@tdmu.edu.vn',
        'icon': Icons.mail_outline_rounded,
        'color': AppColors.secondary,
        'action': (BuildContext ctx) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            const SnackBar(
              content: Text('Hệ thống email liên hệ: smartdoc@tdmu.edu.vn'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      },
    ];

    return Column(
      children: items.map((item) {
        final color = item['color'] as Color;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
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
                onTap: () => (item['action'] as Function(BuildContext))(context),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(item['icon'] as IconData, color: color, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['title'] as String,
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['subtitle'] as String,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: AppColors.textSecondary,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.textTertiary,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final controller = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
        title: const Row(
          children: [
            Icon(Icons.rate_review_rounded, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Đóng góp phản hồi', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Mọi ý kiến góp ý của bạn sẽ giúp đội ngũ kỹ sư SmartDoc nâng cao độ chính xác của AI và trải nghiệm học tập tốt hơn.',
                style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.45),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: controller,
                maxLines: 4,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Vui lòng điền nội dung phản hồi';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Nhập ý kiến, báo lỗi hoặc gợi ý nâng cấp tính năng...',
                  hintStyle: const TextStyle(fontSize: 13, color: AppColors.textTertiary),
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.control,
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppRadius.control,
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.dispose();
              Navigator.pop(ctx);
            },
            child: const Text('Huỷ bỏ', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                controller.dispose();
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cảm ơn bạn! Phản hồi đã được ghi nhận trên hệ thống.'),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Gửi phản hồi', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _FaqList extends StatelessWidget {
  const _FaqList();

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> faqs = [
      {
        'q': 'SmartDoc AI trả lời dựa trên những học liệu nào?',
        'a': 'SmartDoc AI hoạt động theo kiến trúc RAG (Retrieval-Augmented Generation). Khi bạn tải lên một tài liệu, hệ thống sẽ chia nhỏ, nhúng (embed) và lưu trữ vector dữ liệu. AI sẽ trích xuất ngữ cảnh liên quan trực tiếp từ tài liệu đó để tạo câu trả lời chính xác, tránh tuyệt đối hiện tượng "ảo tưởng dữ liệu" của các mô hình ngôn ngữ lớn.',
      },
      {
        'q': 'Tôi có thể chia sẻ các tài liệu và ghi chú học tập không?',
        'a': 'Có, hệ thống Notebook cho phép bạn gộp nhiều tài liệu liên quan vào cùng một sổ tay học tập. Trong các phiên bản cập nhật tới, SmartDoc sẽ hỗ trợ tính năng chia sẻ liên kết Notebook để học nhóm trực tuyến cùng bạn bè.',
      },
      {
        'q': 'Các định dạng tài liệu nào được hỗ trợ?',
        'a': 'Hiện tại ứng dụng hỗ trợ trích xuất và phân tích toàn diện các tài liệu định dạng PDF, văn bản thuyết trình PowerPoint (.ppt, .pptx) và tài liệu Word (.docx).',
      },
      {
        'q': 'Làm thế nào để lưu lại các câu trả lời hay của AI?',
        'a': 'Dưới mỗi câu trả lời của AI trong màn hình trò chuyện, bạn sẽ thấy một biểu tượng Bookmark nhỏ. Bấm vào biểu tượng đó, cặp Câu hỏi & Câu trả lời sẽ tự động đồng bộ thời gian thực về thư viện hồ sơ cá nhân của bạn.',
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: faqs.length,
      itemBuilder: (context, index) {
        final faq = faqs[index];
        return _FaqCard(
          question: faq['q']!,
          answer: faq['a']!,
        );
      },
    );
  }
}

class _FaqCard extends StatefulWidget {
  final String question;
  final String answer;

  const _FaqCard({
    required this.question,
    required this.answer,
  });

  @override
  State<_FaqCard> createState() => _FaqCardState();
}

class _FaqCardState extends State<_FaqCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.card,
          border: Border.all(
            color: _isExpanded ? AppColors.primary.withValues(alpha: 0.2) : AppColors.border,
            width: 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.01),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: AppRadius.card,
          child: Column(
            children: [
              ListTile(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                leading: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _isExpanded ? AppColors.primary.withValues(alpha: 0.08) : AppColors.background,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.quiz_rounded,
                    color: _isExpanded ? AppColors.primary : AppColors.textSecondary,
                    size: 16,
                  ),
                ),
                title: Text(
                  widget.question,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: _isExpanded ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
                trailing: AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0,
                  duration: AppConstants.animationDuration,
                  child: const Icon(
                    Icons.expand_more_rounded,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 4),
                  decoration: BoxDecoration(
                    color: AppColors.background.withValues(alpha: 0.3),
                  ),
                  child: Text(
                    widget.answer,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: AppConstants.animationDuration,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
