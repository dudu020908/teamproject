import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'model/candidate.dart';
import 'providers/tournament_provider.dart';

void main() {
  runApp(const IdealWorldcupApp());
}

class IdealWorldcupApp extends StatelessWidget {
  const IdealWorldcupApp({super.key});

  @override
  Widget build(BuildContext context) {
    final samples = List<Candidate>.unmodifiable([
      Candidate(
        id: '1',
        title: 'Cat',
        imageUrl: 'https://picsum.photos/id/1025/600/800',
      ),
      Candidate(
        id: '2',
        title: 'Dog',
        imageUrl: 'https://picsum.photos/id/237/600/800',
      ),
      Candidate(
        id: '3',
        title: 'Fox',
        imageUrl: 'https://picsum.photos/id/433/600/800',
      ),
      Candidate(
        id: '4',
        title: 'Panda',
        imageUrl: 'https://picsum.photos/id/1062/600/800',
      ),
      Candidate(
        id: '5',
        title: 'Koala',
        imageUrl: 'https://picsum.photos/id/443/600/800',
      ),
      Candidate(
        id: '6',
        title: 'Tiger',
        imageUrl: 'https://picsum.photos/id/593/600/800',
      ),
      Candidate(
        id: '7',
        title: 'Lion',
        imageUrl: 'https://picsum.photos/id/1074/600/800',
      ),
      Candidate(
        id: '8',
        title: 'Bear',
        imageUrl: 'https://picsum.photos/id/582/600/800',
      ),
    ]);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TournamentProvider(samples)),
      ],
      child: MaterialApp(
        title: 'Ideal World Cup',
        theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
        home: const TournamentScreen(),
      ),
    );
  }
}

class TournamentScreen extends StatelessWidget {
  const TournamentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<TournamentProvider>(
          builder: (_, p, __) => Text(
            p.state == TournamentState.playing ? '이상형 월드컵 · 진행중' : '우승자',
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<TournamentProvider>().reset(),
            tooltip: '다시 시작',
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<TournamentProvider>(
          builder: (context, p, _) {
            if (p.state == TournamentState.finished) {
              final w = p.winner!;
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _WinnerCard(title: w.title, imageUrl: w.imageUrl),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: p.reset,
                      child: const Text('다시 하기'),
                    ),
                  ],
                ),
              );
            }

            final left = p.left;
            final right = p.right;
            if (left == null || right == null) {
              // 페어 세팅 중 잠깐 빈 상태일 수 있음
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '현재 라운드 후보: ${p.currentRoundSize + p._nextRoundLengthDebug}명',
                      ),
                      Text('남은 대결: ${p.remainingPairs}'),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: _PickCard(
                          title: left.title,
                          imageUrl: left.imageUrl,
                          onTap: p.chooseLeft,
                        ),
                      ),
                      const VerticalDivider(width: 1),
                      Expanded(
                        child: _PickCard(
                          title: right.title,
                          imageUrl: right.imageUrl,
                          onTap: p.chooseRight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// 디버그 표기를 위해 Provider 내부 컬렉션 길이를 간접 노출 (UI 참고용)
extension on TournamentProvider {
  int get _nextRoundLengthDebug => 0; // 필요 시 디버그용으로 노출해도 됨
}

class _PickCard extends StatefulWidget {
  final String title;
  final String imageUrl;
  final VoidCallback onTap;

  const _PickCard({
    required this.title,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  State<_PickCard> createState() => _PickCardState();
}

class _PickCardState extends State<_PickCard>
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

class _WinnerCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  const _WinnerCard({required this.title, required this.imageUrl});

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
