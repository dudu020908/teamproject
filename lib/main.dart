import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

import 'package:teamproject/service/local_storage_service.dart';

import 'package:teamproject/providers/tournament_provider.dart';

import 'package:teamproject/screens/CreateWorldcupScreen.dart';
import 'package:teamproject/screens/user_info_screen.dart';
import 'package:teamproject/screens/topic_screen.dart';
import 'package:teamproject/screens/round_selection_screen.dart';
import 'package:teamproject/screens/tournament_screen.dart';
import 'package:teamproject/screens/winner_screen.dart';
import 'package:teamproject/screens/summary_screen.dart';
import 'package:teamproject/screens/home_screen.dart';
import 'package:teamproject/screens/worldcup_list_screen.dart';

import 'themes/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final auth = FirebaseAuth.instance;
  if (auth.currentUser == null) {
    await auth.signInAnonymously();
  }

  final userInfo = await LocalStorageService.loadUserInfo();
  final String initialRoute = '/home';

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
  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;

  void toggle() {
    _mode = _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}
