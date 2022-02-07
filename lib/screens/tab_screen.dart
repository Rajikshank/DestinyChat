import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gvchat/screens/contacts_screen.dart';

import '../constants.dart';
import '../widgets/search/search.dart';
import './profile_screen.dart';

class TabScreen extends StatefulWidget {
  const TabScreen({Key? key}) : super(key: key);

  @override
  _TabScreenState createState() => _TabScreenState();
}

class _TabScreenState extends State<TabScreen> {
  getUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();

    Constants.myUserName = userData.data()!['username'].toString();
    print("Username: ${userData.data()!['username']}");
    print("Constants.myUserName: ${Constants.myUserName}");
    Constants.myEmail = userData.data()!['email'];
    Constants.imageUrl = userData.data()!['image'];
  }

  void logout() async {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    getUserInfo();
    print("Constants.myUserName inside widget tree: ${Constants.myUserName}");
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Destiny Chat',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          bottom: TabBar(
            tabs: [
              Tab(
                child: Text(
                  'Chats',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              Tab(
                child: Text(
                  'Profile',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
            ),
            IconButton(
                onPressed: () {
                  showSearch(
                      context: context,
                      delegate: SearchUser(currentMembers: []));
                },
                icon: Icon(Icons.search)),
            PopupMenuButton(
                itemBuilder: (BuildContext context) => [
                      PopupMenuItem(
                        child: GestureDetector(
                          child: Text('Logout'),
                          onTap: () {
                            logout();
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ]),
          ],
        ),
        body: TabBarView(
          children: [
            ContactsScreen(),
            ProfileScreen(),
          ],
        ),
      ),
    );
  }
}
