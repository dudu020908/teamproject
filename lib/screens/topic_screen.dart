import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamproject/model/candidate.dart';
import 'package:teamproject/providers/tournament_provider.dart';
import 'package:teamproject/widgets/gradient_background.dart';
import 'package:teamproject/widgets/dark_mode_toggle.dart';
import 'package:teamproject/main.dart';

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

    // Consumer로 감싸서 다크모드 즉시 반영
    return Consumer<ThemeModeNotifier>(
      builder: (context, themeNotifier, _) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final textColor = isDark ? Colors.white : Colors.black87;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: GradientBackground(
            child: Stack(
              children: [
                ListView.builder(
                  padding: const EdgeInsets.only(
                    top: 140,
                    bottom: 16,
                    left: 12,
                    right: 12,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final categoryName = categories.keys.elementAt(index);
                    final topics = categories[categoryName]!;

                    return Card(
                      color: isDark
                          ? Colors.grey[850]
                          : Colors.white.withOpacity(0.85),
                      elevation: 5,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ExpansionTile(
                        leading: _categoryIcon(categoryName),
                        title: Text(
                          categoryName,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        children: topics.map((topic) {
                          return ListTile(
                            title: Text(
                              topic,
                              style: TextStyle(color: textColor),
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 18,
                              color: textColor,
                            ),
                            onTap: () {
                              final candidates = samplesForTopic(topic);
                              provider.setTopic(topic, candidates);
                              Navigator.pushNamed(
                                context,
                                '/roundselection',
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

                // 상단 안내 문구
                Positioned(
                  top: 40,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "어떤 월드컵을 해볼까요?",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "원하는 카테고리를 선택해주세요",
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),

                // 상단 다크모드 토글 버튼
                const DarkModeToggle(),
              ],
            ),
          ),
        );
      },
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
