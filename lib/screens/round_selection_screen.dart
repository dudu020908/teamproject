import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:teamproject/widgets/gradient_background.dart';
import 'package:teamproject/widgets/dark_mode_toggle.dart';
import 'package:teamproject/model/candidate.dart';
import 'package:teamproject/widgets/logout_button.dart';
import '../providers/tournament_provider.dart';
import 'package:teamproject/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Firestore에서 후보자 목록을 가져오는 함수
Future<List<Candidate>> fetchCandidates(String worldcupId) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('worldcups')
      .doc(worldcupId)
      .collection('candidates')
      .get();

  return snapshot.docs.map((doc) => Candidate.fromFirestore(doc)).toList();
}

class RoundSelectionScreen extends StatefulWidget {
  final String categoryTitle;
  final String categoryEmoji;

  final String worldcupId;

  const RoundSelectionScreen({
    super.key,
    required this.categoryTitle,
    required this.categoryEmoji,
    required this.worldcupId, // 생성자에 worldcupId 추가
  });

  @override
  State<RoundSelectionScreen> createState() => _RoundSelectionScreenState();
}

class _RoundSelectionScreenState extends State<RoundSelectionScreen> {
  final TextEditingController _controller = TextEditingController();
  int? selectedQuick;
  bool _showHint = true;

  // SnackBar 경고 표시
  void _showSnackBar(String message, bool isDark) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: isDark ? Colors.redAccent[700] : Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  // topic 기반 후보 로딩 → worldcupId 기반으로 변경
  void _handleStart(bool isDark) async {
    final text = _controller.text.trim();
    final num = int.tryParse(text);

    if (num == null || num < 8 || num > 128) {
      _showSnackBar("⚠️ 8~128 사이의 숫자만 입력 가능합니다", isDark);
      return;
    }

    // worldcupId 기준으로 Firestore 후보 조회
    final candidates = await fetchCandidates(widget.worldcupId);

    // 후보 수 부족
    if (candidates.length < num) {
      _showSnackBar(
        "⚠️ 후보 수(${candidates.length}명)가 ${num}강을 진행하기에 부족합니다!",
        isDark,
      );
      return;
    }

    // 후보 섞기
    List<Candidate> selectedCandidates = List.from(candidates);
    selectedCandidates.shuffle();

    if (selectedCandidates.length > num) {
      selectedCandidates = selectedCandidates.take(num).toList();
    }

    // Provider에 설정
    Provider.of<TournamentProvider>(
      context,
      listen: false,
    ).startTournament(widget.categoryTitle, selectedCandidates);

    // 화면 이동
    Navigator.pushNamed(context, '/tournament', arguments: {'rounds': num});
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModeNotifier>(
      builder: (context, themeNotifier, _) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final textColor = isDark ? Colors.white : Colors.black87;
        final subTextColor = isDark ? Colors.grey[400] : Colors.grey[700];
        final boxColor = isDark ? Colors.grey[850] : Colors.white;

        // topic, emoji 는 arguments 에서 받지 않음 → 모두 widget 값 사용
        final inputValue = int.tryParse(_controller.text) ?? 0;
        final isValid = inputValue >= 8 && inputValue <= 128;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: GradientBackground(
            child: SafeArea(
              child: Stack(
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 32,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const SizedBox(height: 60),

                              // 상단 카테고리 정보
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: boxColor,
                                  borderRadius: BorderRadius.circular(40),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      widget.categoryEmoji,
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      widget.categoryTitle,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: textColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 24),

                              Text(
                                "몇 강전을 하실건가요?",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "8~128 사이의 숫자만 입력 가능합니다",
                                style: TextStyle(color: subTextColor),
                              ),

                              const SizedBox(height: 32),

                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: boxColor,
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 80,
                                      child: Focus(
                                        onFocusChange: (hasFocus) {
                                          setState(() => _showHint = !hasFocus);
                                        },
                                        child: TextField(
                                          controller: _controller,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                          ],
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 48,
                                            color: Color(0xFFFF5C8D),
                                            fontWeight: FontWeight.bold,
                                          ),
                                          decoration: InputDecoration(
                                            hintText: _showHint ? "8" : "",
                                            hintStyle: TextStyle(
                                              color: Colors.grey.withOpacity(
                                                0.3,
                                              ),
                                              fontSize: 48,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            border: InputBorder.none,
                                          ),
                                          onChanged: (val) {
                                            if (val.isNotEmpty &&
                                                !RegExp(
                                                  r'^\d+$',
                                                ).hasMatch(val)) {
                                              _showSnackBar(
                                                "숫자만 입력할 수 있습니다 (8~128)",
                                                isDark,
                                              );
                                              _controller.text = val.replaceAll(
                                                RegExp(r'\D'),
                                                '',
                                              );
                                            }

                                            final num = int.tryParse(val);
                                            if (num != null && num > 128) {
                                              _showSnackBar(
                                                "⚠️ 최대 128강까지만 가능합니다",
                                                isDark,
                                              );
                                            }
                                            setState(() {});
                                          },
                                        ),
                                      ),
                                    ),
                                    Text(
                                      "강",
                                      style: TextStyle(
                                        fontSize: 28,
                                        color: subTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 24),

                              Text(
                                "빠른 선택",
                                style: TextStyle(color: subTextColor),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children: [8, 16, 32, 64, 128].map((num) {
                                  final isSelected = selectedQuick == num;
                                  return ChoiceChip(
                                    label: Text("${num}강"),
                                    selected: isSelected,
                                    selectedColor: const Color(0xFFFF5C8D),
                                    labelStyle: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : textColor,
                                    ),
                                    onSelected: (_) {
                                      setState(() {
                                        selectedQuick = num;
                                        _controller.text = num.toString();
                                      });
                                    },
                                  );
                                }).toList(),
                              ),

                              const SizedBox(height: 40),

                              Row(
                                children: [
                                  Expanded(
                                    child: _actionButton(
                                      text: "이전으로",
                                      color: boxColor!,
                                      textColor: textColor,
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _actionButton(
                                      text: "시작하기",
                                      color: isValid
                                          ? const Color(0xFFFF5C8D)
                                          : Colors.grey.shade300,
                                      textColor: isValid
                                          ? Colors.white
                                          : Colors.grey.shade500,
                                      onPressed: isValid
                                          ? () =>
                                                _handleStart(isDark)
                                          : null,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),
                              Text(
                                "💡 8~128 사이의 숫자만 가능합니다",
                                style: TextStyle(color: subTextColor),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const LogoutButton(),
                  const DarkModeToggle(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _actionButton({
    required String text,
    required Color color,
    required Color textColor,
    required VoidCallback? onPressed,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 56,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: onPressed != null
            ? [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : [],
      ),
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
