import 'package:flutter/material.dart';
import 'package:merge_items_game/pages/game_page.dart';
import 'package:merge_items_game/pages/home.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Polygon',
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        'loading-start-game': (context) => const LoadingPage(),
        '/start-game': (context) => const GamePage(),
      },
      theme: ThemeData(
        useMaterial3: true,
      ),
    );
  }
}
  