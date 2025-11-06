import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:teamproject/widgets/gradient_background.dart';

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

  /// SnackBar 경고 표시
  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.redAccent.shade200,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  // "시작하기" 버튼 클릭 시
  void _handleStart() {
    final text = _controller.text.trim();
    final num = int.tryParse(text);

    // 숫자가 아니거나 범위 초과 시 경고
    if (num == null || num < 8 || num > 128) {
      _showSnackBar("⚠️ 8~128 사이의 숫자만 입력 가능합니다");
      return;
    }

    Navigator.pushNamed(context, '/tournament', arguments: {'rounds': num});
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final topic = args?['topic'] ?? widget.categoryTitle;
    final emoji = args?['emoji'] ?? widget.categoryEmoji;

    final inputValue = int.tryParse(_controller.text) ?? 0;
    final isValid = inputValue >= 8 && inputValue <= 128;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(height: 16),

                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
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
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            "몇 강전을 하실건가요?",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "8~128 사이의 숫자만 입력 가능합니다",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
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
                                    FilteringTextInputFormatter.digitsOnly,
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
                                      color: Colors.grey.withOpacity(0.3),
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    border: InputBorder.none,
                                  ),
                                  onChanged: (val) {
                                    // 문자 입력 시 자동 제거
                                    if (val.isNotEmpty &&
                                        !RegExp(r'^\d+$').hasMatch(val)) {
                                      _showSnackBar("숫자만 입력할 수 있습니다 (8~128)");
                                      _controller.text = val.replaceAll(
                                        RegExp(r'\D'),
                                        '',
                                      );
                                    }

                                    // 128 초과 시 경고
                                    final num = int.tryParse(val);
                                    if (num != null && num > 128) {
                                      _showSnackBar("⚠️ 최대 128강까지만 가능합니다");
                                    }
                                    setState(() {});
                                  },
                                ),
                              ),
                            ),
                            const Text(
                              "강",
                              style: TextStyle(
                                fontSize: 28,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // 빠른 선택 버튼(8,16,32,64,128강)
                      const Text("빠른 선택", style: TextStyle(color: Colors.grey)),
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
                              color: isSelected ? Colors.white : Colors.black87,
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

                      // 뒤로가기 시작하기
                      Row(
                        children: [
                          Expanded(
                            child: _actionButton(
                              text: "이전으로",
                              color: Colors.white,
                              textColor: Colors.black87,
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
                              onPressed: isValid ? _handleStart : null,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      const Text(
                        "💡 8~128 사이의 숫자만 가능합니다",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
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
