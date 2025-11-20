import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:teamproject/widgets/gradient_background.dart';
import 'package:teamproject/widgets/dark_mode_toggle.dart';
import 'package:teamproject/widgets/logout_button.dart';

class WorldcupListScreen extends StatelessWidget {
  const WorldcupListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final categoryId = args['categoryId'];
    final categoryTitle = args['title'];
    final emoji = args['emoji'];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("$emoji $categoryTitle"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: GradientBackground(
        child: Stack(
          children: [
            const Positioned(top: 16, left: 16, child: LogoutButton()),
            const Positioned(top: 16, right: 16, child: DarkModeToggle()),
            // 월드컵 리스트
            Positioned.fill(
              top: 60,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("worldcups")
                    .where("categoryId", isEqualTo: categoryId)
                    .orderBy("createdAt", descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.pinkAccent,
                      ),
                    );
                  }

                  final docs = snapshot.data!.docs;

                  if (docs.isEmpty) {
                    return const Center(
                      child: Text(
                        "아직 생성된 월드컵이 없습니다.",
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final wc = docs[index].data() as Map<String, dynamic>;
                      final wcId = docs[index].id;

                      // 월드컵 카드
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          leading: Text(
                            wc["categoryEmoji"],
                            style: const TextStyle(fontSize: 28),
                          ),
                          title: Text(wc["title"]),
                          subtitle: wc["description"] != ""
                              ? Text(wc["description"])
                              : null,
                          trailing: const Icon(Icons.chevron_right),

                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/roundselection',
                              arguments: {
                                'worldcupId': wcId,
                                'categoryId': categoryId,
                                'title': wc["title"],
                                'emoji': wc["categoryEmoji"],
                              },
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
