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

class _PickCardState extends State<PickCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 140),
  );
  late final Animation<double> _scale = Tween(
    begin: 1.0,
    end: 0.96,
  ).animate(_ac);

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    await _ac.forward();
    await _ac.reverse();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scale,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Card(
            clipBehavior: Clip.antiAlias,
            elevation: 2,
            child: Column(
              children: [
                Expanded(
                  child: Image.network(
                    widget.imageUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (c, child, progress) => progress == null
                        ? child
                        : const Center(child: CircularProgressIndicator()),
                    errorBuilder: (_, __, ___) =>
                        const Center(child: Icon(Icons.broken_image)),
                  ),
                ),
                ListTile(
                  title: Text(
                    widget.title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  trailing: const Icon(Icons.touch_app),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WinnerCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  const WinnerCard({super.key, required this.title, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: 320,
        height: 420,
        child: Column(
          children: [
            Expanded(
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
            ListTile(
              title: Text(
                '우승: $title',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: const Icon(Icons.emoji_events),
            ),
          ],
        ),
      ),
    );
  }
}
