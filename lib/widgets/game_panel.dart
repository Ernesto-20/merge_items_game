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

  int serialId = 0;
  late List<FigureInfo> lastState;

  // State of figures
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

  
  
  
  
  
  @override
  void initState() {
    super.initState();
    lastState = figuresPossitions.map((e) => e.copyWidth()).toList();
    controllerMovements = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));

    animationMovements = Tween<double>(begin: 0, end: 1).animate(controllerMovements)
      ..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // La animación ha terminado
        _onAnimationComplete();
      }
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
                if (!_isTransicion()) {
                  Move move = details.velocity.pixelsPerSecond.dy > 0 ? Move.down : Move.up;
                  currentMovement = move;
                  _calculateSpace(move);
                  controllerMovements..reset()..forward();
                }
              },
              onHorizontalDragEnd: (details) {
                if (!_isTransicion()) {
                  Move move = details.velocity.pixelsPerSecond.dx > 0 ? Move.right : Move.left;
                  currentMovement = move;
                  _calculateSpace(Move.right);
                  controllerMovements..reset()..forward();
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


  // Widgets
  Positioned _buildFigureWithPossition(FigureInfo figure) {
    double verticalScrolling = figure.rowIndex * gridHeight;
    if (currentMovement == Move.down)
      verticalScrolling = gridHeight * (figure.rowIndex + figure.steps * (animationMovements.value == 1 ? 0 : animationMovements.value));
    else if (currentMovement == Move.up)
      verticalScrolling = gridHeight * (figure.rowIndex - figure.steps * (animationMovements.value == 1 ? 0 : animationMovements.value));

    double horizontalScrolling = figure.columnIndex * gridWidth;
    if (currentMovement == Move.right)
      horizontalScrolling = gridWidth * (figure.columnIndex + figure.steps * (animationMovements.value == 1 ? 0 : animationMovements.value));
    else if (currentMovement == Move.left)
      horizontalScrolling = gridWidth * (figure.columnIndex - figure.steps * (animationMovements.value == 1 ? 0 : animationMovements.value));


    return Positioned(
      top: verticalScrolling,
      left: horizontalScrolling,
      child: FigureView(
        key: ValueKey(figure.id),
        figureInfo: figure,
        maxWidth: gridWidth,
        maxHeight: gridHeight,
      ),
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

  
  // Calculate movements to scroll through the board 

  void _calculateSpace(Move move) {
    List<({FigureInfo figure, int availableMovement})> available = [];
    _cleanLevelUp();

    available = _calculateAvailability(move);
    _refreshFigureWithNewAvailability(available);
  }

  List<({FigureInfo figure, int availableMovement})> _calculateAvailability(Move move) {
    Map<int, Map<int, FigureInfo?>> arrayIndexPoss = _getCurrentMatrix();
    List<({FigureInfo figure, int availableMovement})> available = [];

    bool isVertical = move == Move.up || move == Move.down;
    bool isReversed = move == Move.down || move == Move.right;

    int outerLimit = isVertical ? widthDimension : heightDimension;
    int innerLimit = isVertical ? heightDimension : widthDimension;

    for (int outer = 0; outer < outerLimit; outer++) {
      int availableMovement = 0;
      List<({FigureInfo figure, int availableMovement})> availableInLine = [];
      bool combined = false;

      for (int inner = isReversed ? innerLimit - 1 : 0;
          isReversed ? inner >= 0 : inner < innerLimit;
          isReversed ? inner-- : inner++) {
        int row = isVertical ? inner : outer;
        int column = isVertical ? outer : inner;

        if (arrayIndexPoss[row]![column] == null) {
          availableMovement++;
        } else if ((!combined) &&
            (availableInLine.isNotEmpty) &&
            (availableInLine.last.figure.id != arrayIndexPoss[row]![column]!.id) &&
            _canBeCombined(availableInLine.last.figure.lvl, arrayIndexPoss[row]![column]!.lvl, row, column)) {
          availableMovement++;
          combined = true;

          availableInLine.add((
            figure: arrayIndexPoss[row]![column]!,
            availableMovement: availableMovement
          ));
        } else {
          combined = false;
          availableInLine.add((
            figure: arrayIndexPoss[row]![column]!,
            availableMovement: availableMovement
          ));
        }
      }

      available = [...available, ...availableInLine];
    }

    return available;
  }

  void _refreshFigureWithNewAvailability(List<({FigureInfo figure, int availableMovement})> available) {
    List<FigureInfo> temp = [];

    for (({FigureInfo figure, int availableMovement}) aval in available) {
      FigureInfo figure = figuresPossitions.firstWhere((e) => e.id == aval.figure.id);
      temp.add(figure..steps = aval.availableMovement);
    }

    figuresPossitions = temp..sort(((a, b) => a.id.compareTo(b.id)));
  }

  bool _canBeCombined(int figure1, int figure2, int row, int column) {
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
  

  
  // Check if the game is over  
  bool isGameOver() {
    if (!isFullMatrix()) {
      return false;
    }

     for (Move move in Move.values) {
      if (_isThereAvalilableMovement(_calculateAvailability(move))) {
        return false;
      }
    }

    return true;
  }
  bool _isThereAvalilableMovement(List<({FigureInfo figure, int availableMovement})> avaliability) {
    for (({FigureInfo figure, int availableMovement}) aval in avaliability) {
      if (aval.availableMovement > 0) {
        return true;
      }
    }
    return false;
  }
  
  
  

  // Others methods
  bool isFullMatrix() => figuresPossitions.length == heightDimension * widthDimension;
  bool _isTransicion() => (animationMovements.value > 0 && animationMovements.value < 1 || isFinish);
  int _calcLevel(int lvl1, int lvl2) {
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
  int _calcBiggerLevel() {
    return figuresPossitions.isEmpty ? 1 : figuresPossitions.map((figure) => figure.lvl).reduce(max);
  }
  Map<int, Map<int, FigureInfo?>> _getCurrentMatrix() {
    Map<int, Map<int, FigureInfo?>> arrayIndexPoss = {};

    int outer = heightDimension;
    int inner = widthDimension;

    for (int i = 0; i < outer; i++) {
      // Initialize de array in null values.
      arrayIndexPoss[i] = {};
      for (int j = 0; j < inner; j++) {
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
  ({int rowIndex, int columnIndex}) _getRandomEmptyPossition() {
    const Map<int, Map<int, FigureInfo?>> arrayIndexPoss = _getCurrentMatrix();
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
  void _cleanLevelUp() {
    for (var element in figuresPossitions) {
      element.levelUp = false;
    }
  }
  void _updateFiguresPosition() {
    for (int i = 0; i < figuresPossitions.length; i++) {
      if (currentMovement == Move.down)
        figuresPossitions[i].rowIndex += figuresPossitions[i].steps;
      else if (currentMovement == Move.up)
        figuresPossitions[i].rowIndex -= figuresPossitions[i].steps;
      else if (currentMovement == Move.right)
        figuresPossitions[i].columnIndex += figuresPossitions[i].steps;
      else if (currentMovement == Move.left)
        figuresPossitions[i].columnIndex -= figuresPossitions[i].steps;
    }
  }
  void _onAnimationComplete() {
   // Setting the nuews rowIndex and columnIndex of the figures
    _updateFiguresPosition();

    // Getting the new figures list after combining them
    List<FigureInfo> combinedFigures = [];
    Set<int> indexDuplicated = {};
    points = 0;
    for (int i = 0; i < figuresPossitions.length; i++) {
      if (indexDuplicated.contains(i)) continue;

      bool isCombined = false;

      for (int j = i + 1; j < figuresPossitions.length; j++) {
        if (indexDuplicated.contains(j)) continue;

        if (figuresPossitions[i].isAtSamePosition(figuresPossitions[j])) {
          isCombined = true;
          indexDuplicated.add(j);

          int upgrade = _calcLevel(figuresPossitions[i].lvl, figuresPossitions[j].lvl);
          points += (upgrade > 0) ? upgrade * 10 : 50;

          combinedFigures.add(FigureInfo(
            id: ++serialId,
            rowIndex: figuresPossitions[i].rowIndex,
            columnIndex: figuresPossitions[i].columnIndex,
            steps: 0,
            lvl: upgrade,
            levelUp: true,
          ));

          break;
        }
      }

      if (!isCombined) {
        combinedFigures.add(figuresPossitions[i]);
      }
    }


    biggerLvl = _calcBiggerLevel();
    figuresPossitions = combinedFigures..sort((a, b) => a.id.compareTo(b.id));
    _tryAddFigure();
    isFinish = isGameOver();
  }
  




  // Generate new figure to the board

  void _tryAddFigure() {
    if (!_hasStateChanged()) return;

    // Adding a new figure to the board
    if (isFullMatrix())
      _addFigure();

    // Add another figure with a 15% chance
    if (!isFullMatrix() && Random().nextInt(100) < 15)
      _addFigure();

    // Update the last state to the current state
    lastState = figuresPossitions.map((e) => e.copyWidth()).toList();
  }

  bool _hasStateChanged() {
    if (lastState.length != figuresPossitions.length) return true;

    for (int i = 0; i < lastState.length; i++) {
      if (lastState[i] != figuresPossitions[i]) {
        return true;
      }
    }
    return false;
  }

  void _addFigure() {
    int level = _generateRandomLevel();
    var position = _getRandomEmptyPosition();

    figuresPossitions.add(FigureInfo(
      id: ++serialId,
      rowIndex: position.rowIndex,
      columnIndex: position.columnIndex,
      steps: 0,
      lvl: level,
    ));
  }

  int _generateRandomLevel() {
    int randomValue = Random().nextInt(200);

    if (randomValue < 5) {
      return randomValue <= 1 ? -1 : -2; // Possitive and Nevative Pyramid with the same probability 
    } else if (randomValue < 30) {
      return 2; // Level 2
    }
    return 1; // Level 1 by default
  }
}