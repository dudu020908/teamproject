import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamproject/model/candidate.dart';
import 'package:teamproject/service/local_storage_service.dart';
import 'package:teamproject/widgets/gradient_background.dart';
import 'package:teamproject/widgets/dark_mode_toggle.dart';
import 'package:teamproject/widgets/logout_button.dart';
import 'package:teamproject/widgets/pick_winner_card.dart';
import 'package:teamproject/main.dart';

class WinnerScreen extends StatefulWidget {
  const WinnerScreen({super.key});

  @override
  State<WinnerScreen> createState() => _WinnerScreenState();
}

class _WinnerScreenState extends State<WinnerScreen> {
  bool _saved = false; // 로컬 저장 중복 방지

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _saveLocalResult());
  }

  // -------------------------------------------------------------------------
  // 로컬 저장: SharedPreferences(LocalStorageService)
  // -------------------------------------------------------------------------
  Future<void> _saveLocalResult() async {
    if (_saved) return;

    final args = ModalRoute.of(context)!.settings.arguments as Map;

    final topic = args['topic'] as String;
    final winner = args['winner'] as Candidate;

    await LocalStorageService.saveResult(topic, winner.title);

    setState(() => _saved = true);
  }

  // -------------------------------------------------------------------------
  // UI
  // -------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final topic = args['topic'] as String;
    final winner = args['winner'] as Candidate;

    return WillPopScope(
      // 뒤로가기 강제 차단 + /topics 이동
      onWillPop: () async {
        Navigator.pushNamedAndRemoveUntil(context, '/topics', (route) => false);
        return false;
      },

      child: Consumer<ThemeModeNotifier>(
        builder: (_, tm, __) {
          final isDark = Theme.of(context).brightness == Brightness.dark;

          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: const Text("최종 결과"),
              centerTitle: true,

              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/topics',
                    (route) => false,
                  );
                },
              ),
            ),

            body: GradientBackground(
              child: Stack(
                children: [
                  const LogoutButton(),
                  const DarkModeToggle(),

                  SafeArea(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 32,
                      ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),

                          // 🔥 주제 텍스트
                          Text(
                            "주제: $topic",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 24),

                          // Winner 카드 - 자동 너비 조절
                          FractionallySizedBox(
                            widthFactor: 0.85,
                            child: PickCard(
                              title: winner.title,
                              imageUrl: winner.imageUrl,
                              onTap: () {},
                            ),
                          ),

                          const SizedBox(height: 32),

                          Text(
                            "나의 최종 선택!",
                            style: TextStyle(
                              fontSize: 16,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),

                          const SizedBox(height: 24),

                          // 요약 보기
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/summary');
                              },
                              child: const Text("요약 보기"),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // 다시 하기 → topics 이동
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  '/topics',
                                  (route) => false,
                                );
                              },
                              child: const Text("다시 하기"),
                            ),
                          ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
