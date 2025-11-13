import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamproject/model/candidate.dart';
import 'package:teamproject/service/local_storage_service.dart';
import 'package:teamproject/widgets/gradient_background.dart';
import 'package:teamproject/widgets/pick_winner_card.dart';
import 'package:teamproject/widgets/dark_mode_toggle.dart';
import 'package:teamproject/main.dart';

class WinnerScreen extends StatefulWidget {
  const WinnerScreen({super.key});

  @override
  State<WinnerScreen> createState() => _WinnerScreenState();
}

class _WinnerScreenState extends State<WinnerScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _saveResult(); // 위너 정보 로컬 저장
    });
  }

  /// 결과 저장 함수
  Future<void> _saveResult() async {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    if (args != null) {
      final topic = args['topic'] as String?;
      final winner = args['winner'] as Candidate?;
      if (topic != null && winner != null) {
        await LocalStorageService.saveResult(topic, winner.title);
        print('로컬 저장 완료: topic=$topic, winner=${winner.title}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map?;
    final topic = (args?['topic'] as String?) ?? '주제 없음';
    final winner = args?['winner'] as Candidate?;

    return WillPopScope(
      onWillPop: () async {
        // 시스템 뒤로가기 차단 후 직접 이동 처리 
        Navigator.pushNamedAndRemoveUntil(context, '/topics', (route) => false);
        return false;
      },
      child: Consumer<ThemeModeNotifier>(
        builder: (context, themeNotifier, _) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final textColor = isDark ? Colors.white : Colors.black87;

          return Scaffold(
            appBar: AppBar(
              // 자동 뒤로가기 버튼 복구됨 (leading 자동 생성)
              backgroundColor: Colors.transparent,
              foregroundColor: textColor,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  // AppBar 뒤로가기 = /topics 이동
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/topics',
                    (route) => false,
                  );
                },
              ),

              title: const Text('결과'),
            ),
            body: GradientBackground(
              child: Stack(
                children: [
                  Center(
                    child: winner == null
                        ? Text('우승자 없음', style: TextStyle(color: textColor))
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '주제: $topic',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              PickCard(
                                title: winner.title,
                                imageUrl: winner.imageUrl,
                                onTap: () {},
                              ),
                              const SizedBox(height: 8),

                              // 새로운 주제 선택 버튼
                              FilledButton(
                                onPressed: () {
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    '/topics',
                                    (route) => false,
                                  );
                                },
                                style: FilledButton.styleFrom(
                                  backgroundColor: isDark
                                      ? Colors.blueGrey[700]
                                      : const Color(0xFF1565C0),
                                ),
                                child: const Text(
                                  '다른 주제 선택',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                  ),

                  const DarkModeToggle(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
