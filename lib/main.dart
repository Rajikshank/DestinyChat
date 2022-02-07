import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gvchat/screens/choose_username_screen.dart';
import 'package:gvchat/screens/group_detail_screen.dart';
import 'package:gvchat/screens/new_public.dart';
import 'package:gvchat/screens/profile_screen.dart';
import 'package:gvchat/helpers/public_chat_meths.dart';
import 'package:gvchat/screens/public_chat_screen.dart';

import './screens/contacts_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/login_screen.dart';
import 'screens/welcome_screen1.dart';
import 'screens/welcome_screen2.dart';
import './screens/chat_screen.dart';
import './screens/new_group_screen.dart';
import 'helpers/public_chat_meths.dart';

import './theme.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Future<FirebaseApp> _initialization = Firebase.initializeApp();
    return FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
          return MaterialApp(
            title: 'Destiny Chat',
            theme: darkThemeData(context),
            debugShowCheckedModeBanner: false,
            home: snapshot.connectionState != ConnectionState.done
                ? WelcomeScreen1()
                : StreamBuilder(
                    initialData: WelcomeScreen1(),
                    stream: FirebaseAuth.instance.authStateChanges(),
                    builder: (BuildContext ctx, userSnapshot) {
                      if (userSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return WelcomeScreen1();
                      }
                      if (userSnapshot.hasData) {
                        if (Navigator.of(ctx).canPop()) {
                          Navigator.of(ctx).pop();
                        }
                        return ContactsScreen();
                      }
                      return WelcomeScreen2();
                    },
                  ),
            routes: {
              ChooseUsernameScreen.routeName: (ctx) => ChooseUsernameScreen(),
              GroupDetailScreen.routeName: (ctx) => GroupDetailScreen(),
              ProfileScreen.routeName: (ctx) => ProfileScreen(),
              NewGroupScreen.routeName: (ctx) => NewGroupScreen(),
              LoginScreen.routeName: (ctx) => LoginScreen(),
              SignupScreen.routeName: (ctx) => SignupScreen(),
              ChatScreen.routeName: (ctx) => ChatScreen(),
              ContactsScreen.routeName: (ctx) => ContactsScreen(),
              Public_details.routeName: (ctx) => Public_details(),
              public_screen.routeName: (ctx) => public_screen(),
              NewPublicScreen.routeName: (ctx) => NewPublicScreen(),
            },
          );
        });
  }
}
