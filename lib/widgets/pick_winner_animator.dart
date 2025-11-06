import 'package:flutter/material.dart';
import 'package:teamproject/model/candidate.dart';
import 'pick_winner_card.dart';

class PickWinnerAnimator extends StatefulWidget {
  final Candidate candidate;
  final VoidCallback onAnimationComplete;
  // 이 카드가 원래 왼쪽(true)에 있었는지 오른쪽(false)에 있었는지 명시적으로 받습니다.
  final bool isLeftCard;

  const PickWinnerAnimator({
    super.key,
    required this.candidate,
    required this.onAnimationComplete,
    required this.isLeftCard,
  });

  @override
  State<PickWinnerAnimator> createState() => _PickWinnerAnimatorState();
}

class _PickWinnerAnimatorState extends State<PickWinnerAnimator>
    with TickerProviderStateMixin {
  // 여러 애니메이션 트랙(이동/확대/페이드)을 동기화
  late final AnimationController _controller;
  // 카드 확대(스케일) 애니메이션
  late final Animation<double> _scaleAnim;
  // 카드 페이드아웃(투명도) 애니메이션
  late final Animation<double> _fadeAnim;
  // 카드 이동(좌우 + 위로 살짝) 애니메이션
  late final Animation<Offset> _moveAnim;

  @override
  void initState() {
    super.initState();

    // 애니메이션 전체 재생 시간 설정 (동기화 기준)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // 카드가 살짝 커지며 강조되는 효과
    _scaleAnim = Tween(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    // 카드가 점점 사라지는 효과
    _fadeAnim = Tween(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    // 원래 위치가 왼쪽이면 오른쪽으로, 오른쪽이면 왼쪽으로 중앙으로 이동
    final direction = widget.isLeftCard ? 1.0 : -1.0;

    _moveAnim = Tween<Offset>(
      begin: const Offset(0, 0),
      end: Offset(direction * 0.3, -0.2), 
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    // 애니메이션이 완료되면 onAnimationComplete 콜백 호출
    _controller.forward().then((_) => widget.onAnimationComplete());
  }

  @override
  void dispose() {
    // 컨트롤러는 반드시 해제하여 메모리 누수 방지
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Stack의 중앙에 배치되지만, SlideTransition으로 원래 위치에서 시작하는 것처럼 보이게 함
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _moveAnim,
        child: ScaleTransition(
          scale: _scaleAnim,
          child: PickCard(
            title: widget.candidate.title,
            imageUrl: widget.candidate.imageUrl,
            onTap: () {},
          ),
        ),
      ),
    );
  }
}
