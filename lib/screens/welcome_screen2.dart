import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../gv_chat_icons.dart';
import './login_screen.dart';
import './signup_screen.dart';
import '../buttons/primary_button.dart';

class WelcomeScreen2 extends StatefulWidget {
  static const routeName = '/welcome';
  const WelcomeScreen2({Key? key}) : super(key: key);

  @override
  _WelcomeScreen2State createState() => _WelcomeScreen2State();
}

class _WelcomeScreen2State extends State<WelcomeScreen2> {
  googleLogin() async {
    final googleSignIn = GoogleSignIn();
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) return;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await FirebaseAuth.instance.signInWithCredential(credential);
    // if (!documentSnapshot.exists) {
    //   await showUsernameDialog(credential);
    // } else {

    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                children: [
                  //   SizedBox(
                  //   height: 30,
                  // ),
                  Image.asset(
                    'assets/images/chat.png',
                    scale: 2,
                    // ewidth: MediaQuery.of(context).size.width,
                  ),

                  Positioned(
                    top: 340,
                    height: 100,
                    left: 22,
                    child: Text(
                      'Destiny',
                      style: GoogleFonts.spaceGrotesk(
                        color: Color(0xFF009cfe),
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 22,
                    top: 392,
                    child: Text(
                      'Chat',
                      textAlign: TextAlign.left,
                      style: GoogleFonts.spaceGrotesk(
                          color: Colors.white,
                          fontSize: 50,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              // SizedBox(
              //   height: 50,
              // ),
              // Spacer(),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13.0)),
                          minimumSize: Size(104, 48),
                          primary: Colors.blue,
                        ),
                        onPressed: () {
                          Navigator.of(context)
                              .pushNamed(LoginScreen.routeName);
                        },
                        child: Text('LOGIN',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 18))),
                  ),
                  PrimaryButton(
                    icon: Icons.add_box_outlined,
                    text: 'CREATE NEW ACCOUNT',
                    press: () {
                      Navigator.of(context).pushNamed(SignupScreen.routeName);
                    },
                  ),
                  SizedBox(
                    height: 17,
                  ),
                  // PrimaryButton(
                  //     icon: Icons.account_box_outlined,
                  //     press: () {
                  //       Navigator.of(context)
                  //           .pushNamed(LoginScreen.routeName);
                  //     },
                  //     text: 'Login to your account'),
                  // SizedBox(
                  //   height: 10,
                  // ),
                  PrimaryButton(
                      icon: CustomIcons.google,
                      press: () async {
                        googleLogin();
                      },
                      text: 'CONTINUE WITH GOOGLE'),
                  // PrimaryButton(
                  //     icon: CustomIcons.google,
                  //     press: () async {
                  //       googleLogin();
                  //     },
                  //     text: 'CONTINUE WITH GOOGLE'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
