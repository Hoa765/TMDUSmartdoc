import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants.dart';
import '../../../shared/widgets/widgets.dart';
import '../../auth/providers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  String _selectedFaculty = 'Khoa học Máy tính';
  String _selectedYear = 'Năm 3';
  String _selectedAvatarIndex = '0';

  final List<Map<String, dynamic>> _avatarPresets = [
    {
      'index': '0',
      'colors': [const Color(0xFF2563EB), const Color(0xFF60A5FA)],
      'icon': Icons.person_rounded,
    },
    {
      'index': '1',
      'colors': [const Color(0xFF7C3AED), const Color(0xFFC084FC)],
      'icon': Icons.school_rounded,
    },
    {
      'index': '2',
      'colors': [const Color(0xFF059669), const Color(0xFF34D399)],
      'icon': Icons.science_rounded,
    },
    {
      'index': '3',
      'colors': [const Color(0xFFDC2626), const Color(0xFFF87171)],
      'icon': Icons.psychology_rounded,
    },
    {
      'index': '4',
      'colors': [const Color(0xFFD97706), const Color(0xFFFBBF24)],
      'icon': Icons.menu_book_rounded,
    },
    {
      'index': '5',
      'colors': [const Color(0xFF0891B2), const Color(0xFF22D3EE)],
      'icon': Icons.computer_rounded,
    },
  ];

  final List<String> _faculties = [
    'Khoa học Máy tính',
    'Kỹ thuật Phần mềm',
    'Hệ thống Thông tin',
    'An toàn Thông tin',
    'Công nghệ Thông tin',
    'Quản trị Kinh doanh',
    'Ngôn ngữ Anh',
    'Sư phạm Toán',
  ];

  final List<String> _years = [
    'Năm 1',
    'Năm 2',
    'Năm 3',
    'Năm 4',
    'Học viên Cao học',
  ];

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _nameController = TextEditingController(text: auth.userName);
    _selectedFaculty = auth.faculty;
    _selectedYear = auth.academicYear;
    _selectedAvatarIndex = auth.avatarIndex;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Thiết lập tài khoản',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xl),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar Selection Card Block
                    AppCard(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl, horizontal: AppSpacing.md),
                      child: Column(
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.face_retouching_natural_rounded, color: AppColors.primary, size: 18),
                              SizedBox(width: 6),
                              Text(
                                'Chọn ảnh diện học tập',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          AppSpacing.vLg,
                          Center(
                            child: Wrap(
                              spacing: 14,
                              runSpacing: 14,
                              alignment: WrapAlignment.center,
                              children: _avatarPresets.map((preset) {
                                final isSelected = _selectedAvatarIndex == preset['index'];
                                final colors = preset['colors'] as List<Color>;
                                final icon = preset['icon'] as IconData;

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedAvatarIndex = preset['index'];
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: AppConstants.animationDuration,
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected ? AppColors.primary : Colors.transparent,
                                        width: 2.5,
                                      ),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: AppColors.primary.withValues(alpha: 0.25),
                                                blurRadius: 8,
                                                spreadRadius: 2,
                                              )
                                            ]
                                          : [],
                                    ),
                                    child: Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: colors,
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        boxShadow: AppShadows.card,
                                      ),
                                      child: Icon(
                                        icon,
                                        color: Colors.white,
                                        size: 26,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppSpacing.vLg,

                    // Details Card Block
                    AppCard(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.badge_rounded, color: AppColors.secondary, size: 18),
                              SizedBox(width: 6),
                              Text(
                                'Thông tin học thuật',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          AppSpacing.vLg,

                          // Display Name Input
                          const Text(
                            'Họ và tên học viên',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _nameController,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Vui lòng nhập họ và tên';
                              }
                              return null;
                            },
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                            decoration: InputDecoration(
                              hintText: 'Nhập họ và tên của bạn',
                              prefixIcon: const Icon(Icons.person_outline_rounded, size: 20, color: AppColors.textSecondary),
                              prefixIconConstraints: const BoxConstraints(minWidth: 40),
                              border: OutlineInputBorder(
                                borderRadius: AppRadius.control,
                                borderSide: const BorderSide(color: AppColors.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: AppRadius.control,
                                borderSide: const BorderSide(color: AppColors.border),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: AppRadius.control,
                                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                              ),
                              filled: true,
                              fillColor: AppColors.background,
                              contentPadding: AppSpacing.inputPadding,
                            ),
                          ),
                          AppSpacing.vLg,

                          // Faculty Selector Dropdown
                          const Text(
                            'Khoa / Chuyên ngành đào tạo',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          _buildDropdown<String>(
                            value: _selectedFaculty,
                            items: _faculties,
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedFaculty = val;
                                });
                              }
                            },
                            icon: Icons.school_outlined,
                          ),
                          AppSpacing.vLg,

                          // Academic Year Selector Dropdown
                          const Text(
                            'Khóa / Năm học hiện tại',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          _buildDropdown<String>(
                            value: _selectedYear,
                            items: _years,
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedYear = val;
                                });
                              }
                            },
                            icon: Icons.date_range_outlined,
                          ),
                        ],
                      ),
                    ),
                    AppSpacing.vXxl,

                    // Action Button
                    CustomButton(
                      label: 'Lưu cấu hình hồ sơ',
                      icon: Icons.save_rounded,
                      isLoading: auth.isLoading,
                      isFullWidth: true,
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final messenger = ScaffoldMessenger.of(context);
                          final navigator = Navigator.of(context);

                          final success = await auth.updateProfile(
                            displayName: _nameController.text.trim(),
                            faculty: _selectedFaculty,
                            academicYear: _selectedYear,
                            avatarIndex: _selectedAvatarIndex,
                          );

                          if (success) {
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Đã cập nhật hồ sơ cá nhân thành công!'),
                                backgroundColor: AppColors.success,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            navigator.pop();
                          } else {
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(auth.errorMessage ?? 'Đã xảy ra lỗi khi lưu cấu hình.'),
                                backgroundColor: AppColors.error,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppRadius.control,
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<T>(
          initialValue: value,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
          decoration: InputDecoration(
            border: InputBorder.none,
            prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 18),
            prefixIconConstraints: const BoxConstraints(minWidth: 36),
          ),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          dropdownColor: AppColors.surface,
          items: items.map((T item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(item.toString()),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
