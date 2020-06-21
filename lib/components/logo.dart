import 'package:flutter/material.dart';
import 'package:tic_tac/theme/theme.dart';

class Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          height: 400,
          width: 600,
          child: Stack(
            children: <Widget>[
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  height: 65,
                  width: 65,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(65 / 2),
                    gradient: RadialGradient(
                      radius: 0.18,
                      colors: [
                        Colors.transparent,
                        Colors.black87.withOpacity(.65)
                        
                      ],
                      stops: [1, 1],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 10,
                child: RotationTransition(
                  turns: AlwaysStoppedAnimation(-50 / 360),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(200),
                      color: Colors.black87.withOpacity(.67),
                    ),
                    height: 25,
                    width: 200,
                  ),
                ),
              ),
              Positioned(
                left: 50,
                top: 30,
                child: RotationTransition(
                  turns: AlwaysStoppedAnimation(40 / 360),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(200),
                      color: Colors.black87.withOpacity(.71),
                    ),
                    height: 25,
                    width: 140,
                  ),
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
