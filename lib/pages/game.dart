import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tic_tac/components/board.dart';
import 'package:tic_tac/components/o.dart';
import 'package:tic_tac/components/x.dart';
import 'package:tic_tac/services/board.dart';
import 'package:tic_tac/services/provider.dart';
import 'package:tic_tac/theme/theme.dart';

class GamePage extends StatefulWidget {
  GamePageState createState() => GamePageState();
}

class GamePageState extends State<GamePage> {
  final boardService = locator<BoardService>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        boardService.newGame();
        return true;
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: StreamBuilder<
                    MapEntry<MapEntry<int, int>, MapEntry<BoardState, String>>>(
                stream: Observable.combineLatest2(
                    boardService.score$,
                    boardService.boardState$,
                    (score, state) => MapEntry(score, state)),
                builder: (context,
                    AsyncSnapshot<
                            MapEntry<MapEntry<int, int>,
                                MapEntry<BoardState, String>>>
                        snapshot) {
                  if (!snapshot.hasData) {
                    return Container();
                  }
                  final int xScore = snapshot.data.key.key;
                  final int oScore = snapshot.data.key.value;

                  if (snapshot.data.value.key == BoardState.Init) {
                    return Flex(
                      direction: Axis.horizontal,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text("waiting for a match".toUpperCase()),
                              CircularProgressIndicator()
                            ],
                          ),
                        )
                      ],
                    );
                  } else {
                    return Container(
                      // color: Colors.red,
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  color: Colors.white,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      SizedBox(
                                        height: 40,
                                        width: 40,
                                        child: Material(
                                          elevation: 5,
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          child: Center(
                                              child: Text(
                                            "$xScore",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 18),
                                          )),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(),
                                      ),
                                      X(35, 10),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Text(
                                          "Player",
                                          style: TextStyle(fontSize: 20),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                    child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[Board()],
                                )),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  color: Colors.white,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      O(35, MyTheme.green),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10,
                                        ),
                                        child: Text(
                                          "Player",
                                          style: TextStyle(fontSize: 20),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(),
                                      ),
                                      SizedBox(
                                        height: 40,
                                        width: 40,
                                        child: Material(
                                          elevation: 5,
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          child: Center(
                                              child: Text(
                                            "$oScore",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 18),
                                          )),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            color: Colors.white,
                            height: 60,
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Expanded(
                                  child: Container(),
                                ),
                                IconButton(
                                  icon: Icon(Icons.home),
                                  onPressed: () {
                                    boardService.newGame();
                                    if (boardService.gameMode$.value ==
                                        GameMode.Online) {
                                      boardService.disconnectOnlineGame();
                                    }
                                    Navigator.of(context)
                                        .popUntil((route) => route.isFirst);
                                  },
                                  color: Colors.black87,
                                  iconSize: 30,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                }),
          ),
        ),
      ),
    );
  }
}
