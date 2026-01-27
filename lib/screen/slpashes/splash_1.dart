import 'package:daleel/screen/slpashes/on_boarding.dart';
import 'package:daleel/widgets/animated_logo.dart';
import 'package:flutter/material.dart';


class Splash1 extends StatelessWidget {
  const Splash1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedLogo(
          onAnimationComplete: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>  Splash2(),
              ),
            );
          },
        ),
      ),
    );
  }
}