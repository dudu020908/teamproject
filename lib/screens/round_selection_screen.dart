import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:teamproject/widgets/gradient_background.dart';
import 'package:teamproject/widgets/dark_mode_toggle.dart';
import 'package:teamproject/model/candidate.dart';
import '../providers/tournament_provider.dart';
import 'package:teamproject/main.dart';

class RoundSelectionScreen extends StatefulWidget {
  final String categoryTitle;
  final String categoryEmoji;

  const RoundSelectionScreen({
    super.key,
    required this.categoryTitle,
    required this.categoryEmoji,
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
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.white,
            ),
          ),
          backgroundColor: isDark ? Colors.redAccent[700] : Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  // "시작하기" 버튼 클릭 시
  void _handleStart(bool isDark) {
    final text = _controller.text.trim();
    final num = int.tryParse(text);

    // 숫자가 아니거나 범위 초과 시 경고
    if (num == null || num < 8 || num > 128) {
      _showSnackBar("⚠️ 8~128 사이의 숫자만 입력 가능합니다", isDark);
      return;
    }
    // Provider 초기화,데이터 전달
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final topic = args?['topic'] ?? widget.categoryTitle;

    final provider = Provider.of<TournamentProvider>(context, listen: false);
    final candidates = samplesForTopic(topic);

    // ✅ 후보가 부족한 경우 차단
    if (candidates.length < num) {
      _showSnackBar(
        "⚠️ 후보 수(${candidates.length}명)가 ${num}강을 진행하기에 부족합니다!",
        isDark,
      );
      return; // 시작 안 함
    }

    List<Candidate> selectedCandidates = List.from(candidates);
    selectedCandidates.shuffle();

    if (selectedCandidates.length > num) {
      selectedCandidates = selectedCandidates.take(num).toList();
    }

    provider.startTournament(topic, selectedCandidates);

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

        final args = ModalRoute.of(context)?.settings.arguments as Map?;
        final topic = args?['topic'] ?? widget.categoryTitle;
        final emoji = args?['emoji'] ?? widget.categoryEmoji;

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
                                      emoji,
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      topic,
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

                              // 입력 필드
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
                                            // 숫자 외 문자 입력 시 자동 제거
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

                                            // 128 초과 시 경고
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

                              // 빠른 선택 버튼
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

                              /// 버튼 영역
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
                                          ? () => _handleStart(isDark)
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

                  //  다크모드 토글 버튼
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
