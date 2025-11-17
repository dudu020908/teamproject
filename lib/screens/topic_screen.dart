import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:teamproject/widgets/gradient_background.dart';
import 'package:teamproject/widgets/dark_mode_toggle.dart';
import 'package:teamproject/main.dart';
import 'package:teamproject/service/local_storage_service.dart';
import 'package:teamproject/widgets/logout_button.dart';

class TopicScreen extends StatelessWidget {
  const TopicScreen({super.key});

  Stream<QuerySnapshot> get categoriesStream =>
      FirebaseFirestore.instance.collection("categories").snapshots();

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModeNotifier>(
      builder: (context, themeNotifier, _) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Scaffold(
          body: GradientBackground(
            child: Stack(
              children: [
                // 카테고리 목록 전체 레이아웃
                _buildCategoryList(context, isDark),

                const LogoutButton(), // 좌상단 로그아웃 버튼
                const DarkModeToggle(), // 우상단 다크모드 버튼

                // 화면 맨 아래 월드컵 생성하기 버튼
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 30,
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
                        Navigator.pushNamed(
                          context,
                          "/createworldcup",
                          arguments: null,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 카테고리 목록 UI
  Widget _buildCategoryList(BuildContext context, bool isDark) {
    return StreamBuilder<QuerySnapshot>(
      stream: categoriesStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.pinkAccent),
          );
        }

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return const Center(
            child: Text("등록된 카테고리가 없습니다.", style: TextStyle(fontSize: 18)),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),

              Text(
                "어떤 월드컵을 해볼까요?",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                "원하는 카테고리를 선택해주세요",
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),

              const SizedBox(height: 24),

              Expanded(
                child: GridView.builder(
                  itemCount: docs.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final docId = docs[index].id;

                    return _buildCategoryTile(
                      context,
                      categoryId: docId,
                      title: data["title"],
                      emoji: data["emoji"],
                      imageUrl: data["imageUrl"],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 카테고리 타일 UI
  Widget _buildCategoryTile(
    BuildContext context, {
    required String categoryId,
    required String title,
    required String emoji,
    required String imageUrl,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          "/category_worldcups",
          arguments: {"categoryId": categoryId, "title": title, "emoji": emoji},
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(imageUrl, fit: BoxFit.cover),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.55), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 36)),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    textAlign: TextAlign.center,
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
      ),
    );
  }
}
