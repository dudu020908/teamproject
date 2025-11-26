import 'package:flutter/material.dart';

class PickCard extends StatefulWidget {
  final String title;
  final String imageUrl;
  final VoidCallback onTap;

  const PickCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  State<PickCard> createState() => _PickCardState();
}

class _PickCardState extends State<PickCard> {
  bool _isPressed = false; // 터치 피드백용 상태

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return FocusTraversalOrder(
      order: const NumericFocusOrder(1),
      child: Tooltip(
        message: '${widget.title} 선택',
        child: Semantics(
          button: true,
          label: '${widget.title} 후보 선택',
          child: GestureDetector(
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) {
              setState(() => _isPressed = false);
              widget.onTap();
            },
            onTapCancel: () => setState(() => _isPressed = false),
            child: AnimatedScale(
              scale: _isPressed ? 0.97 : 1.0, // 살짝 눌리는 효과
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.hardEdge,
                margin: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 이미지 영역 (비율 고정)
                    AspectRatio(
                      aspectRatio: 3 / 4, // 카드 비율 (너비:높이)
                      child: Image.network(
                        widget.imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) =>
                            progress == null
                                ? child
                                : const Center(
                                    child: CircularProgressIndicator()),
                        errorBuilder: (context, error, stackTrace) => Container(
                    color: scheme.surfaceVariant,
                    child: Icon(
                            Icons.broken_image,
                            size: 40,
                      color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),

                    // 제목 영역
                    Container(
                      width: double.infinity,
                color: scheme.surface,
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        widget.title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                  ),
                ),
              ),
          ),
        ),
      ),
    );
  }
}
