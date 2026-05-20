import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants.dart';
import '../../home/providers/document_provider.dart';
import '../../notebooks/providers/notebook_provider.dart';
import '../../chat/providers/chat_provider.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final docs = context.watch<DocumentProvider>().documents;
    final notebooks = context.watch<NotebookProvider>().notebooks;
    final chatProvider = context.watch<ChatProvider>();
    final conversations = chatProvider.conversations;

    // Tính toán số liệu thực tế
    final totalDocs = docs.length;
    final totalNotebooks = notebooks.length;
    final totalChats = conversations.length;
    final totalPages = docs.fold<int>(0, (acc, doc) => acc + doc.pageCount);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Thống kê học tập',
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
                  // Progress header card
                  _buildHeaderOverview(context, totalDocs, totalPages),
                  AppSpacing.vLg,

                  // Stat Cards Grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.35,
                    children: [
                      _buildStatCard(
                        context,
                        'Tài liệu môn học',
                        '$totalDocs',
                        Icons.article_rounded,
                        AppColors.primary,
                        const Color(0xFF60A5FA),
                        0,
                      ),
                      _buildStatCard(
                        context,
                        'Sổ tay ghi chép',
                        '$totalNotebooks',
                        Icons.auto_stories_rounded,
                        AppColors.secondary,
                        const Color(0xFFC084FC),
                        1,
                      ),
                      _buildStatCard(
                        context,
                        'Trò chuyện AI',
                        '$totalChats',
                        Icons.forum_rounded,
                        AppColors.accent,
                        const Color(0xFF22D3EE),
                        2,
                      ),
                      _buildStatCard(
                        context,
                        'Số trang tài liệu',
                        '$totalPages',
                        Icons.menu_book_rounded,
                        AppColors.warning,
                        const Color(0xFFFBBF24),
                        3,
                      ),
                    ],
                  ),
                  AppSpacing.vXxl,

                  // Chart Section
                  Row(
                    children: [
                      const Icon(Icons.show_chart_rounded, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Tần suất tương tác học tập',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                              letterSpacing: 0.2,
                            ),
                      ),
                    ],
                  ),
                  AppSpacing.vMd,
                  const _WeeklyActivityChart().appScaleIn(delay: const Duration(milliseconds: 200)),
                  AppSpacing.vXxl,

                  // AI Insight Suggestion Card
                  _buildAiInsightCard(context, totalDocs, totalNotebooks),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderOverview(BuildContext context, int totalDocs, int totalPages) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.card,
        boxShadow: AppShadows.card,
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: ClipRRect(
        borderRadius: AppRadius.card,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.15), width: 1.5),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              AppSpacing.hLg,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hành trình kiến thức',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Bạn đã tích luỹ được $totalPages trang học liệu số từ $totalDocs tài liệu chuyên ngành được tải lên.',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
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

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color mainColor,
    Color glowColor,
    int index,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.border, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: mainColor.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: AppRadius.card,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: mainColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: mainColor.withValues(alpha: 0.15), width: 1),
                    ),
                    child: Icon(icon, color: mainColor, size: 20),
                  ),
                ],
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    ).appScaleIn(delay: Duration(milliseconds: 100 + (index * 50)));
  }

  Widget _buildAiInsightCard(BuildContext context, int totalDocs, int totalNotebooks) {
    String insightText = '';
    if (totalDocs == 0) {
      insightText = 'Bạn chưa tải tài liệu học tập nào lên. Hãy tải lên tài liệu môn học ngay hôm nay, SmartDoc AI sẽ tự động phân tích và tạo lộ trình ôn tập lý tưởng cho riêng bạn!';
    } else if (totalNotebooks == 0) {
      insightText = 'Bạn đang học tập tốt với các tài liệu đơn lẻ. Tuy nhiên, gom nhóm chúng vào một "Notebook" sẽ kích hoạt chế độ đối chiếu đa tài liệu của AI, giúp mở rộng góc nhìn kiến thức chéo cực kỳ sâu sắc!';
    } else {
      insightText = 'Tiến độ học tập của bạn rất ổn định! AI nhận định khả năng tự học của bạn đang ở mức xuất sắc. Hãy tiếp tục đặt câu hỏi đào sâu hoặc trích xuất ghi nhớ học tập thường xuyên nhé!';
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.secondary.withValues(alpha: 0.05), AppColors.accent.withValues(alpha: 0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.15), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: AppRadius.card,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome_rounded, color: AppColors.secondary, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'Nhận xét từ Cố vấn AI',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.secondary,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
              AppSpacing.vMd,
              Text(
                insightText,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  height: 1.55,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    ).appEntrance(delay: const Duration(milliseconds: 300));
  }
}

