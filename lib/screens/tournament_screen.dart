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
  Candidate? _selected; // Candidate 타입
  bool _isLeftCardSelected = false; // 선택된 카드가 왼쪽 카드인지 여부

  @override
  Widget build(BuildContext context) {
    // 전달된 라운드 정보 가져오기
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final int? rounds = args?['rounds'] as int?;
    final String roundsText = rounds != null ? ' (${rounds}강)' : '';

    // Consumer로 감싸서 다크모드 반영
    return Consumer2<ThemeModeNotifier, TournamentProvider>(
      builder: (context, themeNotifier, provider, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final textColor = isDark ? Colors.white : Colors.black;

        final currentPair = provider.currentPair;
        final topic = provider.topicTitle; // 현재 주제 이름

        // UI에 표시할 상태 텍스트 구성
        final label = provider.roundLabel;
        final pairText = provider.roundPairsTotal > 0
            ? '${provider.currentPairIndexDisplay}/${provider.roundPairsTotal}'
            : '';
        final byeHint = provider.byeThisRound ? ' · 부전승 1명 포함' : '';
        final statusText =
            '($label${pairText.isNotEmpty ? ' $pairText' : ''}$byeHint)';

        // 우승자 확정 시 결과화면 이동
        if (provider.hasWinner && !_navigatedToWinner) {
          _navigatedToWinner = true; // 중복 방지
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushNamed(
              context,
              '/winner',
              arguments: {'topic': topic, 'winner': provider.winner},
            );
          });
        }

        return Scaffold(
          extendBodyBehindAppBar: true, // 배경을 AppBar 뒤까지 확장
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: textColor,
          ),

          body: GradientBackground(
            child: Stack(
              children: [
                // 토너먼트 정보: "대결-주제" + "(8강/부전승)" 표시
                Positioned(
                  top: kToolbarHeight + MediaQuery.of(context).padding.top + 5,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      Text(
                        '대결 – $topic',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
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

                // 카드 UI
                Padding(
                  padding: const EdgeInsets.only(top: 120),
                  child: Center(
                    child: provider.hasWinner
                        ? const SizedBox.shrink()
                        : currentPair.isEmpty
                        ? Text(
                            "후보가 없습니다",
                            style: TextStyle(color: textColor, fontSize: 18),
                          )
                        : Stack(
                            alignment: Alignment.center,
                            children: [
                              // AnimatedSwitcher (다음 라운드 전환 효과)
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 600),
                                transitionBuilder: (child, anim) {
                                  return ScaleTransition(
                                    scale: CurvedAnimation(
                                      parent: anim,
                                      curve: Curves.elasticOut,
                                    ),
                                    child: child,
                                  );
                                },

                                child: _isAnimating
                                    ? const SizedBox.shrink(
                                        key: ValueKey('gap'),
                                      )
                                    : Row(
                                        key: ValueKey(
                                          currentPair
                                              .map((c) => c.title)
                                              .join(','),
                                        ),
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: currentPair.map((candidate) {
                                          // 부전승 후보라면 전용 카드 UI 표시
                                          if (candidate.isBye) {
                                            return Expanded(
                                              child: _ByeCard(isDark: isDark),
                                            );
                                          }

                                          // 일반 후보 카드
                                          return Expanded(
                                            child: AnimatedScale(
                                              scale: _selected == candidate
                                                  ? 0.95
                                                  : 1.0,
                                              duration: const Duration(
                                                milliseconds: 150,
                                              ),
                                              child: PickCard(
                                                title: candidate.title,
                                                imageUrl: candidate.imageUrl,
                                                onTap: _isAnimating
                                                    ? () {}
                                                    : () => _onSelect(
                                                        provider,
                                                        candidate,
                                                      ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                              ),

                              // 선택된 카드 확대 + 이동 애니메이션
                              if (_selected != null && _isAnimating)
                                PickWinnerAnimator(
                                  candidate: _selected!,
                                  isLeftCard: _isLeftCardSelected,
                                  onAnimationComplete: () {
                                    provider.pickWinner(_selected!);

                                    Future.delayed(
                                      const Duration(milliseconds: 200),
                                      () {
                                        if (mounted) {
                                          setState(() {
                                            _selected = null;
                                            _isAnimating = false;
                                          });
                                        }
                                      },
                                    );
                                  },
                                ),
                            ],
                          ),
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

  // 카드 선택 시 호출
  void _onSelect(TournamentProvider provider, Candidate candidate) {
    if (_isAnimating) return;

    // 부전승 후보는 절대 선택되지 않음
    if (candidate.isBye) return;

    final currentPair = provider.currentPair;
    // 선택된 카드가 왼쪽인지 확인
    final isLeft = currentPair.isNotEmpty && currentPair[0] == candidate;

    setState(() {
      _selected = candidate;
      _isAnimating = true;
      _isLeftCardSelected = isLeft; // 상태 저장
    });
  }
}

// 부전승 카드 전용 UI
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
      margin: const EdgeInsets.all(12),
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
