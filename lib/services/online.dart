import 'dart:math';

import 'package:rxdart/rxdart.dart';

class OnlineService {
  BehaviorSubject<MapEntry<int, int>> _otherPlayerMove;

  BehaviorSubject<MapEntry<int, int>> get otherPlayerMove => _otherPlayerMove;

  BehaviorSubject<String> _networkStatus;

  BehaviorSubject<String> get networkStatus => _networkStatus;

  OnlineService() {
    _initStream();
  }

  _initStream() {
    _otherPlayerMove =
        BehaviorSubject<MapEntry<int, int>>.seeded(MapEntry(-1, -1));
    _networkStatus = BehaviorSubject<String>.seeded("?");
  }

  init() async {
    await Future.delayed(const Duration(seconds: 3));

    var rng = Random();
    var result = rng.nextBool();
    var player = "";
    if (result) {
      player = "X";
    } else {
      player = "O";
    }

    print("TEST !!! > $player");
    _networkStatus.add(player);
  }

  disconnect() async {
    await Future.delayed(const Duration(seconds: 1));
    _networkStatus.add(null);
  }

  move(int i, int j) async {
    await Future.delayed(const Duration(seconds: 5));
    _otherPlayerMove.add(MapEntry(1, 1));
  }

  dispose() {
    _otherPlayerMove.close();
    _networkStatus.close();
  }
}
