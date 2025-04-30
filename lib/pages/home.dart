import 'dart:math';

import 'package:flutter/material.dart';
import 'package:merge_items_game/models/figure.dart';
import 'package:merge_items_game/widgets/figure_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: const Color.fromARGB(255, 255, 255, 255),
            width: double.infinity,
            height: double.infinity,
          ),
          const FloatingFigures(),
          const Positioned.fill(
            child: Image(
              image: AssetImage('assets/images/home-top.png'),
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
          
          
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsets.only(top: 150),
              height: 115,
              child: const Image(
                image: AssetImage('assets/images/title.png'),
                fit: BoxFit.contain,
              ),
            ),
          ),
          Align(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                MainButton(
                  title: 'Play',
                  onPressed: () {
                    Future.delayed(const Duration(seconds: 5), () {
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => const LoadingPage(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                        ),
                      );
                    });
                  },
                  width: 200,
                ),
                const SizedBox(
                  height: 20,
                ),
                MainButton(
                  title: 'How to play',
                  width: 180,
                  onPressed: () {},
                ),
                const SizedBox(
                  height: 20,
                ),
                MainButton(
                  title: 'Records',
                  width: 160,
                  onPressed: () {},
                ),
                const SizedBox(
                  height: 20,
                ),
                MainButton(
                  title: 'Settings',
                  width: 140,
                  onPressed: () {},
                ),
                const SizedBox(
                  height: 60,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MainButton extends StatelessWidget {
  const MainButton({
    super.key,
    required this.title,
    required this.onPressed,
    required this.width,
  });

  final VoidCallback onPressed;
  final String title;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 60,
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(87, 58, 146, 1),
            offset: Offset(0, 5),
            blurRadius: 0, // Sin desenfoque
          ),
        ],
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromRGBO(133, 108, 184, 1),
            padding: const EdgeInsets.all(0), // Ajusta el tamaño del botón
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20), // Radio del borde
            ),
          ),
          child: Text(
            title,
            style: const TextStyle(
                color: Color.fromARGB(255, 255, 255, 255), fontSize: 23),
          )),
    );
  }
}


class FloatingFigures extends StatefulWidget {
  const FloatingFigures({super.key});

  @override
  State<FloatingFigures> createState() => _FloatingFiguresState();
}

class _FloatingFiguresState extends State<FloatingFigures>
    with TickerProviderStateMixin {
  late final AnimationController _controllerMoving;
  late Animation<double> animationMovements;

  @override
  void initState() {
    super.initState();

    _controllerMoving =
        AnimationController(vsync: this, duration: const Duration(seconds: 12))
          ..repeat();
    animationMovements =
        Tween<double>(begin: 0, end: 1).animate(_controllerMoving)
          ..addListener(() {
            setState(() {});
          });
  }

  @override
  void dispose() {
    _controllerMoving.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<FigureInfo> figures = [
      FigureInfo(id: 0, rowIndex: -1, columnIndex: -1, steps: -1, lvl: 5),
      FigureInfo(id: 1, rowIndex: -1, columnIndex: -1, steps: -1, lvl: 4),
      FigureInfo(id: 2, rowIndex: -1, columnIndex: -1, steps: -1, lvl: 1),
      FigureInfo(id: 3, rowIndex: -1, columnIndex: -1, steps: -1, lvl: 7),
      FigureInfo(id: 4, rowIndex: -1, columnIndex: -1, steps: -1, lvl: 8),
      FigureInfo(id: 5, rowIndex: -1, columnIndex: -1, steps: -1, lvl: 9),
    ];

    return Stack(
      children: [
        Positioned(
          top: -50 * cos(animationMovements.value * 2 * pi),
          right: 30 + 20 * sin(animationMovements.value * 2 * pi),
          child: FigureView(
            key: ValueKey(figures[0].id),
            figureInfo: figures[0],
            maxWidth: 40,
            maxHeight: 40,
          ),
        ),
        Positioned(
          top: 300 +
              200 * cos(animationMovements.value * 2 * pi) +
              30 * sin(animationMovements.value * 1 * pi),
          left: 150 +
              100 * cos(animationMovements.value * 2 * pi) +
              10 * sin(animationMovements.value * 1 * pi),
          child: FigureView(
            key: ValueKey(figures[1].id),
            figureInfo: figures[1],
            maxWidth: 40,
            maxHeight: 40,
          ),
        ),
        Positioned(
          bottom: 100 + -80 * cos(animationMovements.value * 2 * pi),
          left: 200 + 20 * sin(animationMovements.value * 2 * pi),
          child: FigureView(
            key: ValueKey(figures[3].id),
            figureInfo: figures[3],
            maxWidth: 40,
            maxHeight: 40,
          ),
        ),
        Positioned(
          bottom: -10 * cos(animationMovements.value * 2 * pi),
          left: 30 + 20 * sin(animationMovements.value * 2 * pi),
          child: FigureView(
            key: ValueKey(figures[2].id),
            figureInfo: figures[2],
            maxWidth: 40,
            maxHeight: 40,
          ),
        ),
        Positioned(
          bottom: 50 + 135 * cos(animationMovements.value * 2 * pi),
          left: 255 + 20 * sin(animationMovements.value * 2 * pi),
          child: FigureView(
            key: ValueKey(figures[4].id),
            figureInfo: figures[4],
            maxWidth: 40,
            maxHeight: 40,
          ),
        ),
        Positioned(
          bottom: 220 +  -10 * cos(animationMovements.value * 2 * pi),
          left: 20 + 20 * sin(animationMovements.value * 2 * pi),
          child: FigureView(
            key: ValueKey(figures[5].id),
            figureInfo: figures[5],
            maxWidth: 40,
            maxHeight: 40,
          ),
        ),
      ],
    );
  }
}