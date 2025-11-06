import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamproject/model/candidate.dart';
import 'package:teamproject/providers/tournament_provider.dart';
import 'package:teamproject/widgets/gradient_background.dart';

class TopicScreen extends StatelessWidget {
  const TopicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<TournamentProvider>();

    final Map<String, List<String>> categories = {
      '동물': ['고양이', '강아지'],
      '디저트': ['디저트'],
      '자동차': ['스포츠카'],
      '자연': ['풍경'],
      '미술': ['클래식 아트'],
    };

    return Scaffold(
      // Scaffold는 투명하게
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('주제 선택'), elevation: 0),
      body: GradientBackground(
        // 배경 감싸기
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final categoryName = categories.keys.elementAt(index);
            final topics = categories[categoryName]!;

            return Card(
              color: Colors.white.withOpacity(0.85),
              elevation: 5,
              margin: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ExpansionTile(
                leading: _categoryIcon(categoryName),
                title: Text(
                  categoryName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                children: topics.map((topic) {
                  return ListTile(
                    title: Text(topic),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: () {
                      final candidates = samplesForTopic(topic);
                      provider.setTopic(topic, candidates);
                      Navigator.pushNamed(
                        context,
                        '/rounds',
                        arguments: {
                          'topic': topic,
                          'emoji': _emojiForCategory(categoryName),
                        },
                      );
                    },
                  );
                }).toList(),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _categoryIcon(String category) {
    switch (category) {
      case '동물':
        return const Icon(Icons.pets, color: Colors.orangeAccent);
      case '디저트':
        return const Icon(Icons.cake, color: Colors.pinkAccent);
      case '자동차':
        return const Icon(Icons.directions_car, color: Colors.blueAccent);
      case '자연':
        return const Icon(Icons.landscape, color: Colors.green);
      case '미술':
        return const Icon(Icons.palette, color: Colors.deepPurpleAccent);
      default:
        return const Icon(Icons.category);
    }
  }

  String _emojiForCategory(String category) {
    switch (category) {
      case '동물':
        return '🐶';
      case '디저트':
        return '🍰';
      case '자동차':
        return '🏎️';
      case '자연':
        return '🌿';
      case '미술':
        return '🎨';
      default:
        return '💫';
    }
  }
}
