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
    final String roundsText = rounds != null ? ' (${rounds}강)' : '';

    return Consumer2<ThemeModeNotifier, TournamentProvider>(
      builder: (context, themeNotifier, provider, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final textColor = isDark ? Colors.white : Colors.black;

        final currentPair = provider.currentPair;
        final topic = provider.topicTitle;

        // UI에 쓸 라벨
        final label = provider.roundLabel;
        final pairText = provider.roundPairsTotal > 0
            ? '${provider.currentPairIndexDisplay}/${provider.roundPairsTotal}'
            : '';
        final byeHint = provider.byeThisRound ? ' · 부전승 1명 포함' : '';
        final statusText =
            '($label${pairText.isNotEmpty ? ' $pairText' : ''}$byeHint)';

        // 우승 후 결과 이동
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

            // 2줄 제목 적용
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
            child: SizedBox.expand(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (provider.hasWinner)
                    const SizedBox.shrink()
                  else if (currentPair.isEmpty)
                    Center(
                      child: Text(
                        "후보가 없습니다",
                        style: TextStyle(color: textColor, fontSize: 18),
                      ),
                    )
                  else
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return SizedBox(
                          height: constraints.maxHeight,
                          width: constraints.maxWidth,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 600),
                                transitionBuilder: (child, anim) =>
                                    ScaleTransition(
                                      scale: CurvedAnimation(
                                        parent: anim,
                                        curve: Curves.elasticOut,
                                      ),
                                      child: child,
                                    ),
                                child: _isAnimating
                                    ? const SizedBox.shrink(
                                        key: ValueKey('animating'),
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
                        );
                      },
                    ),

                  const DarkModeToggle(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _onSelect(
    TournamentProvider provider,
    Candidate candidate,
  ) async {
    if (_isAnimating) return;

    final currentPair = provider.currentPair;
    final isLeft = currentPair.isNotEmpty && currentPair[0] == candidate;

    setState(() {
      _selected = candidate;
      _isAnimating = true;
      _isLeftCardSelected = isLeft;
    });
  }
}
