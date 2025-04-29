import 'dart:math';

import 'package:flutter/material.dart';
import 'package:merge_items_game/models/figure.dart';
import 'package:merge_items_game/utils/colors.dart';
import 'package:merge_items_game/widgets/figure_view.dart';

const int heightDimension = 5;
const int widthDimension = 4;

double gridWidth = 90;
double gridHeight = 90;

class GamePanel extends StatefulWidget {
  const GamePanel({super.key});

  @override
  State<GamePanel> createState() => _GamePanelState();
}

enum Move { up, right, down, left }

class _GamePanelState extends State<GamePanel> with TickerProviderStateMixin {
  Move currentMovement = Move.right;
  late final AnimationController controllerMovements;
  late Animation<double> animationMovements;
  int biggerLvl = 1;

  late List<({FigureInfo figure, int availableMovement})> availableSpace = [];

  int serialId = 0;
  late List<FigureInfo> lastState;
  List<FigureInfo> figuresPossitions = [
    FigureInfo(
      id: 0,
      rowIndex: 4,
      columnIndex: 3,
      steps: 0,
      lvl: 1,
    ),
  ];
  int points = 0;
  bool isFinish = false;
  ({int rowIndex, int columnIndex, int steps}) comboPossition =
      (rowIndex: 0, columnIndex: 0, steps: 0);

  
  @override
  void initState() {
    super.initState();
    lastState = figuresPossitions.map((e) => e.copyWidth()).toList();
    controllerMovements = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450));

    animationMovements = Tween<double>(begin: 0, end: 1)
        .animate(controllerMovements)
      ..addListener(() {
        setState(() {
          if (animationMovements.value == 1) {
            for (var figure in figuresPossitions) {
              switch (currentMovement) {
                case Move.up:
                  figure.rowIndex -= figure.steps;
                case Move.right:
                  figure.columnIndex += figure.steps;
                case Move.down:
                  figure.rowIndex += figure.steps;
                case Move.left:
                  figure.columnIndex -= figure.steps;
              }
            }

            // Combined
            List<FigureInfo> combinedFigures = [];
            List<int> indexDuplicated = [];
            points = 0;
            for (int i = 0; i < figuresPossitions.length; i++) {
              bool isCombined = false;
              for (int j = i + 1; j < figuresPossitions.length; j++) {
                if ((figuresPossitions[i].rowIndex ==
                        figuresPossitions[j].rowIndex) &&
                    (figuresPossitions[i].columnIndex ==
                        figuresPossitions[j].columnIndex) &&
                    !(indexDuplicated.contains(j))) {
                  isCombined = true;
                  indexDuplicated.add(j);
                  if (figuresPossitions[i].id > figuresPossitions[j].id) {
                    int upgrade = upgradeLevel(figuresPossitions[i].lvl,
                        figuresPossitions[j].lvl); //Subir de nivel o bajar.

                    points += (upgrade > 0) ? upgrade * 10 : 50;

                    (upgrade) * (figuresPossitions[j].lvl == -1 ? 200 : 10);

                    if (figuresPossitions[i].lvl > figuresPossitions[j].lvl) {
                      combinedFigures.add(figuresPossitions[i]
                        ..lvl = upgrade
                        ..id = ++serialId
                        ..levelUp = true);
                    } else {
                      combinedFigures.add(figuresPossitions[i]
                        ..lvl = upgrade
                        ..id = ++serialId
                        ..levelUp = true);
                    }

                    biggerLvl = biggerLvl < figuresPossitions[i].lvl
                        ? figuresPossitions[i].lvl
                        : biggerLvl;
                  } else {
                    int upgrade = upgradeLevel(figuresPossitions[i].lvl,
                        figuresPossitions[j].lvl); //Subir de nivel o bajar.

                    points += (upgrade > 0) ? upgrade * 10 : 50;

                    if (figuresPossitions[i].lvl > figuresPossitions[j].lvl) {
                      combinedFigures.add(figuresPossitions[j]
                        ..lvl = upgrade
                        ..id = ++serialId
                        ..levelUp = true);
                    } else {
                      combinedFigures.add(figuresPossitions[j]
                        ..lvl = upgrade
                        ..id = ++serialId
                        ..levelUp = true);
                    }

                    biggerLvl = biggerLvl < figuresPossitions[j].lvl
                        ? figuresPossitions[j].lvl
                        : biggerLvl;
                  }

                  break;
                }
              }
              if (!isCombined && !indexDuplicated.contains(i)) {
                combinedFigures.add(figuresPossitions[i]);
              }
            }

            biggerLvl = calculateBiggerLevel();

            figuresPossitions = combinedFigures
              ..sort((a, b) => a.id.compareTo(b.id));

            if (indexDuplicated.isNotEmpty) {
              comboPossition = (
                rowIndex: combinedFigures[0].rowIndex,
                columnIndex: combinedFigures[0].columnIndex,
                steps: combinedFigures[0].steps
              );
            }

            if (!isFinish) {
              _addNewFigure();
              isFinish = isGameOver();
            }
          }
        });
      });
  }

  
  
  @override
  void dispose() {
    controllerMovements.dispose();
    super.dispose();
  }

  

  

  


  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constrains) {
      double paddingTop = 50;
      double paddingBottom = 50;

      gridWidth = (constrains.maxWidth - (50)) ~/ widthDimension + 0.0;
      gridHeight = (constrains.maxHeight - (paddingTop + paddingBottom)) ~/ heightDimension + 0.0;

      return Stack(
        children: [
          Container(
            child: GestureDetector(
              onVerticalDragEnd: (details) {
                // Swiping in up direction.
                if (details.velocity.pixelsPerSecond.dy > 0) {
                  if (!_isTransicion()) {
                    _calculateSpace(Move.down);
                    currentMovement = Move.down;
                    controllerMovements
                      ..reset()
                      ..forward();
                  }
                }
                if (details.velocity.pixelsPerSecond.dy < 0) {
                  if (!_isTransicion()) {
                    _calculateSpace(Move.up);
                    currentMovement = Move.up;
                    controllerMovements
                      ..reset()
                      ..forward();
                  }
                }
              },
              onHorizontalDragEnd: (details) {
                // Swiping in right direction.
                if (details.velocity.pixelsPerSecond.dx > 0) {
                  if (!_isTransicion()) {
                    _calculateSpace(Move.right);
                    currentMovement = Move.right;
                    controllerMovements
                      ..reset()
                      ..forward();
                  }
                }
                // Swiping in left direction.
                if (details.velocity.pixelsPerSecond.dx < 0) {
                  if (!_isTransicion()) {
                    _calculateSpace(Move.left);
                    currentMovement = Move.left;
                    controllerMovements
                      ..reset()
                      ..forward();
                  }
                }
              },
              child: Center(
                child: SizedBox(
                  width: widthDimension * gridWidth,
                  height: heightDimension * gridHeight,
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: Colors.black26,
                      ),
                      Stack(
                        children: figuresPossitions
                            .map((FigureInfo figure) =>
                                _buildFigureWithPossition(figure))
                            .toList(),
                      ),
                      ...[
                        isFinish
                            ? _buildGameOver()
                            : const SizedBox()
                      ],
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      );
    });
  }

  Positioned _buildFigureWithPossition(FigureInfo figure) {
    return Positioned(
      top: (currentMovement == Move.down)
          ? gridHeight *
              (figure.rowIndex +
                  figure.steps *
                      (animationMovements.value == 1
                          ? 0
                          : animationMovements.value))
          : (currentMovement == Move.up)
              ? gridHeight *
                  (figure.rowIndex -
                      figure.steps *
                          (animationMovements.value == 1
                              ? 0
                              : animationMovements.value))
              : figure.rowIndex * gridHeight,
      left: currentMovement == Move.right
          ? gridWidth *
              (figure.columnIndex +
                  figure.steps *
                      (animationMovements.value == 1
                          ? 0
                          : animationMovements.value))
          : currentMovement == Move.left
              ? gridWidth *
                  (figure.columnIndex -
                      figure.steps *
                          (animationMovements.value == 1
                              ? 0
                              : animationMovements.value))
              : figure.columnIndex * gridWidth,
      child: FigureView(
        key: ValueKey(figure.id),
        figureInfo: figure,
        maxWidth: gridWidth,
        maxHeight: gridHeight,
      ),
    );
  }

  























  void _calculateSpace(Move move) {
    List<({FigureInfo figure, int availableMovement})> available = [];
    _cleanLevelUp();
    switch (move) {
      case Move.up:
        available = _calculateAvailabilityTop();
        availableSpace = available;
        _refreshFigureWithNewAvailability(available);
      case Move.right:
        available = _calculateAvailabilityRight();
        availableSpace = available;
        _refreshFigureWithNewAvailability(available);

      case Move.down:
        available = _calculateAvailabilityDown();
        availableSpace = available;
        _refreshFigureWithNewAvailability(available);

      case Move.left:
        available = _calculateAvailabilityLeft();
        availableSpace = available;
        _refreshFigureWithNewAvailability(available);
    }
  }

  // Up movement
  List<({FigureInfo figure, int availableMovement})> _calculateAvailabilityTop() {
    // Calculate and represent the current positions of figures in a two-dimensional array
    Map<int, Map<int, FigureInfo?>> arrayIndexPoss = _initializaedArrayWithCurrentsPossitions();
    List<({FigureInfo figure, int availableMovement})> available = [];

    for (int column = 0; column < widthDimension; column++) {
      int availableMovement = 0;
      List<({FigureInfo figure, int availableMovement})> availableInColumn = [];

      bool combined = false;
      for (int row = 0; row < heightDimension; row++) {
        if (arrayIndexPoss[row]![column] == null) {
          availableMovement++;
        } else if ((!combined) &&
            (availableInColumn.isNotEmpty) &&
            (availableInColumn.last.figure.id !=
                arrayIndexPoss[row]![column]!.id) &&
            _pyramidRestroid(availableInColumn.last.figure.lvl, arrayIndexPoss[row]![column]!.lvl, row, column)) {
          availableMovement++;
          combined = true;

          availableInColumn.add((
            figure: arrayIndexPoss[row]![column]!,
            availableMovement: availableMovement
          ));
        } else {
          combined = false;
          availableInColumn.add((
            figure: arrayIndexPoss[row]![column]!,
            availableMovement: availableMovement
          ));
        }
      }

      available = [...available, ...availableInColumn];
    }

    return available;
  }
  // Down movement
  List<({FigureInfo figure, int availableMovement})> _calculateAvailabilityDown() {
    // Calculate and represent the current positions of figures in a two-dimensional array
    Map<int, Map<int, FigureInfo?>> arrayIndexPoss = _initializaedArrayWithCurrentsPossitions();
    List<({FigureInfo figure, int availableMovement})> available = [];

    for (int column = 0; column < widthDimension; column++) {
      int availableMovement = 0;
      List<({FigureInfo figure, int availableMovement})> availableInColumn = [];

      bool combined = false;
      for (int row = heightDimension - 1; row >= 0; row--) {
        if (arrayIndexPoss[row]![column] == null) {
          availableMovement++;
        } else if ((!combined) &&
            (availableInColumn.isNotEmpty) &&
            (availableInColumn.last.figure.id != arrayIndexPoss[row]![column]!.id) &&
              _pyramidRestroid(availableInColumn.last.figure.lvl, arrayIndexPoss[row]![column]!.lvl, row, column)) {
          availableMovement++;
          combined = true;

          availableInColumn.add((
            figure: arrayIndexPoss[row]![column]!,
            availableMovement: availableMovement
          ));
        } else {
          combined = false;
          availableInColumn.add((
            figure: arrayIndexPoss[row]![column]!,
            availableMovement: availableMovement
          ));
        }
      }

      available = [...available, ...availableInColumn];
    }

    return available;
  }
  // Right movement
  List<({FigureInfo figure, int availableMovement})>
      _calculateAvailabilityRight() {
    // Calculate and represent the current positions of figures in a two-dimensional array
    Map<int, Map<int, FigureInfo?>> arrayIndexPoss =
        _initializaedArrayWithCurrentsPossitions();
    List<({FigureInfo figure, int availableMovement})> available = [];

    for (int row = 0; row < heightDimension; row++) {
      int availableMovement = 0;
      List<({FigureInfo figure, int availableMovement})> availableInRow = [];

      bool combined = false;
      for (int column = widthDimension - 1; column >= 0; column--) {
        if (arrayIndexPoss[row]![column] == null) {
          availableMovement++;
        } else if ((!combined) &&
            (availableInRow.isNotEmpty) &&
            (availableInRow.last.figure.id != arrayIndexPoss[row]![column]!.id) &&
            _pyramidRestroid(availableInRow.last.figure.lvl, arrayIndexPoss[row]![column]!.lvl, row, column)) {
          availableMovement++;
          combined = true;

          availableInRow.add((
            figure: arrayIndexPoss[row]![column]!,
            availableMovement: availableMovement
          ));
        } else {
          combined = false;
          availableInRow.add((
            figure: arrayIndexPoss[row]![column]!,
            availableMovement: availableMovement
          ));
        }
      }

      available = [...available, ...availableInRow];
    }

    return available;
  }
  // Left movement
  List<({FigureInfo figure, int availableMovement})>
      _calculateAvailabilityLeft() {
    // Calculate and represent the current positions of figures in a two-dimensional array
    Map<int, Map<int, FigureInfo?>> arrayIndexPoss =
        _initializaedArrayWithCurrentsPossitions();
    List<({FigureInfo figure, int availableMovement})> available = [];

    for (int row = 0; row < heightDimension; row++) {
      int availableMovement = 0;
      List<({FigureInfo figure, int availableMovement})> availableInRow = [];

      bool combined = false;
      for (int column = 0; column < widthDimension; column++) {
        if (arrayIndexPoss[row]![column] == null) {
          availableMovement++;
        } else if ((!combined) &&
            (availableInRow.isNotEmpty) &&
            (availableInRow.last.figure.id != arrayIndexPoss[row]![column]!.id) &&
            _pyramidRestroid(availableInRow.last.figure.lvl, arrayIndexPoss[row]![column]!.lvl, row, column)) {
          availableMovement++;
          combined = true;

          availableInRow.add((
            figure: arrayIndexPoss[row]![column]!,
            availableMovement: availableMovement
          ));
        } else {
          combined = false;
          availableInRow.add((
            figure: arrayIndexPoss[row]![column]!,
            availableMovement: availableMovement
          ));
        }
      }

      available = [...available, ...availableInRow];
    }

    return available;
  }














  void _refreshFigureWithNewAvailability(
      List<({FigureInfo figure, int availableMovement})> available) {
    List<FigureInfo> temp = [];

    for (({FigureInfo figure, int availableMovement}) aval in available) {
      FigureInfo figure =
          figuresPossitions.firstWhere((e) => e.id == aval.figure.id);
      temp.add(figure..steps = aval.availableMovement);
    }

    figuresPossitions = temp..sort(((a, b) => a.id.compareTo(b.id)));
  }

  

  

  void _cleanLevelUp() {
    for (var element in figuresPossitions) {
      element.levelUp = false;
    }
  }

  bool isGameOver() {
    if (!isFullMatrix) {
      return false;
    }

    if (isAvalilableMovement(_calculateAvailabilityTop())) {
      return false;
    }
    if (isAvalilableMovement(_calculateAvailabilityDown())) {
      return false;
    }
    if (isAvalilableMovement(_calculateAvailabilityRight())) {
      return false;
    }
    if (isAvalilableMovement(_calculateAvailabilityLeft())) {
      return false;
    }

    return true;
  }

  bool isAvalilableMovement(List<({FigureInfo figure, int availableMovement})> avaliability) {
    for (({FigureInfo figure, int availableMovement}) aval in avaliability) {
      if (aval.availableMovement > 0) {
        return true;
      }
    }
    return false;
  }

  
  



  // Refactorized

  bool get isFullMatrix => figuresPossitions.length == heightDimension * widthDimension;
  bool _isTransicion() => (animationMovements.value > 0 && animationMovements.value < 1 || isFinish);



  int upgradeLevel(int lvl1, int lvl2) {
    if (lvl1 <= -1 and lvl2 <= -1) {
      // Both figures are pyramids
      return lvl1 == lvl2 ? -1 : -2;
    } else {
      if (lvl1 == lvl2) {
        // Ther aren't pyramids
        return lvl1 + 1;
      }
      
      // There is a pyramid
      if (lvl1 == -2 || lvl2 == -2){
        return lvl1 + lvl2 + 1 > 0 ? lvl1 + lvl2 + 1 : 1;
      } else {
        return lvl1.abs() + lvl2.abs();
      }
    }
  }
  int calculateBiggerLevel() {
    int bigger = 1;
    for (int i = 0; i < figuresPossitions.length; i++) {
      if (bigger < figuresPossitions[i].lvl) {
        bigger = figuresPossitions[i].lvl;
      }
    }
    return bigger;
  }
  bool _pyramidRestroid(int figure1, int figure2, int row, int column) {
    bool check = false;

    if ( figure1 == figure2) {
      check = true;
    } else if (figure1 < 0 && figure2 < 0) {
      check = true;
    } else if ((figure1 < 0 && figure2 == biggerLvl) || (figure2 < 0 && figure1 == biggerLvl)) {
      check = true;
    }

    return check;
  }




  Map<int, Map<int, FigureInfo?>> _initializaedArrayWithCurrentsPossitions() {
    Map<int, Map<int, FigureInfo?>> arrayIndexPoss = {};

    int externalDimension = heightDimension;
    int internalDimension = widthDimension;

    for (int i = 0; i < externalDimension; i++) {
      // Initialize de array in -1 values.
      arrayIndexPoss[i] = {};
      for (int j = 0; j < internalDimension; j++) {
        arrayIndexPoss[i]![j] = null;
      }
    }

    for (int i = 0; i < figuresPossitions.length; i++) {
      const int indexRow = figuresPossitions[i].rowIndex;
      const int indexColumn = figuresPossitions[i].columnIndex;

      arrayIndexPoss[indexRow]![indexColumn] = figuresPossitions[i];
    }

    return arrayIndexPoss;
  }
  ({int rowIndex, int columnIndex}) _getNewPoss() {
    const Map<int, Map<int, FigureInfo?>> arrayIndexPoss = _initializaedArrayWithCurrentsPossitions();
    const List<({int rowIndex, int columnIndex})> freePosition = [];

    for (int i = 0; i < heightDimension; i++) {
      for (int j = 0; j < widthDimension; j++) {
        if (arrayIndexPoss[i]![j] == null) {
          freePosition.add((rowIndex: i, columnIndex: j));
        }
      }
    }

    const int index = Random().nextInt(freePosition.length);
    return (
      rowIndex: freePosition[index].rowIndex,
      columnIndex: freePosition[index].columnIndex
    );
  }



  Container _buildGameOver(){
    return Container(
      decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius:
              BorderRadius.circular(5)),
      alignment: Alignment.center,
      child: ElevatedButton(
        child: const Text(
          'Try again!',
          style: TextStyle(
              color: textBody,
              fontSize: 14,
              fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          isFinish = false;
          figuresPossitions = [];
          controllerMovements
            ..reset()
            ..forward();
        },
      ),
    )
  }

















  void _addNewFigure() async {
    bool areEqual = true;
    if (lastState.length == figuresPossitions.length) {
      for (int i = 0; i < lastState.length; i++) {
        if (lastState[i] != figuresPossitions[i]) {
          areEqual = false;
          break;
        }
      }
    } else {
      areEqual = false;
    }


    if (!areEqual) {
      // Adding a new figure in the canvas
      if (!isFullMatrix) {
        __addfigure();
      }
      // Another figure
      if (!isFullMatrix && Random().nextInt(100) < 15) {
        __addfigure();
      }
    }

    lastState = figuresPossitions.map((e) => e.copyWidth()).toList();
  }
  void __addfigure() {
    int rm = Random().nextInt(200);
    int lvl = 1;
    if (rm < 5) {
      if (rm <= 1) {
        lvl = -1;
      } else {
        lvl = -2;
      }
    } else if (rm < 40) {
      lvl = 2;
    }

    ({int rowIndex, int columnIndex}) poss = _getNewPoss();
    figuresPossitions.add(FigureInfo(
      id: ++serialId,
      rowIndex: poss.rowIndex,
      columnIndex: poss.columnIndex,
      steps: 0,
      lvl: lvl,
    ));
  }
}