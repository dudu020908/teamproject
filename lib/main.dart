import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamproject/providers/tournament_provider.dart';
import 'package:teamproject/screens/user_info_screen.dart';
import 'themes/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/user_info_screen.dart';
import 'screens/topic_screen.dart';
import 'screens/tournament_screen.dart';
import 'screens/winner_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => TournamentProvider())],
      child: const IdealWorldcupApp(),
    ),
  );
}

class IdealWorldcupApp extends StatelessWidget {
  const IdealWorldcupApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ThemeModeNotifier())],
      child: Consumer<ThemeModeNotifier>(
        builder: (_, tm, __) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: '이상형 월드컵',
          theme: AppTheme.light, //라이트모드
          darkTheme: AppTheme.dark, //다크모드
          themeMode: tm.mode,
          initialRoute: '/',
          routes: {
            '/': (_) => const HomeScreen(), //메인화면
            '/userinfo': (_) => const UserInfoScreen(), //유저 정보 받는화면
            '/topics': (_) => const TopicScreen(), //메인에서 넘어가는주제 선택화면
            '/tournament': (_) => const TournamentScreen(), //선택한 주제에 맞는 대결화면
            '/winner': (_) => const WinnerScreen(), //대결 종료, 우승한 결과화면
          },
        ),
      ),
    );
  }
}

//라이트/다크 토글용 Notifier
class ThemeModeNotifier extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;
  void toggle() {
    _mode = _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}
