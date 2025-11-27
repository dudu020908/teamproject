import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'firebase_options.dart';

import 'package:teamproject/service/local_storage_service.dart';

import 'package:teamproject/providers/tournament_provider.dart';

import 'package:teamproject/screens/CreateWorldcupScreen.dart';
import 'package:teamproject/screens/user_info_screen.dart';
import 'package:teamproject/screens/topic_screen.dart';
import 'package:teamproject/screens/round_selection_screen.dart';
import 'package:teamproject/screens/tournament_screen.dart';
import 'package:teamproject/screens/winner_screen.dart';
import 'package:teamproject/screens/home_screen.dart';
import 'package:teamproject/screens/worldcup_list_screen.dart';

import 'themes/app_theme.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  final prefsWarmUp = LocalStorageService.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final auth = FirebaseAuth.instance;
  final Future<void> signInFuture = auth.currentUser == null
      ? auth.signInAnonymously()
      : Future.value();

  await Future.wait([prefsWarmUp, signInFuture]);
  const String initialRoute = '/home';

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TournamentProvider()),
        ChangeNotifierProvider(create: (_) => ThemeModeNotifier()),
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
    return Consumer<ThemeModeNotifier>(
      builder: (_, tm, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "이상형 월드컵",

          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: tm.mode,

          builder: (context, child) {
            final mediaQuery = MediaQuery.of(context);
            final clampedScale = mediaQuery.textScaleFactor.clamp(1.0, 1.5);
            return MediaQuery(
              data: mediaQuery.copyWith(
                textScaler: TextScaler.linear(clampedScale),
              ),
              child: child!,
            );
          },

          initialRoute: initialRoute,

          routes: {
            '/': (_) => const HomeScreen(),
            '/home': (_) => const HomeScreen(),
            '/userinfo': (_) => const UserInfoScreen(),
            '/topics': (_) => const TopicScreen(),
            '/createworldcup': (_) => const CreateWorldcupScreen(),
            '/category_worldcups': (_) => const WorldcupListScreen(),

            '/roundselection': (context) {
              final args =
                  ModalRoute.of(context)!.settings.arguments
                      as Map<String, dynamic>;
              return RoundSelectionScreen(
                categoryId: args['categoryId'],
                categoryTitle: args['title'],
                categoryEmoji: args['emoji'],
              );
            },

            '/tournament': (_) => const TournamentScreen(),
            '/winner': (_) => const WinnerScreen(),
            //  '/summary': (_) => const SummaryScreen(),
          },
        );
      },
    );
  }
}

class ThemeModeNotifier extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.light; // 기본은 라이트 모드로 시작
  ThemeMode get mode => _mode;

  void toggle() {
    _mode = _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}
