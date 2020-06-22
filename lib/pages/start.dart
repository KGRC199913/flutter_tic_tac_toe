import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:tic_tac/components/btn.dart';
import 'package:tic_tac/components/logo.dart';
import 'package:tic_tac/pages/game.dart';
import 'package:tic_tac/pages/pick.dart';
import 'package:tic_tac/pages/settings.dart';
import 'package:tic_tac/services/alert.dart';
import 'package:tic_tac/services/board.dart';
import 'package:tic_tac/services/provider.dart';
import 'package:tic_tac/services/sound.dart';
import 'package:tic_tac/theme/theme.dart';

class StartPage extends StatelessWidget {
  final boardService = locator<BoardService>();
  final soundService = locator<SoundService>();
  final alertService = locator<AlertService>();

  StartPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        body: Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.1, 0.65],
              colors: [
                MyColors.deepPink,
                MyColors.darkIndigo,
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: SafeArea(
                  child: Stack(
                    //mainAxisSize: MainAxisSize.max,
                    //mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Logo(),
                      Align(
                        alignment: Alignment.center.add(Alignment.bottomCenter),
                        child: SizedBox(
                            width: 200,
                            height: 200,
                            child: SvgPicture.asset(
                              "assets/icons/gamepad.svg",
                            )),
                      ),
                      Align(
                        alignment: Alignment.topCenter,
                        child: Text(
                          "Tic Tac Toe",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 65,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'DancingScript'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Flexible(
                flex: 1,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Btn(
                     
                      onTap: () {
                        boardService.gameMode$.add(GameMode.Solo);
                        soundService.playSound('click');

                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => PickPage(),
                          ),
                        );
                      },
                      height: 60,
                      width: 250,
                      borderRadius: 50,
                      color: Colors.lightBlueAccent,
                      child: Text(
                        "single player".toUpperCase(),
                        style: TextStyle(
                            color: Colors.black.withOpacity(.8),
                            fontSize: 16,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                    SizedBox(height: 30),
                    Row( mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Btn(
                          onTap: () {
                            boardService.gameMode$.add(GameMode.Multi);
                            soundService.playSound('click');

                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => GamePage(),
                              ),
                            );
                          },
                          color: Colors.orange,
                          height: 80,
                          width: 110,
                          borderRadius: 20,
                          child: Column( mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SvgPicture.asset('assets/icons/dagger.svg', height: 40,),
                              Text(
                                "Local".toUpperCase(),
                                style: TextStyle(
                                    color: Colors.black.withOpacity(.8),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                           SizedBox(width: 30,),                
                    Btn(
                      onTap: () {
                        boardService.gameMode$.add(GameMode.Online);
                        soundService.playSound('click');
                        boardService.initNetwork();
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => GamePage(),
                          ),
                        );
                      },
                      color: Colors.white,
                      height: 80,
                      width: 110,
                      borderRadius: 20,
                      child: Column( mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SvgPicture.asset('assets/icons/online-game.svg', height: 40,),
                          Text(
                            "online".toUpperCase(),
                            style: TextStyle(
                                color: Colors.black.withOpacity(.8),
                                fontSize: 16,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                      ],
                    ),
 
                    SizedBox(height: 40),
                    Btn( 
                      onTap: () {
                        soundService.playSound('click');
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            fullscreenDialog: true,
                            builder: (context) => SettingsPage(),
                          ),
                        );
                      },
                      color: Colors.white,
                      height: 50,
                      width: 50,
                      borderRadius: 25,
                      child: Icon(Icons.settings),
                    ),
              SafeArea(child: Text('A Project of TeamX', style: TextStyle(color: Colors.white.withOpacity(.5)),))
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
