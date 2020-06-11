import 'package:rxdart/rxdart.dart';

class OnlineService {
  BehaviorSubject<MapEntry<int, int>> _otherPlayerMove;

  BehaviorSubject<MapEntry<int, int>> get otherPlayerMove => _otherPlayerMove;

  OnlineService() {
    _initStream();
  }

  _initStream() {
    _otherPlayerMove =
        BehaviorSubject<MapEntry<int, int>>.seeded(MapEntry(-1, -1));
  }

  move(int i, int j) async {
    await Future.delayed(const Duration(seconds: 5));
    _otherPlayerMove.add(MapEntry(1, 1));
  }

  dispose() {
    _otherPlayerMove.close();
  }
}
