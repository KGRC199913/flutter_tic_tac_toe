import 'dart:math' as math;

import 'package:rxdart/rxdart.dart';
import 'package:tic_tac/services/online.dart';
import 'package:tic_tac/services/provider.dart';
import 'package:tic_tac/services/sound.dart';

final soundService = locator<SoundService>();
final onlineService = locator<OnlineService>();

enum BoardState { Done, Play, Wait, Init }
enum GameMode { Solo, Multi, Online }

class BoardService {
  BehaviorSubject<List<List<String>>> _board$;

  BehaviorSubject<List<List<String>>> get board$ => _board$;

  BehaviorSubject<String> _player$;

  BehaviorSubject<String> get player$ => _player$;

  BehaviorSubject<MapEntry<BoardState, String>> _boardState$;

  BehaviorSubject<MapEntry<BoardState, String>> get boardState$ => _boardState$;

  BehaviorSubject<GameMode> _gameMode$;

  BehaviorSubject<GameMode> get gameMode$ => _gameMode$;

  BehaviorSubject<MapEntry<int, int>> _score$;

  BehaviorSubject<MapEntry<int, int>> get score$ => _score$;

  String _start;

  String _assignedSign;

  BoardService() {
    _initStreams();

    onlineService.otherPlayerMove.listen((opponentMove) {
      int i = opponentMove.key;
      int j = opponentMove.value;

      if (i == -1 || j == -1) {
        return;
      }

      var player = _player$.value;
      List<List<String>> currentBoard = _board$.value;

      currentBoard[i][j] = player;
      _board$.add(currentBoard);
      _playMoveSound(player);
      switchPlayer(player);

      bool isWinner = _checkWinner(i, j);
      boardState$.add(MapEntry(BoardState.Play, player));

      if (isWinner) {
        _updateScore(player);
        _boardState$.add(MapEntry(BoardState.Done, player));
        return;
      } else if (isBoardFull()) {
        _boardState$.add(MapEntry(BoardState.Done, null));
      }
    });

    onlineService.networkStatus.listen((status) {
      if (status == "?") {
        return;
      }

      if (status == null) {
        _player$.add(null);
        boardState$.add(MapEntry(BoardState.Init, status));
        return;
      }

      if (status == "!") {
        _player$.add(null);
        _boardState$.add(MapEntry(BoardState.Done, "!"));
        return;
      }

      _player$.add(status);
      _assignedSign = status;

      var isFirst = onlineService.isFirst.value;
      if (isFirst) {
        boardState$.add(MapEntry(BoardState.Play, status));
      } else {
        switchPlayer(status);
        boardState$.add(MapEntry(BoardState.Wait, status));
      }
    });
  }

  void newMove(int i, int j) {
    if (_gameMode$.value == GameMode.Online &&
        boardState$.value.key == BoardState.Wait) {
      return;
    }

    String player = _player$.value;
    List<List<String>> currentBoard = _board$.value;

    currentBoard[i][j] = player;
    _playMoveSound(player);
    _board$.add(currentBoard);
    switchPlayer(player);

    bool isWinner = _checkWinner(i, j);

    if (_gameMode$.value == GameMode.Online) {
      _boardState$.add(MapEntry(BoardState.Wait, player));
      onlineService.move(i, j);
    }

    if (isWinner) {
      _updateScore(player);
      _boardState$.add(MapEntry(BoardState.Done, player));
      return;
    } else if (isBoardFull()) {
      _boardState$.add(MapEntry(BoardState.Done, null));
    } else if (_gameMode$.value == GameMode.Solo) {
      botMove();
    }
  }

  botMove() {
    String player = _player$.value;
    List<List<String>> currentBoard = _board$.value;
    List<List<int>> temp = List<List<int>>();
    for (var i = 0; i < currentBoard.length; i++) {
      for (var j = 0; j < currentBoard[i].length; j++) {
        if (currentBoard[i][j] == " ") {
          temp.add([i, j]);
        }
      }
    }

    math.Random rnd = new math.Random();
    int r = rnd.nextInt(temp.length);
    int i = temp[r][0];
    int j = temp[r][1];

    currentBoard[i][j] = player;
    _board$.add(currentBoard);
    switchPlayer(player);

    bool isWinner = _checkWinner(i, j);

    if (isWinner) {
      _updateScore(player);
      _boardState$.add(MapEntry(BoardState.Done, player));
      return;
    } else if (isBoardFull()) {
      _boardState$.add(MapEntry(BoardState.Done, null));
    }
  }

