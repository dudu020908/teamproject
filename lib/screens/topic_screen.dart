import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import 'package:teamproject/widgets/gradient_background.dart';
import 'package:teamproject/widgets/dark_mode_toggle.dart';
import 'package:teamproject/widgets/logout_button.dart';
import 'package:teamproject/main.dart';
import 'CreateWorldcupScreen.dart';

class TopicScreen extends StatelessWidget {
  const TopicScreen({super.key});

  // 🔹 worldcups 컬렉션 스트림 (isDraft 필드 쓰면 where 로 필터해도 됨)
  Stream<QuerySnapshot> get categoriesStream => FirebaseFirestore.instance
      .collection("categories")
      .orderBy("createdAt", descending: true)
      .snapshots();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단 바 (뒤로가기, 다크모드, 로그아웃 등)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [LogoutButton(), DarkModeToggle()],
                ),
              ),

              const SizedBox(height: 8),

              // 제목
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "어떤 월드컵을 해볼까요?",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "원하는 이상형 월드컵을 선택해주세요",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 월드컵 카드 그리드
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: categoriesStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          "월드컵 목록을 불러오는 중 오류가 발생했어요.",
                          style: TextStyle(
                            color: isDark ? Colors.red[200] : Colors.red[800],
                          ),
                        ),
                      );
                    }
                    final docs = snapshot.data?.docs ?? [];

                    if (docs.isEmpty) {
                      return const Center(
                        child: Text(
                          "아직 생성된 월드컵이 없어요.\n아래 버튼으로 새 월드컵을 만들어보세요!",
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: GridView.builder(
                        itemCount: docs.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1,
                            ),
                        itemBuilder: (context, index) {
                          final doc = docs[index];
                          final data = doc.data() as Map<String, dynamic>;

                          final title = data['title'] ?? "제목 없음";
                          final emoji = data['emoji'] ?? "🏆";
                          final imageUrl = data['imageUrl'] ?? "";

                          return _WorldcupCard(
                            title: title,
                            emoji: emoji,
                            imageUrl: imageUrl,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/roundselection',
                                arguments: {
                                  'categoryId': doc.id,
                                  'title': title,
                                  'emoji': emoji,
                                },
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
              ),

              // 하단: 월드컵 생성 버튼
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text(
                      "월드컵 생성하기",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF5C8D),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/createworldcup');
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorldcupCard extends StatelessWidget {
  final String title;
  final String emoji;
  final String imageUrl;
  final VoidCallback onTap;

  const _WorldcupCard({
    required this.title,
    required this.emoji,
    required this.onTap,
    this.imageUrl = "",
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 🔹 사진 전체 배경
            if (imageUrl.isNotEmpty)
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => Container(
                  color: isDark ? const Color(0xFF2C3E50) : Colors.grey[300],
                  child: const Icon(Icons.image_not_supported),
                ),
              )
            else
              Container(
                color: isDark ? const Color(0xFF2C3E50) : Colors.grey[300],
              ),

            // 🔹 아래에서 위로 올라가는 어두운 그라디언트
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.65),
                    Colors.black.withOpacity(0.20),
                    Colors.transparent,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),

            // 🔹 이모지 + 제목
            Align(
              alignment: const Alignment(0, 0.35),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 🔥 이모지 강조를 위한 반투명 원형 배경
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.35), // 배경
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      emoji,
                      style: const TextStyle(
                        fontSize: 32, // ← 크기 키움
                        shadows: [Shadow(color: Colors.black54, blurRadius: 6)],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 5,
                          color: Colors.black87,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
