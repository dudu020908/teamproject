import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamproject/widgets/pick_winner_card.dart';

import '../providers/tournament_provider.dart';

class TournamentScreen extends StatefulWidget {
  const TournamentScreen({super.key});

  @override
  State<TournamentScreen> createState() => _TournamentScreenState();
}

class _TournamentScreenState extends State<TournamentScreen> {
  bool _navigatedToWinner = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<TournamentProvider>(
      builder: (context, provider, child) {
        final currentPair = provider.currentPair;
        final topic = provider.topicTitle; // 현재 주제 이름

        // 우승자 확정 시
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
          appBar: AppBar(title: Text('대결 – $topic'), centerTitle: true),
          body: Center(
            child: provider.hasWinner
                ? const SizedBox.shrink()
                : currentPair.isEmpty
                ? const Text("후보가 없습니다")
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: currentPair.map((candidate) {
                      return Expanded(
                        child: PickCard(
                          title: candidate.title,
                          imageUrl: candidate.imageUrl,
                          onTap: () {
                            provider.pickWinner(candidate);
                          },
                        ),
                      );
                    }).toList(),
                  ),
          ),
        );
      },
    );
  }
}
