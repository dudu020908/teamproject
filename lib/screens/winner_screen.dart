import 'package:flutter/material.dart';
import 'package:teamproject/model/candidate.dart';
import 'package:teamproject/widgets/pick_winner_card.dart';

class WinnerScreen extends StatelessWidget {
  const WinnerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map?;
    final topic = (args?['topic'] as String?) ?? '주제 없음';
    final winner = args?['winner'] as Candidate?;

    return Scaffold(
      appBar: AppBar(title: const Text('결과'), automaticallyImplyLeading: false),
      body: Center(
        child: winner == null
            ? const Text('우승자 없음')
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '주제: $topic',
                    style: Theme.of(context).textTheme.titleMedium,
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
                    child: const Text('다른 주제 선택'),
                  ),
                ],
              ),
      ),
    );
  }
}
