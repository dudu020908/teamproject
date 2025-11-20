import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamproject/model/candidate.dart';
import 'package:teamproject/service/local_storage_service.dart';
import 'package:teamproject/widgets/gradient_background.dart';
import 'package:teamproject/widgets/dark_mode_toggle.dart';
import 'package:teamproject/widgets/logout_button.dart';
import 'package:teamproject/widgets/pick_winner_card.dart';
import 'package:teamproject/main.dart';

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class WinnerScreen extends StatefulWidget {
  const WinnerScreen({super.key});

  @override
  State<WinnerScreen> createState() => _WinnerScreenState();
}

class _WinnerScreenState extends State<WinnerScreen> {
  bool _saved = false; // 로컬 저장 중복 방지

  // 결과 카드 캡처용 키
  final GlobalKey _resultCardKey = GlobalKey();

  static const Map<String, String> typeComments = {
    "감성형": "오, 감성적인 타입이시네요. 감정과 분위기를 중시하는 스타일!",
    "이성형": "이성적인 타입이시네요. 늘 합리적으로 판단하는 편인가요?",
    "현실형": "매우 현실적인 타입! 이상보단 현실을 중시하는 스타일 같아요.",
    "이상형": "이상형 지향! 머릿속에 그리던 완벽한 이미지가 확실하신가 봐요.",
    "개성형": "개성 있는 타입! 남들이 뭐라 해도 내 취향은 내가 정한다 🔥",
    "트렌디형": "트렌디한 선택! 유행에 누구보다 빠른 감각파네요.",
    "안정형": "안정적인 타입이시군요. 편안함과 안정감을 중요하게 생각하시는 듯!",
    "자극형": "자극적인 스타일! 강렬한 매력과 임팩트를 좋아하는 타입이에요.",
  };

  String _buildTypeComment(Candidate winner) {
    // winner.types 가 비어있으면 기본 멘트
    if (winner.types.isEmpty) {
      return "나만의 취향이 확실하시네요 😎";
    }

    final mainType = winner.types.first;
    return typeComments[mainType] ?? "나만의 취향이 확실하시네요 😎 (타입: $mainType)";
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _saveLocalResult());
  }

  // 로컬 저장: SharedPreferences(LocalStorageService)
  Future<void> _saveLocalResult() async {
    if (_saved) return;

    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final topic = args['topic'] as String;
    final winner = args['winner'] as Candidate;

    await LocalStorageService.saveResult(topic, winner.title);

    setState(() => _saved = true);
  }

  // 결과 카드 캡처 + 이미지 공유
  Future<void> _captureAndShareResultCard({
    required String topic,
    required Candidate winner,
    required String comment,
  }) async {
    try {
      // 1) RepaintBoundary로 감싼 영역을 RenderRepaintBoundary로 가져온다.
      final boundary =
          _resultCardKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) {
        debugPrint('RepaintBoundary not found');
        return;
      }

      // 2) 위젯을 이미지로 렌더링
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final Uint8List pngBytes = byteData.buffer.asUint8List();

      // 3) 임시 디렉토리에 파일로 저장
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/worldcup_result.png');
      await file.writeAsBytes(pngBytes);

      // 4) share_plus로 이미지 + 텍스트 공유
      await Share.shareXFiles([
        XFile(file.path),
      ], text: '이상형 월드컵 결과\n\n주제: $topic\n최종 선택: ${winner.title}\n$comment');
    } catch (e, s) {
      debugPrint('Error capturing and sharing result card: $e\n$s');
    }
  }

  // UI
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final topic = args['topic'] as String;
    final winner = args['winner'] as Candidate;

    final comment = _buildTypeComment(winner);

    return WillPopScope(
      // 뒤로가기 강제 차단 + /home 이동
      onWillPop: () async {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        return false;
      },
      child: Consumer<ThemeModeNotifier>(
        builder: (_, tm, __) {
          final isDark = Theme.of(context).brightness == Brightness.dark;

          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: const Text("최종 결과"),
              centerTitle: true,
              leading: IconButton(
                icon: Icon(
                  Icons.home,
                  color: isDark ? Colors.white : Colors.black,
                ),
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/home',
                    (route) => false,
                  );
                },
              ),
            ),
            body: GradientBackground(
              child: Stack(
                children: [
                  const Positioned(top: 16, left: 16, child: LogoutButton()),
                  const Positioned(top: 16, right: 16, child: DarkModeToggle()),
                  Positioned.fill(
                    top: 60,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 32,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),

                          //이미지로 캡처 (제목 + 카드 + 코멘트 + 최종 선택)
                          RepaintBoundary(
                            key: _resultCardKey,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              color: isDark ? Colors.black : Colors.white,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // 주제 텍스트
                                  Text(
                                    "주제: $topic",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),

                                  const SizedBox(height: 24),

                                  // Winner 카드 - 자동 너비 조절
                                  FractionallySizedBox(
                                    widthFactor: 0.85,
                                    child: PickCard(
                                      title: winner.title,
                                      imageUrl: winner.imageUrl,
                                      onTap: () {},
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // 타입 분석 코멘트
                                  Text(
                                    comment,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black87,
                                    ),
                                  ),

                                  const SizedBox(height: 24),

                                  Text(
                                    "당신의 최종 선택! : ${winner.title}",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // 요약 보기 → 결과 공유하기 버튼
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                _captureAndShareResultCard(
                                  topic: topic,
                                  winner: winner,
                                  comment: comment,
                                );
                              },
                              child: const Text("결과 공유 하기"),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // 다시 하기 → topics 이동
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  '/topics',
                                  (route) => false,
                                );
                              },
                              child: const Text("다시 하기"),
                            ),
                          ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
