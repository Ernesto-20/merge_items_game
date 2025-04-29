import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:merge_items_game/models/figure.dart';


const Map<int, Map<String, dynamic>> ALL_FIGURES_BY_LEVELS = {
    -2: {'form': 'negative_pyramid', 'color': Colors.white},
    -1: {'form': 'positive_pyramid', 'color': Colors.white},



    1: {'form': 'triangle', 'color': Color.fromRGBO(0, 255, 0, 1)},
    2: {'form': 'square', 'color': Color.fromARGB(255, 255, 133, 57)},
    3: {'form': 'pentagon', 'color': Colors.blue.shade500},
    4: {'form': 'hexagon', 'color': Color.fromRGBO(255, 0, 255, 1)},
    5: {'form': 'heptagon', 'color': Color.fromRGBO(0, 206, 209, 1)},
    6: {'form': 'octagon', 'color': Color.fromRGBO(0, 20, 150, 1)},
    7: {'form': 'nonagon', 'color': Color.fromRGBO(255, 0, 0, 1)},
    8: {'form': 'decadon', 'color': Color.fromARGB(255, 71, 0, 79)},
    9: {'form': 'undecadon', 'color': Color.fromRGBO(128, 0, 128, 1)},
    10: {'form': 'dodecadon', 'color': Color.fromRGBO(204, 255, 0, 1)},
    11: {'form': 'triskaidecagon', 'color': Color.fromARGB(255, 163, 198, 168)},
    12: {'form': 'tetradecagon', 'color': Color.fromARGB(255, 193, 151, 151)},
    13: {'form': 'pentadecagon', 'color': Color.fromARGB(255, 116, 166, 109)},

    14: {'form': 'circule', 'color': Colors.white},
  };

class FigureView extends StatefulWidget {
  const FigureView({
    super.key,
    required this.figureInfo,
    required this.maxWidth,
    required this.maxHeight,
  });

  final FigureInfo figureInfo;
  final double maxWidth;
  final double maxHeight;

  @override
  State<FigureView> createState() => _FigureViewState();
}

class _FigureViewState extends State<FigureView> with TickerProviderStateMixin {
  late final AnimationController controllerLevelUp;
  late Animation<double> animationLevelUp;

  late final AnimationController controllerSpin;
  late Animation<double> animationSpin;

  late final Color color;

  late final String form;
  late double sizeForm;
  late bool isCircule = false;

  @override
  void initState() {
    super.initState();
    sizeForm = 40;

    controllerSpin = AnimationController(vsync: this, duration: const Duration(seconds: 10),)..repeat();
    animationSpin = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: controllerSpin,curve: Curves.linear, ),)..addListener(() {
        setState(() {});
      });

    controllerLevelUp = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );
    animationLevelUp = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: controllerLevelUp, curve: Curves.easeInOutExpo))
      ..addListener(() {
        setState(() {});
      });
    if (widget.figureInfo.levelUp) {
      controllerLevelUp.forward();
    }
  }

  @override
  void dispose() {
    controllerLevelUp.dispose();
    controllerSpin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: widget.maxWidth,
        height: widget.maxWidth,
        // color: Colors.blueGrey,
        alignment: Alignment.center,
        child: _buildRotatePolygon());
  }

  Widget _buildRotatePolygon() {
    return AnimatedBuilder(
      animation: controllerSpin,
      builder: (BuildContext context, Widget? child) {
        return Transform.rotate(
          angle:
              controllerSpin.value * 2 * pi + animationLevelUp.value * 2 * pi,
          child: child,
        );
      },
      child: SizedBox(
          width: widget.figureInfo.levelUp
              ? sizeForm / 2 * animationLevelUp.value + sizeForm / 2
              : sizeForm,
          height: widget.figureInfo.levelUp
              ? sizeForm / 2 * animationLevelUp.value + sizeForm / 2
              : sizeForm,
          child: _buildPolygon()),
    );
  }
  Widget _buildPolygon({bool text = true}) {

    double width = widget.figureInfo.lvl == 1 ? 18.13 : 26;
    double height = widget.figureInfo.lvl == 1 ? 16.5 : 24;

    return Container(
      width: sizeForm,
      height: sizeForm,
      alignment: Alignment.center,
      child: Stack(
        children: [
          Center(
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.white.withOpacity(1-animationSpin.value), // Transparencia deseada
                BlendMode.dstIn,
              ),
              child: SvgPicture.asset(
                'assets/figures/${ALL_FIGURES_BY_LEVELS[widget.figureInfo.lvl]!['form']}-border.svg',
                width: width + (sizeForm - width) * animationSpin.value,
                height: height + (sizeForm - height) * animationSpin.value,
              ),
            ),
          ),
          Container(
            alignment: Alignment.center,
            child: SvgPicture.asset(
              'assets/figures/${ALL_FIGURES_BY_LEVELS[widget.figureInfo.lvl]!['form']}.svg',
              width: widget.figureInfo.lvl == 1 ? 23.13 : 26,
              height: widget.figureInfo.lvl == 1 ? 21.5 : 24,
            ),
          ),
        ],
      ),
    );
  }




  // That is a deprecated function
  Widget _buildThreeDimension() {
    Color colorPrimary;
    Color colorSecondary;

    if (widget.figureInfo.lvl == -1) {
      colorPrimary = Colors.blueAccent;
      colorSecondary = Colors.blue;
    } else {
      colorPrimary = Colors.redAccent;
      colorSecondary = Colors.red;
    }

    return AnimatedBuilder(
      animation: controllerSpin,
      builder: (BuildContext context, Widget? child) {
        return Transform.rotate(
          angle: controllerSpin.value * 2 * pi,
          child: child,
        );
        // return child!;
      },
      child: SizedBox(
          width:
              widget.figureInfo.levelUp ? 14 * animationLevelUp.value + 14 : 30,
          height:
              widget.figureInfo.levelUp ? 14 * animationLevelUp.value + 14 : 30,
          child: Pyramid(
              value: controllerSpin.value,
              colorPrimary: colorPrimary,
              colorSecondary: colorSecondary)),
    );
  }
}





