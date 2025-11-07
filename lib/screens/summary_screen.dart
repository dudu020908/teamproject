import 'package:flutter/material.dart';
import 'package:teamproject/service/local_storage_service.dart';
import 'package:teamproject/widgets/gradient_background.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  Map<String, dynamic>? userInfo;
  Map<String, dynamic>? result;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    final info = await LocalStorageService.loadUserInfo();
    final res = await LocalStorageService.loadResult();
    setState(() {
      userInfo = info;
      result = res;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Center(
          child: userInfo == null || result == null
              ? const Text("저장된 데이터가 없습니다.")
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "📦 최근 저장된 결과",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text("성별: ${userInfo!['gender']}"),
                    Text("나이: ${userInfo!['age']}세"),
                    const SizedBox(height: 20),
                    Text("주제: ${result!['topic']}"),
                    Text("최종 선택: ${result!['winner']}"),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/topics'),
                      child: const Text("새로운 주제 시작하기"),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () async {
                        await LocalStorageService.clearAll();
                        if (mounted) {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/userinfo',
                            (route) => false,
                          );
                        }
                      },
                      child: const Text("저장된 데이터 초기화"),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
