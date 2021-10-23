// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        title: 'Tic-Tac-Toe Demo',
        debugShowCheckedModeBanner: false,
        home: Center(
          child: GameBoard(),
        ));
  }
}

class States {
  //there can only be three kinds of states: x, o, and empty for each slot of the gameboard
  static const empty = '';
  static const X = 'X';
  static const O = 'O';
}

class GameBoard extends StatefulWidget {
  const GameBoard({Key? key}) : super(key: key);

  @override
  _GameBoardState createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  static final length = 3;
  static final double wl = 125;
  String prevMove = States.empty; //start at empty and make default case player X

  late List<List<String>>
      board; //set late here since it won't be initialized til later
  late List<int> scores; //index 0 is player 1, index 1 is player 2

  @override
  void initState() {
    super.initState();
    generateBoard(); //generates the board
    scores = [0, 0];
  }

  //generates 3 rows of 3 empty slots for the gameBoard;
  void generateBoard() => setState(() => board = List.generate(
        length,
        (row) => List.generate(length, (col) => States.empty),
      ));

  Widget buildSlot(int row, int col) {
    final state = board[row][col];
    return Container(
        margin: EdgeInsets.all(4),
        child: ElevatedButton(
          onPressed: () => tap(state, row, col),
          style: ElevatedButton.styleFrom(
              minimumSize: Size(wl, wl), primary: Colors.white),
          child: Center(
            child: Text(
              state,
              style: TextStyle(color: Colors.black, fontSize: 50),
            ),
          ),
        ));
  }

  void tap(String state, int row, int col) {
    if (state == States.empty) {
      final value = prevMove == States.X ? States.O : States.X;

      setState(() {
        prevMove = value;
        board[row][col] = value;
      });

      if (checkWin(row, col)) {
        //win con
        winner("Player $value won!");
        setState(() {
          value == 'X' ? scores[0]++ : scores[1]++;
        });
      } else if (noMoves()) {
        winner('It is a tie!');
      }
    }
  }

  bool noMoves() => board.every((row) => row.every((str) => str != States.empty)); //similar to javascript's Array.every function

  bool checkWin(int row, int col) {
    //yoinked clever algorithm from here: https://stackoverflow.com/questions/1056316/algorithm-for-determining-tic-tac-toe-game-over/1058804#1058804
    final currPlayer = board[row][col];
    final size = length; //length is initialized to be 3 in the beginning
    int horizontal = 0, vertical = 0, diagonal = 0, antidiagonal = 0;
    for (int i = 0; i < size; i++) {
      if (board[row][i] == currPlayer) vertical++;
      if (board[i][col] == currPlayer) horizontal++;
      if (board[i][i] == currPlayer) diagonal++;
      if (board[i][size - i - 1] == currPlayer) antidiagonal++;
    }

    return vertical == size ||
        horizontal == size ||
        diagonal == size ||
        antidiagonal == size;
  }

  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.yellow,
        appBar: AppBar(
          title: Center(child: Text('Tic-Tac-Toe', textAlign: TextAlign.center,)),
          backgroundColor: Colors.black,
          actions: [IconButton(onPressed: _scoreBoard, icon: Icon(Icons.assessment)), const Tooltip(message: "ScoreBoard")],
        ),
        body: Center(
            child: Table(
          defaultColumnWidth: FixedColumnWidth(125.0),
          children: [
            TableRow(children: [
              buildSlot(0, 0),
              buildSlot(0, 1),
              buildSlot(0, 2)
            ]), //manually built each slot, there is probably a better method but making it work is priority
            TableRow(
                children: [buildSlot(1, 0), buildSlot(1, 1), buildSlot(1, 2)]),
            TableRow(
                children: [buildSlot(2, 0), buildSlot(2, 1), buildSlot(2, 2)]),
          ],
        )));
  }

  void _scoreBoard() {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (context) { //pushes the new route on top of the navigator stack
      int index = 0;
      final tiles = scores.map((score) {
        index++;
        final player = index == 1 ? "X" : 'O';
        return ListTile(
          contentPadding: EdgeInsets.all(20.0),
          title: Center(child: Text("Player $player : $score", style: const TextStyle(fontSize: 50.0)),
        ));
      });
      final display = ListTile.divideTiles(
              context: context,
              tiles: tiles,
            ).toList();

       return Scaffold(
        appBar: AppBar(title: Center(child: Text('Score Board',)), backgroundColor: Colors.black,),
        body: ListView(children: display, padding: EdgeInsets.only(top: 300),
      ), backgroundColor: Colors.yellow,); 
    }));
  }

  winner(String text) => showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text(text, textAlign: TextAlign.center,),
          content: Text('Press restart to play again.', textAlign: TextAlign.center,),
          actions: [
            ElevatedButton(
              onPressed: () {
                generateBoard(); //resets board
                Navigator.of(context).pop(); //removes dialog
              },
              child: Center(child: Text('Restart')),
            )
          ],
        ),
      );
}
