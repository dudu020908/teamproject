import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamproject/model/candidate.dart';
import 'package:teamproject/widgets/gradient_background.dart';
import 'package:teamproject/widgets/pick_winner_card.dart';
import 'package:teamproject/widgets/dark_mode_toggle.dart'; 
import 'package:teamproject/main.dart'; 

class WinnerScreen extends StatelessWidget {
  const WinnerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map?;
    final topic = (args?['topic'] as String?) ?? '주제 없음';
    final winner = args?['winner'] as Candidate?;

    // Consumer로 감싸서 다크모드 즉시 반영
    return Consumer<ThemeModeNotifier>(
      builder: (context, themeNotifier, _) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final textColor = isDark ? Colors.white : Colors.black87;

        return Scaffold(
          appBar: AppBar(
            title: const Text('결과'),
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            foregroundColor: textColor,
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
                            FilledButton(
                              onPressed: () => Navigator.popUntil(
                                context,
                                ModalRoute.withName('/topics'),
                              ),
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
                // 상단 다크모드 토글 버튼
                const DarkModeToggle(),
              ],
            ),
          ),
        );
      },
    );
  }
}
