import 'package:flutter/material.dart';
import 'package:teamproject/model/candidate.dart';

class TopicScreen extends StatelessWidget {
  const TopicScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('주제 선택')),
    body: ListView.separated(
      itemCount: topics.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final t = topics[i];
        return ListTile(
          title: Text(t),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            final cands = samplesForTopic(t);
            Navigator.pushNamed(
              context,
              '/play',
              arguments: {'topic': t, 'candidates': cands},
            );
          },
        );
      },
    ),
  );
}
