import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'themes/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/user_info_screen.dart';
import 'screens/topic_screen.dart';
import 'screens/tournament_screen.dart';
import 'screens/winner_screen.dart';

void main() => runApp(const IdealWorldcupApp());

class IdealWorldcupApp extends StatelessWidget {
  const IdealWorldcupApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ThemeModeNotifier())],
      child: Consumer<ThemeModeNotifier>(
        builder: (_, tm, __) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Ideal World Cup',
          theme: AppTheme.light, //라이트모드
          darkTheme: AppTheme.dark, //다크모드
          themeMode: tm.mode,
          initialRoute: '/',
          routes: {
            '/': (_) => const HomeScreen(),
            '/userinfo': (_) => const UserInfoScreen(),
            '/topics': (_) => const TopicScreen(),
            '/play': (_) => const TournamentScreen(),
            '/result': (_) => const WinnerScreen(),
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
