import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gvchat/helpers/database_methods.dart';
import 'package:gvchat/screens/choose_username_screen.dart';
import 'package:new_version/new_version.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';

import '../widgets/unread_messages.dart';
import './chat_screen.dart';
import '../widgets/app_drawer.dart';
import '../helpers/screen_arguements.dart';
import '../widgets/search/search.dart';
import '../helpers/encrytion.dart';

class ContactsScreen extends StatefulWidget {
  static const routeName = '/contacts';
  const ContactsScreen({Key? key}) : super(key: key);

  @override
  _ContactsScreenState createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  // final _formKey = GlobalKey<FormState>();
  // var _enteredUsername = '';
  final user = FirebaseAuth.instance.currentUser;

  String username = '';
  String imageUrl = '';
  String email = '';
  String uid = '';

  clearUnreadMessages(String chatRoomId) async {
    await FirebaseFirestore.instance
        .collection('chatroom')
        .doc(chatRoomId)
        .update({
      'unreadMessages': 0,
    });
  }

  verifyDetails() async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();
    if (!documentSnapshot.exists) {
      Navigator.of(context).popAndPushNamed(ChooseUsernameScreen.routeName);
    }
  }

  @override
  void initState() {
    //super.initState();
    verifyDetails();
    DatabaseMethods().updateTime();

    final fbm = FirebaseMessaging.instance;
    // FirebaseAuth.instance.signOut();
    fbm.requestPermission();
    FirebaseMessaging.onMessage.listen((message) {
      print(message);
      return;
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print(message);
      return;
    });
    fbm.subscribeToTopic('chat');
  }

  @override
  Widget build(BuildContext context) {
    DatabaseMethods().updateTime();
    return Scaffold(
      drawer: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Color(0xFF0d0b14),
        ),
        child: AppDrawer(),
      ),
      appBar: AppBar(
        backgroundColor:
            Theme.of(context).colorScheme.primary.withOpacity(0.25),
        title: Text(
          'Destiny Chat',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
          ),
          IconButton(
              onPressed: () {
                showSearch(
                    context: context, delegate: SearchUser(currentMembers: []));
              },
              icon: Icon(Icons.search)),
        ],
      ),
      body: SingleChildScrollView(
        physics: ScrollPhysics(),
        child: Column(
          children: [
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("group")
                    .where('members', arrayContains: user!.uid)
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (ctx, AsyncSnapshot<QuerySnapshot> groupSnapshot) {
                  if (groupSnapshot.connectionState ==
                          ConnectionState.waiting ||
                      !groupSnapshot.hasData) {
                    return Container();
                  }
                  final groupDocs = groupSnapshot.data!.docs;
                  return groupDocs.isEmpty
                      ? Container()
                      : Container(
                          padding: EdgeInsets.all(15),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Groups",
                                style: TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Expanded(
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: groupDocs.length,
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (context, index) {
                                      int len = groupDocs[index]['title']
                                          .toString()
                                          .length;
                                      return GestureDetector(
                                        onTap: () {
                                          DatabaseMethods().updateTime();
                                          Navigator.of(context).pushNamed(
                                              ChatScreen.routeName,
                                              arguments: ScreenArguments(
                                                username: groupDocs[index]
                                                        ['title']
                                                    .toString(),
                                                chatRoomId: groupDocs[index]
                                                        ['groupId']
                                                    .toString(),
                                                imageUrl: groupDocs[index]['dp']
                                                    .toString(),
                                                isGroup: true,
                                              ));
                                        },
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Column(
                                              children: [
                                                CircleAvatar(
                                                  radius: 25,
                                                  backgroundImage: groupDocs[
                                                              index]['dp']
                                                          .toString()
                                                          .isEmpty
                                                      ? AssetImage(
                                                          'assets/images/group.png',
                                                        )
                                                      : NetworkImage(
                                                              groupDocs[index]
                                                                      ['dp']
                                                                  .toString())
                                                          as ImageProvider,
                                                ),
                                                SizedBox(
                                                  height: 8,
                                                ),
                                                Text(
                                                  len > 5
                                                      ? "${groupDocs[index]['title'].toString().substring(0, 5)}.."
                                                      : groupDocs[index]
                                                              ['title']
                                                          .toString(),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                              )
                            ],
                          ),
                          height: 140,
                          width: double.infinity,
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.1),
                        );
                }),
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("chatroom")
                    .where('users', arrayContains: user!.uid)
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (ctx, AsyncSnapshot<QuerySnapshot> chatroomSnapshot) {
                  if (chatroomSnapshot.connectionState ==
                          ConnectionState.waiting ||
                      !chatroomSnapshot.hasData) {
                    return Container(
                        height: MediaQuery.of(context).size.height * 8 / 9,
                        width: MediaQuery.of(context).size.width,
                        child: Center(child: CircularProgressIndicator()));
                  }
                  final chatroomDocs = chatroomSnapshot.data!.docs;
                  return chatroomDocs.isEmpty
                      ? Container(
                          height: MediaQuery.of(context).size.height * 8 / 9,
                          width: MediaQuery.of(context).size.width,
                          child: Center(
                            child: Text(
                              'No conversations!',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 18),
                            ),
                          ),
                        )
                      : ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: chatroomDocs.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            final String chatRoomId =
                                chatroomDocs[index]['chatroomId'].toString();
                            final String uid = chatRoomId
                                .toString()
                                .replaceAll('~', '')
                                .replaceAll(user!.uid, '');

                            return FutureBuilder(
                                future: FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(uid)
                                    .get(),
                                builder: (BuildContext context,
                                    AsyncSnapshot<DocumentSnapshot> snapshot) {
                                  if (snapshot.connectionState ==
                                          ConnectionState.waiting ||
                                      !snapshot.hasData) {
                                    return Container();
                                  }
                                  Map<String, dynamic>? data = snapshot.data!
                                      .data() as Map<String, dynamic>?;
                                  final username = data!['username'] ?? '';
                                  final imageUrl = data['image'] ?? '';
                                  if (chatroomDocs[index]['latestMessage']
                                      .toString()
                                      .isEmpty) {
                                    return Container();
                                  }
                                  final userId = user!.uid.toString();
                                  int unreadMessages =
                                      chatroomDocs[index]['unreadMessages'];
                                  final String latestMessage =
                                      Encryption.decryptAES(
                                          encrypt.Encrypted.fromBase64(
                                              chatroomDocs[index]
                                                  ['latestMessage']));
                                  int l = latestMessage.length;
                                  final String sender = l > 0
                                      ? chatroomDocs[index]['lastMessageBy']
                                      : '';
                                  return Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ListTile(
                                          onTap: () {
                                            DatabaseMethods().updateTime();
                                            if (userId != sender) {
                                              clearUnreadMessages(chatRoomId);
                                            }
                                            Navigator.of(context).pushNamed(
                                                ChatScreen.routeName,
                                                arguments: ScreenArguments(
                                                    username: username,
                                                    chatRoomId: chatRoomId,
                                                    imageUrl: imageUrl));
                                          },
                                          leading: CircleAvatar(
                                            radius: 25,
                                            backgroundImage: imageUrl.isEmpty
                                                ? AssetImage(
                                                    'assets/images/person.png',
                                                  )
                                                : NetworkImage(
                                                    imageUrl,
                                                  ) as ImageProvider,
                                          ),
                                          trailing: userId != sender
                                              ? UnreadMessages(
                                                  sender,
                                                  unreadMessages,
                                                  chatroomDocs[index]
                                                      ['timestamp'])
                                              : null,
                                          title: Text(
                                            username,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          subtitle: user!.uid == sender &&
                                                  l > 40
                                              ? Text(
                                                  "You: ${latestMessage.substring(0, 40)}...",
                                                  style: TextStyle(
                                                      color: Colors.grey),
                                                )
                                              : (user!.uid == sender && l <= 40
                                                  ? Text(
                                                      "You: $latestMessage",
                                                      style: TextStyle(
                                                          color: Colors.grey),
                                                    )
                                                  : (user!.uid != sender &&
                                                          l <= 40
                                                      ? Text(
                                                          "$latestMessage",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.grey),
                                                        )
                                                      : Text(
                                                          "${latestMessage.substring(0, 40)}...",
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .grey)))),
                                        ),
                                        Divider(),
                                      ],
                                    ),
                                  );
                                });
                          });
                }),
          ],
        ),
      ),
    );
  }
}
