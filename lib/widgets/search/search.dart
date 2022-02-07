import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gvchat/screens/new_group_screen.dart';
import '../../screens/chat_screen.dart';

import 'package:gvchat/helpers/database_methods.dart';
import '../../helpers/screen_arguements.dart';

class SearchUser extends SearchDelegate<String> {
  final String groupId;
  final bool isGroup;
  List<dynamic> currentMembers;
  SearchUser(
      {this.isGroup = false, this.groupId = '', required this.currentMembers});
  final user = FirebaseAuth.instance.currentUser;
  List<dynamic> groupMembers = [];

  startConversation(String uid) {
    final String myUid = user!.uid;
    final chatRoomId = getChatRoomId(uid, myUid);
    List<String> users = [
      uid,
      myUid,
    ];
    DatabaseMethods().createChatRoom(chatRoomId, users);
    return chatRoomId;
  }

  addParticipant(BuildContext context) async {
    print("printing updated group members: $groupMembers");
    await FirebaseFirestore.instance.collection('group').doc(groupId).update({
      'members': groupMembers,
    });
    Navigator.of(context).pop();
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    return super.appBarTheme(context).copyWith(
        backgroundColor:
            Theme.of(context).colorScheme.primary.withOpacity(0.25),
        appBarTheme: AppBarTheme(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.25),
        ));
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, ''),
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // ignore: todo
    // TODO: implement buildResults
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    groupMembers = groupMembers + currentMembers;
    currentMembers = [];
    print("printing group members before: $groupMembers");
    print("printing groupId before: $groupId");
    return Scaffold(
      floatingActionButton: isGroup && groupMembers.isNotEmpty
          ? FloatingActionButton(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Icon(
                Icons.arrow_forward,
                color: Colors.white,
              ),
              onPressed: () {
                groupId.isEmpty
                    ? Navigator.of(context).popAndPushNamed(
                        NewGroupScreen.routeName,
                        arguments: groupMembers)
                    : addParticipant(context);
              },
            )
          : null,
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where("searchKeywords", arrayContains: query)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          return (snapshot.connectionState == ConnectionState.waiting)
              ? Center(child: CircularProgressIndicator())
              : snapshot.data!.docs.isEmpty
                  ? (query.isEmpty
                      ? Center(
                          child: Text(
                            'Search user by their username!',
                            style: TextStyle(color: Colors.grey, fontSize: 18),
                          ),
                        )
                      : Center(
                          child: Text(
                            'No results found!',
                            style: TextStyle(color: Colors.grey, fontSize: 18),
                          ),
                        ))
                  : Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        children: [
                          if (isGroup)
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Center(
                                  child: Text(
                                "Swipe to add participants",
                                style: TextStyle(
                                    fontSize: 18,
                                    color:
                                        Theme.of(context).colorScheme.primary),
                              )),
                            ),
                          Expanded(
                            child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: snapshot.data!.docs.length,
                                itemBuilder: (context, index) {
                                  DocumentSnapshot data =
                                      snapshot.data!.docs[index];
                                  return user!.uid != data['uid'] &&
                                          !groupMembers.contains(data['uid'])
                                      ? Dismissible(
                                          key: ValueKey(data['uid']),
                                          onDismissed: (_) {
                                            groupMembers.add(data['uid']);
                                          },
                                          direction: isGroup
                                              ? DismissDirection.horizontal
                                              : DismissDirection.none,
                                          background: Container(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            child: Text(
                                              'Add participant',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18),
                                            ),
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.only(right: 20),
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 15, vertical: 4),
                                          ),
                                          child: Column(
                                            children: [
                                              ListTile(
                                                onTap: isGroup
                                                    ? null
                                                    : () {
                                                        final chatRoomId =
                                                            startConversation(
                                                          data['uid'],
                                                        );
                                                        Navigator.of(context).popAndPushNamed(
                                                            ChatScreen
                                                                .routeName,
                                                            arguments: ScreenArguments(
                                                                username: data[
                                                                    'username'],
                                                                chatRoomId:
                                                                    chatRoomId,
                                                                imageUrl: data[
                                                                    'image']));
                                                      },
                                                leading: CircleAvatar(
                                                  radius: 20,
                                                  backgroundImage:
                                                      data['image'].isEmpty
                                                          ? AssetImage(
                                                              'assets/images/person.png',
                                                            )
                                                          : NetworkImage(
                                                              data['image'],
                                                            ) as ImageProvider,
                                                ),
                                                title: Text(
                                                  data['username'],
                                                ),
                                              ),
                                              Divider(),
                                            ],
                                          ),
                                        )
                                      : Container();
                                }),
                          ),
                        ],
                      ),
                    );
        },
      ),
    );
  }
}

getChatRoomId(String a, String b) {
  if (a.compareTo(b) == 1) {
    return "$b\~$a";
  } else {
    return "$a\~$b";
  }
}
