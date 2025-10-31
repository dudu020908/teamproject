import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamproject/model/candidate.dart';
import 'package:teamproject/widgets/pick_winner_card.dart';

import '../providers/tournament_provider.dart';

class TournamentScreen extends StatelessWidget {
  const TournamentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map?;
    final topic = (args?['topic'] as String?) ?? '주제 없음';
    final cands =
        (args?['candidates'] as List<Candidate>?) ?? const <Candidate>[];

    return ChangeNotifierProvider(
      create: (_) => TournamentProvider(cands),
      child: Scaffold(
        appBar: AppBar(title: Text('대결 – $topic')),
        body: Consumer<TournamentProvider>(
          builder: (_, p, __) {
            if (p.state == TournamentState.finished) {
              final w = p.winner!;
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    WinnerCard(title: w.title, imageUrl: w.imageUrl),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        '/result',
                        arguments: {'topic': topic, 'winner': w},
                      ),
                      child: const Text('결과 화면'),
                    ),
                    TextButton(onPressed: p.reset, child: const Text('다시 하기')),
                  ],
                ),
              );
            }

            final left = p.left, right = p.right;
            if (left == null || right == null) {
              return const Center(child: CircularProgressIndicator());
            }
            return Row(
              children: [
                Expanded(
                  child: PickCard(
                    title: left.title,
                    imageUrl: left.imageUrl,
                    onTap: p.chooseLeft,
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: PickCard(
                    title: right.title,
                    imageUrl: right.imageUrl,
                    onTap: p.chooseRight,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
