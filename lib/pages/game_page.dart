import 'package:flutter/material.dart';
import 'package:merge_items_game/utils/colors.dart';
import 'package:merge_items_game/widgets/game_panel.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Container(
          color: primary,
          width: double.infinity,
          height: double.infinity,
          child: Column(
            children: [
              Container(
                height: 280,
              ),
              const Expanded(child: GamePanel()),
            ],
          ),
        ),
      ),
    );
  }
}
