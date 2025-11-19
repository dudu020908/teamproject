import 'package:flutter/material.dart';
import 'package:teamproject/service/local_storage_service.dart';
import 'package:teamproject/widgets/gradient_background.dart';
import 'package:teamproject/widgets/dark_mode_toggle.dart';
import 'package:provider/provider.dart';
import 'package:teamproject/main.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({super.key});

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  String? gender;
  double age = 25;

  @override
  void initState() {
    super.initState();
    _loadUserInfo(); // 저장된 유저 정보 불러오기
  }

  // 앱 실행 시 SharedPreferences에서 사용자 정보 로드
  Future<void> _loadUserInfo() async {
    final saved = await LocalStorageService.loadUserInfo();
    if (saved != null) {
      setState(() {
        gender = saved['gender'];
        age = (saved['age'] as int).toDouble();
      });
    }
  }

  void _next() async {
    if (gender != null) {
      await LocalStorageService.saveUserInfo(gender!, age.toInt()); // 로컬 저장
      Navigator.pushReplacementNamed(
        context,
        '/topics',
        arguments: {'gender': gender, 'age': age.toInt()},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Consumer로 감싸서 ThemeMode 변경 시 rebuild 되도록
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
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        _buildGenderButton(
                                          "남자",
                                          "male",
                                          Colors.blueAccent,
                                          isDark,
                                        ),
                                        _buildGenderButton(
                                          "여자",
                                          "female",
                                          Colors.pinkAccent,
                                          isDark,
                                        ),
                                        _buildGenderButton(
                                          "비공개",
                                          "other",
                                          Colors.purpleAccent,
                                          isDark,
                                        ),
                                      ],
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
                                    Stack(
                                      clipBehavior: Clip.none,
                                      alignment: Alignment.topCenter,
                                      children: [
                                        Positioned(
                                          top: -35,
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 150,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              gradient: isDark
                                               ? null // 다크모드일 때는 단색
                                               : const LinearGradient(
                                                colors: [
                                                  Colors.pinkAccent,
                                                  Colors.purpleAccent,
                                                ],
                                              ),
                                              color: isDark
                                                  ? Colors.grey[800]
                                                  : null, // 회색 배경 적용
                                              borderRadius:
                                                  BorderRadius.circular(24),
                                              boxShadow: isDark
                                                  ? [] // 다크모드 → 그림자 없음
                                                  : [
                                                      BoxShadow(
                                                        color: Colors
                                                            .purpleAccent
                                                            .withOpacity(0.4),
                                                        blurRadius: 10,
                                                        offset: const Offset(
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
                                                    : Colors.black, // 글자색 반전
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
                                              setState(() => age = value),
                                        ),
                                      ],
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
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeInOut,
                                width: double.infinity,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: gender == null
                                      ? (isDark
                                            ? Colors.grey[800]
                                            : Colors.grey[300])
                                      : const Color(0xFFFF5C8D),
                                  borderRadius: BorderRadius.circular(40),
                                  boxShadow: gender != null
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
                                  onPressed: gender == null ? null : _next,
                                  child: Text(
                                    "다음으로",
                                    style: TextStyle(
                                      color: gender == null
                                          ? Colors.grey[500]
                                          : Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 60),
                            ],
                          ),
                        ),
                      ),
                      // 토글은 가장 마지막
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

  // 다크모드 대응 성별 버튼
  Widget _buildGenderButton(
    String label,
    String value,
    Color color,
    bool isDark,
  ) {
    final bool isSelected = gender == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => gender = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 12),
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
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white70 : Colors.black54),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
