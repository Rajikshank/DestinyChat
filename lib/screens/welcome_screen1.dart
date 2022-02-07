import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:gvchat/screens/welcome_screen2.dart';

class WelcomeScreen1 extends StatelessWidget {
  const WelcomeScreen1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Column(
        // crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/logo.png',
            height: 150,
            width: 150,
            // scale: 0.5,
          ),
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                Colors.blue,
                Colors.deepPurple,
                Colors.pink,
              ],
            ).createShader(bounds),
            child: Text(
              'Destiny Chat',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline1!.copyWith(
                    fontSize: 40,
                  ),
            ),
          ),
        ],
      ),
      nextScreen: WelcomeScreen2(),
      splashTransition: SplashTransition.fadeTransition,
      backgroundColor: Color(0xFF0d0b14),
    );
  }
}
