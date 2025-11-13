import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamproject/providers/tournament_provider.dart';
import 'package:teamproject/screens/summary_screen.dart';
import 'package:teamproject/screens/user_info_screen.dart';
import 'package:teamproject/screens/round_selection_screen.dart';
import 'package:teamproject/service/local_storage_service.dart';
import 'themes/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/topic_screen.dart';
import 'screens/tournament_screen.dart';
import 'screens/winner_screen.dart';

void main() async {
  // Flutter 엔진과 SharedPreferences 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // 로컬 데이터 불러오기
  final userInfo = await LocalStorageService.loadUserInfo();
  final result = await LocalStorageService.loadResult();

  // 초기 라우트 결정
  String initialRoute;
  if (userInfo != null && result != null) {
    initialRoute = '/summary'; // 저장된 데이터가 있으면 요약화면부터 시작
  } else {
    initialRoute = '/'; // 없으면 홈 화면부터 시작
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TournamentProvider()),
        ChangeNotifierProvider(create: (_) => ThemeModeNotifier()), // 테마 모드 관리
      ],
      child: IdealWorldcupApp(initialRoute: initialRoute),
    ),
  );
}

class IdealWorldcupApp extends StatelessWidget {
  final String initialRoute;
  const IdealWorldcupApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    // 🟩 여기서는 Provider 중복 선언 X
    return Consumer<ThemeModeNotifier>(
      builder: (_, tm, __) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: '이상형 월드컵',
        theme: AppTheme.light, //라이트모드
        darkTheme: AppTheme.dark, //다크모드
        themeMode: tm.mode, // 토글 반영
        initialRoute: initialRoute, // 결정된 시작 화면 반영
        routes: {
          '/': (_) => const HomeScreen(), //메인화면
          '/userinfo': (_) => const UserInfoScreen(), //유저 정보 받는화면
          '/topics': (_) => const TopicScreen(), //메인에서 넘어가는주제 선택화면
          '/roundselection': (_) => const RoundSelectionScreen(
            categoryTitle: '기본',
            categoryEmoji: '💫',
          ), // 몇 강인지 선택하는 화면
          '/tournament': (_) => const TournamentScreen(), //선택한 주제에 맞는 대결화면
          '/winner': (_) => const WinnerScreen(), //대결 종료, 우승한 결과화면
          '/summary': (_) => const SummaryScreen(), //저장된 결과 요약화면
        },
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
