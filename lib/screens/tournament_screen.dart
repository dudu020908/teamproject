// screens/tournament_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamproject/model/candidate.dart';
import 'package:teamproject/widgets/gradient_background.dart';
import 'package:teamproject/widgets/pick_winner_animator.dart';
import 'package:teamproject/widgets/pick_winner_card.dart';
import 'package:teamproject/widgets/dark_mode_toggle.dart';
import 'package:teamproject/main.dart';
import '../providers/tournament_provider.dart';

class TournamentScreen extends StatefulWidget {
  const TournamentScreen({super.key});

  @override
  State<TournamentScreen> createState() => _TournamentScreenState();
}

class _TournamentScreenState extends State<TournamentScreen> {
  bool _navigatedToWinner = false;
  bool _isAnimating = false;
  Candidate? _selected;
  bool _isLeftCardSelected = false;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final int? rounds = args?['rounds'] as int?;

    return Consumer<ThemeModeNotifier>(
      builder: (context, themeNotifier, _) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final textColor = isDark ? Colors.white : Colors.black;

        final provider = context.watch<TournamentProvider>();
        final currentPair = provider.currentPair;
        final topic = provider.topicTitle;

        // 라운드 라벨 / 진행도 / 부전승 문구
        final label = provider.roundLabel; // 9강 / 5강 / 3강 / 결승
        final pairText = provider.roundPairsTotal > 0
            ? '${provider.currentPairIndexDisplay}/${provider.roundPairsTotal}'
            : '';
        final byeHint = provider.byeThisRound ? ' · 부전승 1명 포함' : '';
        final statusText =
            '($label${pairText.isNotEmpty ? ' $pairText' : ''}$byeHint)';
        final roundsText = rounds != null ? ' · 시작 ${rounds}강' : '';

        // 우승이 결정된 순간 WinnerScreen 으로 이동
        if (provider.hasWinner && !_navigatedToWinner) {
          _navigatedToWinner = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushNamed(
              context,
              '/winner',
              arguments: {'topic': topic, 'winner': provider.winner},
            );
          });
        }

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Column(
              children: [
                Text(
                  '대결 – $topic',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$statusText$roundsText',
                  style: TextStyle(
                    fontSize: 13,
                    color: textColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          body: GradientBackground(
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (provider.hasWinner)
                  const SizedBox.shrink()
                else if (currentPair.isEmpty)
                  // 페어 전환 사이 짧은 대기 상태
                  const Center(
                    child: Text(
                      '다음 라운드 준비 중...',
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                else
                  // 실제 대결 카드 영역
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: currentPair.map((candidate) {
                          final isBye = candidate.isBye;

                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: isBye
                                  // 부전승 카드: 이미지 대신 텍스트 박스
                                  ? _ByeCard(isDark: isDark)
                                  : PickCard(
                                      title: candidate.title,
                                      imageUrl: candidate.imageUrl,
                                      onTap: _isAnimating
                                          ? () {}
                                          : () =>
                                                _onSelect(provider, candidate),
                                    ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 40),
                      Text(
                        provider.byeThisRound
                            ? '부전승이 포함된 라운드입니다.'
                            : '마음에 드는 후보를 선택하세요.',
                        style: TextStyle(
                          fontSize: 16,
                          color: textColor.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),

                // 승자 선택 애니메이션 오버레이
                if (_selected != null && _isAnimating)
                  PickWinnerAnimator(
                    candidate: _selected!,
                    isLeftCard: _isLeftCardSelected,
                    onAnimationComplete: () {
                      provider.pickWinner(_selected!);

                      Future.delayed(const Duration(milliseconds: 200), () {
                        if (!mounted) return;
                        setState(() {
                          _selected = null;
                          _isAnimating = false;
                        });
                      });
                    },
                  ),

                // 상단 다크모드 토글
                const DarkModeToggle(),
              ],
            ),
          ),
        );
      },
    );
  }

  // 카드 선택 시 호출
  void _onSelect(TournamentProvider provider, Candidate candidate) {
    if (_isAnimating) return;
    if (candidate.isBye) return; // 부전승 카드는 절대 선택되지 않도록 방어

    final currentPair = provider.currentPair;
    final isLeft = currentPair.isNotEmpty && currentPair[0] == candidate;

    setState(() {
      _selected = candidate;
      _isAnimating = true;
      _isLeftCardSelected = isLeft;
    });
  }
}

// 부전승 카드 전용 위젯
class _ByeCard extends StatelessWidget {
  final bool isDark;
  const _ByeCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? Colors.black.withOpacity(0.3) : Colors.white;
    final border = isDark ? Colors.white24 : Colors.grey.shade300;
    final textColor = isDark ? Colors.white70 : Colors.grey.shade800;

    return Container(
      height: 260,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: border),
      ),
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Text(
          '부전승입니다.\n옆 후보를 선택하세요.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