class _WeeklyActivityChart extends StatefulWidget {
  const _WeeklyActivityChart();

  @override
  State<_WeeklyActivityChart> createState() => _WeeklyActivityChartState();
}

class _WeeklyActivityChartState extends State<_WeeklyActivityChart> {
  bool _animate = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _animate = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();

    return StreamBuilder<QuerySnapshot>(
      stream: chatProvider.getWeeklyActivityStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 200,
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        // Tạo map lưu date -> queryCount từ Firestore
        final Map<String, int> activityMap = {};
        int totalQueries = 0;

        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final dateStr = data['date']?.toString() ?? '';
            final count = int.tryParse(data['queryCount']?.toString() ?? '0') ?? 0;
            if (dateStr.isNotEmpty) {
              activityMap[dateStr] = count;
            }
          }
        }

        // Tạo danh sách 7 ngày gần nhất (từ 6 ngày trước đến hôm nay)
        final now = DateTime.now();
        final List<Map<String, dynamic>> last7Days = [];
        final weekdayNames = {
          1: 'T2',
          2: 'T3',
          3: 'T4',
          4: 'T5',
          5: 'T6',
          6: 'T7',
          7: 'CN'
        };

        for (int i = 6; i >= 0; i--) {
          final date = now.subtract(Duration(days: i));
          final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          final label = weekdayNames[date.weekday] ?? '';
          final count = activityMap[dateStr] ?? 0;
          totalQueries += count;
          last7Days.add({
            'label': label,
            'count': count,
          });
        }

        // Tìm mốc cao nhất để tự điều chỉnh cột hiển thị tỷ lệ
        int maxCount = 5;
        for (var day in last7Days) {
          final count = day['count'] as int;
          if (count > maxCount) {
            maxCount = count;
          }
        }

        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.card,
            border: Border.all(color: AppColors.border, width: 0.8),
            boxShadow: AppShadows.card,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xl),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Tương tác AI trong 7 ngày qua',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15), width: 0.8),
                      ),
                      child: Text(
                        'Tuần này: $totalQueries câu',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                AppSpacing.vXl,

                // Chart Container
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    // Grid background dashed lines for expert chart UI
                    Column(
                      children: List.generate(4, (index) {
                        return Container(
                          height: 38,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: AppColors.border.withValues(alpha: 0.5),
                                width: 0.6,
                                style: BorderStyle.solid,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),

                    // Active Bars
                    SizedBox(
                      height: 160,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(7, (idx) {
                          final dayData = last7Days[idx];
                          final count = dayData['count'] as int;
                          final label = dayData['label'] as String;
                          final heightPercent = count / maxCount;

                          return Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (count > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '$count',
                                    style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              else
                                const SizedBox(height: 15),
                              const SizedBox(height: 4),
                              // Cột
                              Expanded(
                                child: Container(
                                  alignment: Alignment.bottomCenter,
                                  width: 22,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 900),
                                    curve: Curves.easeOutBack,
                                    height: _animate ? (105 * heightPercent) : 0,
                                    decoration: BoxDecoration(
                                      gradient: count > 0
                                          ? const LinearGradient(
                                              colors: [AppColors.primary, AppColors.primaryLight],
                                              begin: Alignment.bottomCenter,
                                              end: Alignment.topCenter,
                                            )
                                          : LinearGradient(
                                              colors: [Colors.grey.shade200, Colors.grey.shade100],
                                              begin: Alignment.bottomCenter,
                                              end: Alignment.topCenter,
                                            ),
                                      borderRadius: BorderRadius.circular(4),
                                      boxShadow: count > 0
                                          ? [
                                              BoxShadow(
                                                color: AppColors.primary.withValues(alpha: 0.15),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              )
                                            ]
                                          : [],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Tên ngày
                              Text(
                                label,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
