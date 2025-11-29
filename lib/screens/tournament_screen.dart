import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:teamproject/model/candidate.dart';
import 'package:teamproject/widgets/gradient_background.dart';
import 'package:teamproject/widgets/pick_winner_card.dart';
import 'package:teamproject/widgets/pick_winner_animator.dart';
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
    // 라운드 정보
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final int? rounds = args?['rounds'] as int?;
    final String roundsText = rounds != null ? ' ($rounds강)' : '';

    final provider = context.watch<TournamentProvider>();
    final scheme = Theme.of(context).colorScheme;
    final textColor = scheme.onSurface;

    final currentPair = provider.currentPair;
    final topic = provider.topicTitle;

    final label = provider.roundLabel;
    final currentIndex = provider.currentPairIndexDisplay;
    final totalPairs = provider.roundPairsTotal;
    final pairText = totalPairs > 0 ? '$currentIndex/$totalPairs' : '';
    final byeHint = provider.byeThisRound ? ' · 부전승 1명 포함' : '';
    final statusText =
        '($label${pairText.isNotEmpty ? ' $pairText' : ''}$byeHint)';

    // 우승자 확정 → Winner로 이동
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
        actions: const [DarkModeToggle(), SizedBox(width: 4)],
      ),
      body: GradientBackground(
        child: Stack(
          children: [
            // 상단 텍스트
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
                      color: textColor.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),

            // 카드 영역
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
                    : AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) =>
                            FadeTransition(opacity: animation, child: child),
                        child: _isAnimating
                            ? const SizedBox.shrink(key: ValueKey('gap'))
                            : Row(
                                key: ValueKey(
                                  currentPair.map((c) => c.title).join(','),
                                ),
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: currentPair.map((candidate) {
                                  if (candidate.isBye) {
                                    return Expanded(
                                      child: _ByeCard(scheme: scheme),
                                    );
                                  }

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
              ),
            ),

            // 승자 애니메이션
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
          ],
        ),
      ),
    );
  }

  // 카드 선택 시 호출
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

class _ByeCard extends StatelessWidget {
  final ColorScheme scheme;
  const _ByeCard({required this.scheme});

  @override
  Widget build(BuildContext context) {
    final bg = scheme.surfaceVariant.withValues(
      alpha: scheme.brightness == Brightness.dark ? 0.8 : 0.95,
    );
    final border = scheme.outlineVariant;
    final textColor = scheme.onSurfaceVariant;

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