class Triangle extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double w = size.width;
    double h = sqrt(3) / 2 * w;

    Path path = Path();

    const double x0 = 0;
    final double y0 = h;
    final double x1 = w / 2;
    const double y1 = 0;
    final double x2 = w;
    final double y2 = h;

    path.moveTo(x0, y0);
    path.lineTo(x1, y1);
    path.lineTo(x2, y2);

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}

class Sephere extends StatelessWidget {
  const Sephere({super.key, required this.value});

  final double value;

  @override
  Widget build(Object context) {
    return Container(
      decoration: BoxDecoration(
          gradient: RadialGradient(
              colors: const [Colors.white38, Colors.white],
              radius: 1.5,
              center: Alignment(sin(value * 2 * pi), tan(value * 2 * pi))),
          color: Colors.white,
          shape: BoxShape.circle),
    );
  }
}

class Pyramid extends StatelessWidget {
  const Pyramid(
      {super.key,
      required this.value,
      required this.colorPrimary,
      required this.colorSecondary});

  final double value;
  final Color colorPrimary;
  final Color colorSecondary;

  @override
  Widget build(Object context) {
    return Transform(
      alignment: FractionalOffset.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateY(sin(value * 2 * pi))
        ..rotateZ(0)
        ..rotateX(-0.1),
      child: Stack(
        children: [
          Transform(
              alignment: FractionalOffset.bottomCenter,
              transform: Matrix4.identity()
                ..translate(17.0, .0, 0.0)
                ..rotateY(.25 * 2 * pi)
                ..rotateX(0.62),
              child: _buildPolygon(color: colorPrimary, text: false)),

          Transform(
              alignment: FractionalOffset.bottomCenter,
              transform: Matrix4.identity()
                ..translate(-17.0, .0, 0.0)
                ..rotateY(.75 * 2 * pi)
                ..rotateX(0.62),
              child: _buildPolygon(color: colorPrimary, text: false)),

          Transform(
              // correct
              alignment: FractionalOffset.bottomCenter,
              transform: Matrix4.identity()
                ..translate(0.1, .0, 17.5)
                ..rotateX(0.62),
              child: _buildPolygon(color: colorSecondary, text: false)),
          // ),
        ],
      ),
    );
  }

  Widget _buildPolygon({required Color color, bool text = false}) {
    return ClipPath(
        clipper: Triangle(),
        child: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [color, color],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter)),
            alignment: Alignment.center,
            child: text
                ? const Text(
                    '${2}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  )
                : null));
  }
}
