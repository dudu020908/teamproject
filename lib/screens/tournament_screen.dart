import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamproject/model/candidate.dart';
import 'package:teamproject/widgets/gradient_background.dart';
import 'package:teamproject/widgets/pick_winner_animator.dart';
import 'package:teamproject/widgets/pick_winner_card.dart';

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
    return Consumer<TournamentProvider>(
      builder: (context, provider, child) {
        final currentPair = provider.currentPair;
        final topic = provider.topicTitle; // 현재 주제 이름

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
          appBar: AppBar(
            title: Text('대결 – $topic'),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: Colors.black,
          ),
          body: GradientBackground(
            child: Center(
              child: provider.hasWinner
                  ? const SizedBox.shrink()
                  : currentPair.isEmpty
                  ? const Text("후보가 없습니다")
                  : Stack(
                      alignment: Alignment.center,
                      children: [
                        // 두 카드 (AnimatedSwitcher로 전환)
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 600),
                          transitionBuilder: (child, anim) {
                            // 다음 라운드 카드가 튀어나오는 애니메이션
                            return ScaleTransition(
                              scale: CurvedAnimation(
                                parent: anim,
                                curve: Curves.elasticOut,
                              ),
                              child: child,
                            );
                          },
                          child: _isAnimating
                            ? const SizedBox.shrink(key: ValueKey('gap'))
                            : Row(
                              key: ValueKey(
                                // AnimatedSwitcher가 다음 라운드로 전환되게 하는 Key
                                currentPair.map((c) => c.title).join(','),
                              ),
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: currentPair.map((candidate) {
                                // 선택되지 않은 카드는 사라지도록 처리
                                
                                return Expanded(
                                  child: AnimatedScale(
                                    // 선택된 카드를 살짝 축소시켜서 강조하는 효과
                                    scale: _selected == candidate ? 0.95 : 1.0,
                                    duration: const Duration(
                                      milliseconds: 150,
                                    ),
                                    child: PickCard(
                                      title: candidate.title,
                                      imageUrl: candidate.imageUrl,
                                      onTap: _isAnimating
                                        ? () {} // 애니메이션 중에는 탭 무시
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
                          // 선택된 카드 애니메이터
                          if (_selected != null && _isAnimating)
                            PickWinnerAnimator(
                              candidate: _selected!,
                              // isLeftCard 정보 전달
                              isLeftCard: _isLeftCardSelected,
                              onAnimationComplete: () {
                                // 애니메이션이 끝나면 다음 라운드로 넘어가기 위한 로직 실행
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
    // 선택된 카드가 currentPair의 첫 번째 요소(왼쪽)인지 확인
    final isLeft = currentPair.isNotEmpty && currentPair[0] == candidate;

    setState(() {
      _selected = candidate;
      _isAnimating = true;
      _isLeftCardSelected = isLeft; // 상태 저장
    });
  }
}
