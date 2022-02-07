import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gvchat/helpers/database_methods.dart';

import 'package:gvchat/helpers/screen_arguements.dart';
import 'package:gvchat/screens/new_public.dart';
import 'package:gvchat/screens/public_chat_screen.dart';

class publicChat extends StatefulWidget {
  static const route = '/screens';

  @override
  _publicChatState createState() => _publicChatState();
}

class _publicChatState extends State<publicChat> {
  get mainAxisSize => null;
  final user = FirebaseAuth.instance.currentUser;
  addmemeber(dynamic groupDocs, int index) {
    final List<dynamic> members = groupDocs[index]['members'];
    if (!members.contains(FirebaseAuth.instance.currentUser!.uid)) {
      members.add(FirebaseAuth.instance.currentUser!.uid.toString());
      print('members added');
    }

    FirebaseFirestore.instance
        .collection("public")
        .doc(groupDocs[index]['Docid'].toString())
        .update({'members': members});
  }

  showAlertDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        title: Text(
          'New Public Channel',
        ),
        content: Text('Do You Want To Create A New Public Channel?'),
        actions: <Widget>[
          TextButton(
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
          ElevatedButton(
            child: Text(
              'Create',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).push(new MaterialPageRoute(
                  builder: (context) => NewPublicScreen()));
            },
            style: ElevatedButton.styleFrom(
              elevation: 0,
              primary: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Public Chat Rooms"),
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection("public").snapshots(),
          builder: (ctx, AsyncSnapshot<QuerySnapshot> groupSnapshot) {
            if (groupSnapshot.connectionState == ConnectionState.waiting ||
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
                          "Available Public chat channels",
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
                              scrollDirection: Axis.vertical,
                              itemBuilder: (context, index) {
                                int len =
                                    groupDocs[index]['Id'].toString().length;
                                List<dynamic> blocked =
                                    groupDocs[index]['blocked'];

                                return !blocked.contains(user!.uid)
                                    ? GestureDetector(
                                        onTap: () {
                                          addmemeber(groupDocs, index);
                                          DatabaseMethods().updateTime();
                                          print(groupDocs[index]['Docid']);
                                          Navigator.of(context).pushNamed(
                                              public_screen.routeName,
                                              arguments: ScreenArguments(
                                                username: groupDocs[index]['Id']
                                                    .toString(),
                                                chatRoomId: groupDocs[index]
                                                        ['Docid']
                                                    .toString(),
                                                imageUrl: groupDocs[index]['dp']
                                                    .toString(),
                                                isGroup: true,
                                              ));
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              ListTile(
                                                leading: CircleAvatar(
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
                                                title: Text(
                                                    groupDocs[index]['Id']
                                                        .toString(),
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white)),
                                                subtitle: Text(
                                                    groupDocs[index]
                                                            ['latestMessage']
                                                        .toString(),
                                                    style: TextStyle(
                                                        color: Colors.grey)),
                                              ),
                                              Divider(),
                                            ],
                                          ),
                                        ),
                                      )
                                    : SizedBox();
                              }),
                        ),
                      ],
                    ),
                  );
          }),
      floatingActionButton: IconButton(
          iconSize: 42,
          onPressed: () {
            print('create public');
            showAlertDialog(context);
          },
          icon: Icon(Icons.add_circle_outline_outlined)),
    );
  }
}
