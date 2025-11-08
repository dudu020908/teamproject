import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamproject/widgets/gradient_background.dart';
import 'package:teamproject/widgets/dark_mode_toggle.dart';
import 'package:teamproject/main.dart';

class TopicScreen extends StatefulWidget {
  const TopicScreen({super.key});

  @override
  State<TopicScreen> createState() => _TopicScreenState();
}

class _TopicScreenState extends State<TopicScreen> {
  Map<String, dynamic>? selectedCategory; // 현재 선택된 큰 카테고리
  String? selectedSub; // 선택된 세부 항목

  final List<Map<String, dynamic>> categories = [
    {
      'title': '연예인 이상형',
      'emoji': '💘',
      'image':
          'https://images.unsplash.com/photo-1740459057005-65f000db582f?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
      'subtopics': ['아이돌', '배우', '가수', '예능인'],
    },
    {
      'title': '패션 스타일',
      'emoji': '👗',
      'image':
          'https://images.unsplash.com/photo-1567523680125-43c5dae7e2fb?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
      'subtopics': ['스트릿', '캐주얼', '빈티지', '하이패션'],
    },
    {
      'title': '식사 궁합',
      'emoji': '🍖',
      'image':
          'https://images.unsplash.com/photo-1736604522360-608c09900076?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
      'subtopics': ['한식', '양식', '일식', '분식'],
    },
    {
      'title': '반려동물',
      'emoji': '🐶',
      'image':
          'https://images.unsplash.com/photo-1519134991647-f069322dfe22?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
      'subtopics': ['강아지', '고양이', '토끼', '햄스터'],
    },
    {
      'title': '감정 스타일',
      'emoji': '🎨',
      'image':
          'https://images.unsplash.com/photo-1699568542323-ff98aca8ea6a?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
      'subtopics': ['낭만적', '감성적', '유머러스', '차분함'],
    },
    {
      'title': '카페 메뉴',
      'emoji': '☕',
      'image':
          'https://images.unsplash.com/photo-1613187984497-483b0d1df052?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
      'subtopics': ['커피', '디저트', '브런치'],
    },
  ];

  void _startSubtopic(String subtopic) {
    Navigator.pushNamed(
      context,
      '/roundselection',
      arguments: {'topic': subtopic, 'emoji': selectedCategory!['emoji']},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModeNotifier>(
      builder: (context, themeNotifier, _) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final textColor = isDark ? Colors.white : Colors.black87;
        final subTextColor = isDark ? Colors.grey[400] : Colors.grey[600];
        final boxColor = isDark ? Colors.grey[850]! : Colors.white;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: GradientBackground(
            child: SafeArea(
              child: Stack(
                children: [
                  // 전체 컨텐츠 스위치
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    child: selectedCategory == null
                        ? _buildMainCategoryView(
                            textColor,
                            subTextColor,
                            boxColor,
                          )
                        : _buildSubtopicView(textColor, subTextColor, boxColor),
                  ),

                  // 다크모드 토글
                  const DarkModeToggle(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 메인 카테고리
  Widget _buildMainCategoryView(
    Color textColor,
    Color? subTextColor,
    Color boxColor,
  ) {
    return LayoutBuilder(
      key: const ValueKey('mainView'),
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: SizedBox(
              height: constraints.maxHeight,
              child: Column(
                children: [
                  const SizedBox(height: 40),
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
                    style: TextStyle(fontSize: 16, color: subTextColor),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1,
                          ),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return GestureDetector(
                          onTap: () =>
                              setState(() => selectedCategory = category),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: Image.network(
                                  category['image'],
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.black.withOpacity(0.6),
                                      Colors.transparent,
                                    ],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ),
                                ),
                              ),
                              Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      category['emoji'],
                                      style: const TextStyle(fontSize: 36),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      category['title'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 세부 주제 화면
  Widget _buildSubtopicView(
    Color textColor,
    Color? subTextColor,
    Color boxColor,
  ) {
    final subs = selectedCategory!['subtopics'] as List<String>;

    return LayoutBuilder(
      key: const ValueKey('subView'),
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 뒤로가기 버튼
                  IconButton(
                    onPressed: () => setState(() => selectedCategory = null),
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.pinkAccent,
                    ),
                  ),

                  // 헤더
                  Center(
                    child: Column(
                      children: [
                        Text(
                          "${selectedCategory!['emoji']} ${selectedCategory!['title']}",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "세부 주제를 선택해주세요",
                          style: TextStyle(fontSize: 16, color: subTextColor),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),

                  //  세부 항목 리스트
                  ...subs.map(
                    (s) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: boxColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ListTile(
                          title: Text(
                            s,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.pinkAccent,
                            size: 18,
                          ),
                          onTap: () => _startSubtopic(s),
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
