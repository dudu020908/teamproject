import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:teamproject/main.dart';
import 'package:teamproject/service/local_storage_service.dart';
import 'package:teamproject/widgets/dark_mode_toggle.dart';
import 'package:teamproject/widgets/gradient_background.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({super.key});

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  late final ValueNotifier<String?> _genderNotifier;
  late final ValueNotifier<double> _ageNotifier;

  @override
  void initState() {
    super.initState();
    _genderNotifier = ValueNotifier<String?>(null);
    _ageNotifier = ValueNotifier<double>(25);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadUserInfo());
  }

  @override
  void dispose() {
    _genderNotifier.dispose();
    _ageNotifier.dispose();
    super.dispose();
  }

  // 앱 실행 시 SharedPreferences에서 사용자 정보 로드
  Future<void> _loadUserInfo() async {
    final saved = await LocalStorageService.loadUserInfo();
    if (!mounted || saved == null) return;

    final savedGender = saved['gender'] as String?;
    final savedAge = (saved['age'] as int?)?.toDouble();

    if (savedGender != null && savedGender != _genderNotifier.value) {
      _genderNotifier.value = savedGender;
    }

    if (savedAge != null && savedAge != _ageNotifier.value) {
      _ageNotifier.value = savedAge;
    }
  }

  void _next() async {
    final selectedGender = _genderNotifier.value;
    if (selectedGender == null) return;

    final selectedAge = _ageNotifier.value.toInt();

    await LocalStorageService.saveUserInfo(selectedGender, selectedAge);
    if (!mounted) return;

    Navigator.pushReplacementNamed(
      context,
      '/topics',
      arguments: {'gender': selectedGender, 'age': selectedAge},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModeNotifier>(
      builder: (context, themeNotifier, _) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final textColor = isDark ? Colors.white : Colors.black87;
        final subTextColor = isDark ? Colors.grey[400] : Colors.grey[700];
        final boxColor = isDark ? Colors.grey[900] : Colors.white;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: GradientBackground(
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      // 배경 원형 효과 (라이트/다크에 맞게 조정)
                      if (!isDark) ...[
                        Positioned(
                          top: -80,
                          left: -80,
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFCFE3),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -80,
                          right: -80,
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: const BoxDecoration(
                              color: Color(0xFFBBDEFB),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],

                      // 메인 유저정보화면
                      SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 48,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const SizedBox(height: 60),
                              Text(
                                "먼저 당신에 대해 알려주세요 💬",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 40),

                              // 성별 선택
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: boxColor,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "성별",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    ValueListenableBuilder<String?>(
                                      valueListenable: _genderNotifier,
                                      builder: (context, selectedGender, _) {
                                        return FocusTraversalGroup(
                                          policy: WidgetOrderTraversalPolicy(),
                                          child: Wrap(
                                            alignment:
                                                WrapAlignment.spaceBetween,
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: [
                                              _buildGenderButton(
                                                "남자",
                                                "male",
                                                Colors.blueAccent,
                                                isDark,
                                                selectedGender,
                                                order: 0,
                                              ),
                                              _buildGenderButton(
                                                "여자",
                                                "female",
                                                Colors.pinkAccent,
                                                isDark,
                                                selectedGender,
                                                order: 1,
                                              ),
                                              _buildGenderButton(
                                                "비공개",
                                                "other",
                                                Colors.purpleAccent,
                                                isDark,
                                                selectedGender,
                                                order: 2,
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 24),

                              // 나이 선택
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: boxColor,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "나이",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    ValueListenableBuilder<double>(
                                      valueListenable: _ageNotifier,
                                      builder: (context, age, _) {
                                        return Stack(
                                          clipBehavior: Clip.none,
                                          alignment: Alignment.topCenter,
                                          children: [
                                            Positioned(
                                              top: -35,
                                              child: AnimatedContainer(
                                                duration: const Duration(
                                                  milliseconds: 150,
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 6,
                                                    ),
                                                decoration: BoxDecoration(
                                                  gradient: isDark
                                                      ? null
                                                      : const LinearGradient(
                                                          colors: [
                                                            Colors.pinkAccent,
                                                            Colors.purpleAccent,
                                                          ],
                                                        ),
                                                  color: isDark
                                                      ? Colors.grey[800]
                                                      : null,
                                                  borderRadius:
                                                      BorderRadius.circular(24),
                                                  boxShadow: isDark
                                                      ? []
                                                      : [
                                                          BoxShadow(
                                                            color: Colors
                                                                .purpleAccent
                                                                .withOpacity(
                                                                  0.4,
                                                                ),
                                                            blurRadius: 10,
                                                            offset:
                                                                const Offset(
                                                                  0,
                                                                  4,
                                                                ),
                                                          ),
                                                        ],
                                                ),
                                                child: Text(
                                                  "${age.toInt()}세",
                                                  style: TextStyle(
                                                    color: isDark
                                                        ? Colors.white
                                                        : Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Slider(
                                              value: age,
                                              min: 10,
                                              max: 60,
                                              divisions: 50,
                                              label: "${age.toInt()}",
                                              activeColor: isDark
                                                  ? Colors.purpleAccent
                                                  : Colors.black87,
                                              inactiveColor: isDark
                                                  ? Colors.grey[700]
                                                  : Colors.grey[300],
                                              onChanged: (value) =>
                                                  _ageNotifier.value = value,
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "10",
                                          style: TextStyle(color: subTextColor),
                                        ),
                                        Text(
                                          "60",
                                          style: TextStyle(color: subTextColor),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 20),
                              const Text(
                                "각 월드컵은 약 1~2분이 소요됩니다.",
                                style: TextStyle(color: Colors.grey),
                              ),

                              const SizedBox(height: 40),

                              // 다음으로 버튼
                              ValueListenableBuilder<String?>(
                                valueListenable: _genderNotifier,
                                builder: (context, selectedGender, _) {
                                  final isEnabled = selectedGender != null;

                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeInOut,
                                    width: double.infinity,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: isEnabled
                                          ? const Color(0xFFFF5C8D)
                                          : (isDark
                                                ? Colors.grey[800]
                                                : Colors.grey[300]),
                                      borderRadius: BorderRadius.circular(40),
                                      boxShadow: isEnabled
                                          ? [
                                              BoxShadow(
                                                color: Colors.pinkAccent
                                                    .withOpacity(0.4),
                                                blurRadius: 12,
                                                offset: const Offset(0, 4),
                                              ),
                                            ]
                                          : [],
                                    ),
                                    child: TextButton(
                                      onPressed: isEnabled ? _next : null,
                                      child: Text(
                                        "다음으로",
                                        style: TextStyle(
                                          color: isEnabled
                                              ? Colors.white
                                              : Colors.grey[500],
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 60),
                            ],
                          ),
                        ),
                      ),

                      // 상단 다크모드 토글 버튼
                      const Positioned(
                        top: 16,
                        right: 16,
                        child: DarkModeToggle(),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  // 다크모드 대응 성별 버튼 + 포커스/접근성 개선
  Widget _buildGenderButton(
    String label,
    String value,
    Color color,
    bool isDark,
    String? selectedGender, {
    double order = 0,
  }) {
    final bool isSelected = selectedGender == value;
    return FocusTraversalOrder(
      order: NumericFocusOrder(order),
      child: Semantics(
        button: true,
        label: '$label 선택',
        selected: isSelected,
        child: GestureDetector(
          onTap: () => _genderNotifier.value = value,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? color
                  : (isDark ? Colors.grey[800] : const Color(0xFFF1F1F1)),
              borderRadius: BorderRadius.circular(30),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : [],
            ),
            child: Center(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.white70 : Colors.black87),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
