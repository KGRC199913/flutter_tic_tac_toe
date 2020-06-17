import 'package:rxdart/rxdart.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class OnlineService {
  BehaviorSubject<MapEntry<int, int>> _otherPlayerMove;

  BehaviorSubject<MapEntry<int, int>> get otherPlayerMove => _otherPlayerMove;

  BehaviorSubject<String> _networkStatus;

  BehaviorSubject<String> get networkStatus => _networkStatus;

  BehaviorSubject<bool> _isFirst;

  BehaviorSubject<bool> get isFirst => _isFirst;

  static const _url = "http://10.0.2.2:3000/";

  IO.Socket io;

  String _currentUid;
  String _currentCompetitorUid;
  String _currentMatchId;
  String _playerSign;

  OnlineService() {
    _initStream();
  }

  _initStream() {
    _otherPlayerMove =
        BehaviorSubject<MapEntry<int, int>>.seeded(MapEntry(-1, -1));
    _networkStatus = BehaviorSubject<String>.seeded("?");
    _isFirst = BehaviorSubject<bool>.seeded(true);
  }

  void init() {
    io = IO.io(_url, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false
    });

    io.on('connect', (_) {
      io.emit('JOIN_OWN_ROOM', {"connect": true});
    });

    io.on('SEND_ID', (data) {
      _currentUid = data["userId"];

      io.emit('FIND_MATCH', {"userId": _currentUid});
    });

    io.on('MATCH_FOUND', (data) {
      _currentMatchId = data['matchId'];
      _currentCompetitorUid = data['competitor'];
      bool isFirst = data['yourTurn'];
      String assignedSign = data['sign'];

      _playerSign = assignedSign;

      _isFirst.add(isFirst);
      _networkStatus.add(assignedSign);
    });

    io.on('NEXT_STEP', (data) {
      int xPos = data['x'];
      int yPos = data['y'];

      _otherPlayerMove.add(MapEntry(xPos, yPos));
    });

    io.on('END_GAME', (data) {
      _networkStatus.add("!");
    });

    io.connect();
  }

  disconnect() {
    _networkStatus.add(null);
    io.disconnect();
    io = null;
  }

  move(int i, int j) {
    io.emit('NEXT_STEP',
        {"userId": _currentUid, "matchId": _currentMatchId, "x": i, "y": j});
  }

  dispose() {
    if (io != null) {
      io.disconnect();
      io = null;
    }
    _otherPlayerMove.close();
    _networkStatus.close();
    _isFirst.close();
  }
}
