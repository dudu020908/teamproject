// ---------------------------------------------------------------------------
// tournament_screen.dart
//
// - TournamentProvider에서 현재 대결 중인 후보 2명을 받아와서 보여줌
// - PickCard(각 후보 카드) + PickWinnerAnimator(선택된 카드 애니메이션)
// - 부전승(bye) 카드도 표현 가능 (Candidate.isBye)
//
// 흐름:
//   RoundSelectionScreen → startTournament(...) 호출
//   → TournamentScreen에서 currentPair/round 정보 표시
//   → 사용자가 카드 선택 → 애니메이션 → provider.pickWinner()
//   → 최종 우승자 확정 시 WinnerScreen으로 이동
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:teamproject/model/candidate.dart';
import 'package:teamproject/widgets/gradient_background.dart';
import 'package:teamproject/widgets/logout_button.dart';
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
  bool _navigatedToWinner = false; // WinnerScreen 중복 이동 방지
  bool _isAnimating = false; // 카드 이동/확대 애니메이션 재생 여부
  Candidate? _selected; // 선택된 후보
  bool _isLeftCardSelected = false; // 선택된 후보가 왼쪽 카드인지 여부

  @override
  Widget build(BuildContext context) {
    // RoundSelectionScreen에서 전달된 'rounds' 값 (4/8/16/32)
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final int? rounds = args?['rounds'] as int?;
    final String roundsText = rounds != null ? ' (${rounds}강)' : '';

    return Consumer2<ThemeModeNotifier, TournamentProvider>(
      builder: (context, themeNotifier, provider, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final textColor = isDark ? Colors.white : Colors.black;

        final currentPair = provider.currentPair; // 현재 대결 중인 후보 2명
        final topic = provider.topicTitle; // 주제(예: 강아지, 아이돌 등)

        // 라운드 / 매치 진행 상황 텍스트
        final label = provider.roundLabel; // 예: "16강", "8강" ...
        final pairText = provider.roundPairsTotal > 0
            ? '${provider.currentPairIndexDisplay}/${provider.roundPairsTotal}'
            : '';
        final byeHint = provider.byeThisRound ? ' · 부전승 1명 포함' : '';
        final statusText =
            '($label${pairText.isNotEmpty ? ' $pairText' : ''}$byeHint)';

        // 최종 우승자 확정 → WinnerScreen으로 이동
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
            foregroundColor: textColor,
          ),
          body: GradientBackground(
            child: Stack(
              children: [
                // 상단 중앙: "대결 – 주제" + "(16강 1/8 · 부전승)" 등 상태 표시
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

                // 중앙 카드 영역
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
                              // 현재 매치업(좌/우 카드) 애니메이션 전환
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
                                          // 부전승 카드라면 안내용 카드 표시
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

                              // 카드 선택 후 확대 + 이동 애니메이션 (승자 강조)
                              if (_selected != null && _isAnimating)
                                PickWinnerAnimator(
                                  candidate: _selected!,
                                  isLeftCard: _isLeftCardSelected,
                                  onAnimationComplete: () {
                                    // 애니메이션 끝 → 승자 처리
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
              const Positioned(
                top: 16,
                left: 16,
                child: LogoutButton(),
              ),
              const Positioned(
                top: 16,
                right: 16,
                child: DarkModeToggle(),
              ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 카드 선택 시 호출
  void _onSelect(TournamentProvider provider, Candidate candidate) {
    if (_isAnimating) return;
    if (candidate.isBye) return; // 부전승 카드 클릭 방지

    final currentPair = provider.currentPair;
    // 왼쪽 카드인지 여부 계산
    final isLeft = currentPair.isNotEmpty && currentPair[0] == candidate;

    setState(() {
      _selected = candidate;
      _isAnimating = true;
      _isLeftCardSelected = isLeft;
    });
  }
}

// ---------------------------------------------------------------------------
// 부전승 카드 전용 UI
// ---------------------------------------------------------------------------
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