  _updateScore(String winner) {
    if (winner == "O") {
      _score$.add(MapEntry(_score$.value.key, _score$.value.value + 1));
    } else if (winner == "X") {
      _score$.add(MapEntry(_score$.value.key + 1, _score$.value.value));
    }
  }

  _playMoveSound(player) {
    if (player == "X") {
      soundService.playSound('x');
    } else {
      soundService.playSound('o');
    }
  }

  bool _checkWinner(int x, int y) {
    var currentBoard = _board$.value;

    var col = 0, row = 0, diag = 0, rdiag = 0;
    var n = currentBoard.length - 1;
    var player = currentBoard[x][y];

    for (int i = 0; i < currentBoard.length; i++) {
      if (currentBoard[x][i] == player) col++;
      if (currentBoard[i][y] == player) row++;
      if (currentBoard[i][i] == player) diag++;
      if (currentBoard[i][n - i] == player) rdiag++;
    }
    if (row == n + 1 || col == n + 1 || diag == n + 1 || rdiag == n + 1) {
      return true;
    }
    return false;
  }

  void setStart(String e) {
    _start = e;
  }

  void switchPlayer(String player) {
    if (player == 'X') {
      _player$.add('O');
    } else {
      _player$.add('X');
    }
  }

  bool isBoardFull() {
    List<List<String>> board = _board$.value;
    int count = 0;
    for (var i = 0; i < board.length; i++) {
      for (var j = 0; j < board[i].length; j++) {
        if (board[i][j] == ' ') count = count + 1;
      }
    }
    if (count == 0) return true;

    return false;
  }

  void resetBoard({String winner = ""}) {
    _board$.add([
      [' ', ' ', ' '],
      [' ', ' ', ' '],
      [' ', ' ', ' ']
    ]);
    _player$.add(_start);

    if (_gameMode$.value == GameMode.Online) {
      if (winner == _assignedSign) {
        _boardState$.add(MapEntry(BoardState.Wait, ""));

        if (_assignedSign == "O") {
          _player$.add("X");
        } else {
          _player$.add("O");
        }
      } else if (winner != _assignedSign && winner != null) {
        _boardState$.add(MapEntry(BoardState.Play, ""));
        _player$.add(_assignedSign);
      } else {
        if (_assignedSign != "X") {
          _boardState$.add(MapEntry(BoardState.Wait, ""));
        } else {
          _boardState$.add(MapEntry(BoardState.Play, ""));
        }
        _player$.add("X");
      }
    } else {
      _boardState$.add(MapEntry(BoardState.Play, ""));
      if (_assignedSign == "O") {
        _player$.add("X");
      }
    }
  }

  void newGame() {
    resetBoard();
    _score$.add(MapEntry(0, 0));
  }

  void initNetwork() {
    boardState$.add(MapEntry(BoardState.Init, ""));
    onlineService.init();
  }

  void disconnectOnlineGame() {
    _score$.add(MapEntry(0, 0));
    onlineService.disconnect();
  }

  void _initStreams() {
    _board$ = BehaviorSubject<List<List<String>>>.seeded([
      [' ', ' ', ' '],
      [' ', ' ', ' '],
      [' ', ' ', ' ']
    ]);
    _player$ = BehaviorSubject<String>.seeded("X");
    _boardState$ = BehaviorSubject<MapEntry<BoardState, String>>.seeded(
      MapEntry(BoardState.Play, ""),
    );
    _gameMode$ = BehaviorSubject<GameMode>.seeded(GameMode.Solo);
    _score$ = BehaviorSubject<MapEntry<int, int>>.seeded(MapEntry(0, 0));
    _start = 'X';
  }
}
