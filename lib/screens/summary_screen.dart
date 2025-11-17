import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamproject/service/local_storage_service.dart';
import 'package:teamproject/widgets/gradient_background.dart';
import 'package:teamproject/widgets/dark_mode_toggle.dart';
import 'package:teamproject/main.dart';
import 'package:teamproject/widgets/logout_button.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  Map<String, dynamic>? userInfo; // gender, age
  Map<String, dynamic>? lastResult; // topic, winner

  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadLocalData();
  }

  /// SharedPreferences(LocalStorageService)로부터 사용자 정보 & 결과 불러오기
  Future<void> _loadLocalData() async {
    final user = await LocalStorageService.loadUserInfo();
    final result = await LocalStorageService.loadResult();

    setState(() {
      userInfo = user;
      lastResult = result;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModeNotifier>(
      builder: (_, themeNotifier, __) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final textColor = isDark ? Colors.white : Colors.black87;

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text("요약 정보", style: TextStyle(color: textColor)),
            centerTitle: true,
          ),

          body: GradientBackground(
            child: Stack(
              children: [
                const DarkModeToggle(), // 상단 우측 토글
                const LogoutButton(), // 상단 좌측 로그아웃 버튼

                // 본문 UI
                Center(
                  child: loading
                      ? const CircularProgressIndicator()
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 40),

                              // 사용자 정보 카드
                              _buildUserInfoCard(isDark),

                              const SizedBox(height: 20),

                              // 최근 월드컵 결과 카드
                              _buildResultCard(isDark),

                              const SizedBox(height: 30),

                              // 전체 초기화 버튼
                              Center(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isDark
                                        ? Colors.red[400]
                                        : Colors.red,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 30,
                                      vertical: 12,
                                    ),
                                  ),
                                  onPressed: () async {
                                    await LocalStorageService.clearAll();

                                    if (!mounted) return;

                                    Navigator.pushNamedAndRemoveUntil(
                                      context,
                                      '/userinfo',
                                      (route) => false,
                                    );
                                  },
                                  child: const Text(
                                    "모든 로컬 데이터 초기화",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // -------------------------------------------------------------------------
  // 사용자 정보 카드
  // -------------------------------------------------------------------------
  Widget _buildUserInfoCard(bool isDark) {
    if (userInfo == null) {
      return _emptyCard("저장된 사용자 정보가 없습니다.");
    }

    final titleColor = isDark ? Colors.white : Colors.black87;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "사용자 정보",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 12),

            Text(
              "성별 : ${userInfo!['gender']}",
              style: TextStyle(fontSize: 16, color: titleColor),
            ),
            Text(
              "나이 : ${userInfo!['age']}세",
              style: TextStyle(fontSize: 16, color: titleColor),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // 최근 월드컵 결과 카드
  // -------------------------------------------------------------------------
  Widget _buildResultCard(bool isDark) {
    if (lastResult == null) {
      return _emptyCard("저장된 월드컵 결과가 없습니다.");
    }

    final titleColor = isDark ? Colors.white : Colors.black87;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              "최근 월드컵 결과",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 12),

            Text(
              "주제 : ${lastResult!['topic']}",
              style: TextStyle(fontSize: 16, color: titleColor),
            ),
            Text(
              "우승자 : ${lastResult!['winner']}",
              style: TextStyle(fontSize: 16, color: titleColor),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // 빈 데이터 카드
  // -------------------------------------------------------------------------
  Widget _emptyCard(String text) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(text, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
