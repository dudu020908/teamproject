import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:teamproject/main.dart';
import 'package:teamproject/model/candidate.dart';
import 'package:teamproject/service/local_storage_service.dart';
import 'package:teamproject/widgets/dark_mode_toggle.dart';
import 'package:teamproject/widgets/gradient_background.dart';
import 'package:teamproject/widgets/pick_winner_card.dart';

class WinnerScreen extends StatefulWidget {
  static const String missingArgumentMessage = '필요한 결과 정보를 찾지 못했습니다.';

  const WinnerScreen({super.key});

  @override
  State<WinnerScreen> createState() => _WinnerScreenState();
}

class _WinnerScreenState extends State<WinnerScreen> {
  bool _saved = false; // 로컬 저장 중복 방지

  String? _topic;
  Candidate? _winnerCandidate;
  String? _loadError;

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
    if (winner.types.isEmpty) {
      return "나만의 취향이 확실하시네요 😎";
    }
    final mainType = winner.types.first;
    return typeComments[mainType] ??
        "나만의 취향이 확실하시네요 😎 (타입: $mainType)";
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _initializeFromRouteArguments());
  }

  Future<void> _initializeFromRouteArguments() async {
    try {
      final route = ModalRoute.of(context);
      final args = route?.settings.arguments;

      if (args is! Map) {
        setState(() => _loadError = WinnerScreen.missingArgumentMessage);
        return;
      }

      final topic = args['topic'];
      final winner = args['winner'];

      if (topic is! String || winner is! Candidate) {
        setState(() => _loadError = WinnerScreen.missingArgumentMessage);
        return;
      }

      setState(() {
        _topic = topic;
        _winnerCandidate = winner;
      });

      await _saveLocalResult(topic: topic, winner: winner);
    } catch (e, s) {
      debugPrint('WinnerScreen args load failed: $e\n$s');
      if (mounted) {
        setState(() => _loadError = '결과 정보를 불러오지 못했습니다.');
      }
    }
  }

  // 로컬 저장: SharedPreferences(LocalStorageService)
  Future<void> _saveLocalResult({
    required String topic,
    required Candidate winner,
  }) async {
    if (_saved) return;

    try {
      await LocalStorageService.saveResult(topic, winner.title)
          .timeout(const Duration(seconds: 3));

      if (mounted) {
        setState(() => _saved = true);
      }
    } on TimeoutException catch (e, s) {
      debugPrint('Saving local result timed out: $e\n$s');
    } catch (e, s) {
      debugPrint('Failed to save local result: $e\n$s');
    }
  }

  // 결과 카드 캡처 + 이미지 공유
  Future<void> _captureAndShareResultCard({
    required String topic,
    required Candidate winner,
    required String comment,
  }) async {
    try {
      final boundary =
          _resultCardKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) {
        debugPrint('RepaintBoundary not found');
        return;
      }

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final Uint8List pngBytes = byteData.buffer.asUint8List();

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/worldcup_result.png');
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text:
            '이상형 월드컵 결과\n\n주제: $topic\n최종 선택: ${winner.title}\n$comment',
      );
    } catch (e, s) {
      debugPrint('Error capturing and sharing result card: $e\n$s');
    }
  }

  // UI
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // 뒤로가기 강제 차단 + /home 이동
      onWillPop: () async {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        return false;
      },
      child: Consumer<ThemeModeNotifier>(
        builder: (context, tm, __) {
          final scheme = Theme.of(context).colorScheme;
          final isDark = scheme.brightness == Brightness.dark;

          final topic = _topic;
          final winner = _winnerCandidate;
          final comment = winner != null
              ? _buildTypeComment(winner)
              : '결과 정보를 준비 중입니다.';

          // 에러 화면
          if (_loadError != null) {
            return Scaffold(
              extendBodyBehindAppBar: true,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                actions: const[DarkModeToggle(),SizedBox(width: 4,)],
                title: Text(
                  "최종 결과",
                  style: TextStyle(color: scheme.onBackground),
                ),
                centerTitle: true,
                leading: IconButton(
                  icon: Icon(
                    Icons.home,
                    color: scheme.onBackground,
                  ),
                  tooltip: '홈으로 이동',
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
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: scheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _loadError!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: scheme.onBackground,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/home',
                              (route) => false,
                            );
                          },
                          child: const Text('홈으로 돌아가기'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          // 아직 인자 로딩 중
          if (topic == null || winner == null) {
            return Scaffold(
              body: GradientBackground(
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(scheme.primary),
                  ),
                ),
              ),
            );
          }

          // 정상 화면
          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: const[DarkModeToggle(),SizedBox(width: 4,)],
              title: Text(
                "최종 결과",
                style: TextStyle(color: scheme.onBackground),
              ),
              centerTitle: true,
              leading: IconButton(
                icon: Icon(
                  Icons.home,
                  color: scheme.onBackground,
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

                          // 캡처 영역 (제목 + 카드 + 코멘트 + 최종 선택)
                          RepaintBoundary(
                            key: _resultCardKey,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              // 공유용 이미지는 배경 고정(라이트/다크에 따라 색만 조정)
                              color: isDark ? Colors.black : Colors.white,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
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

                                  FractionallySizedBox(
                                    widthFactor: 0.85,
                                    child: PickCard(
                                      title: winner.title,
                                      imageUrl: winner.imageUrl,
                                      onTap: () {},
                                    ),
                                  ),
                                  const SizedBox(height: 16),

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

                          // 결과 공유하기
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
