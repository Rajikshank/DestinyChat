import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:gvchat/helpers/image_picker.dart';
import 'package:gvchat/helpers/screen_arguements.dart';

import 'package:gvchat/screens/contacts_screen.dart';
import '../widgets/search/search.dart';
import '../screens/chat_screen.dart';

class GroupDetailScreen extends StatefulWidget {
  static const routeName = '/group-detail';
  const GroupDetailScreen({Key? key}) : super(key: key);

  @override
  _GroupDetailScreenState createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final _formKey = GlobalKey<FormState>();
  var _enteredTitle = '';

  getChatRoomId(String a, String b) {
    if (a.compareTo(b) == 1) {
      return "$b\~$a";
    } else {
      return "$a\~$b";
    }
  }

  addParticipant(String groupId, List<dynamic> members) async {
    await showSearch(
        context: context,
        delegate: SearchUser(
            isGroup: true, groupId: groupId, currentMembers: members));
  }

  removeParticipant(String uid, List<dynamic> members, String groupId) async {
    members.remove(uid);
    await FirebaseFirestore.instance.collection('group').doc(groupId).update({
      'members': members,
    });
    setState(() {});
  }

  makeAdmin(String uid, String groupId) async {
    await FirebaseFirestore.instance.collection('group').doc(groupId).update({
      'admin': uid,
    });
    setState(() {});
  }

  updateTitle(String newTitle, String groupId) async {
    _formKey.currentState!.save();
    await FirebaseFirestore.instance.collection('group').doc(groupId).update({
      'title': newTitle,
    });
    setState(() {});
    Navigator.of(context).pop();
  }

  showUpdateUsernameDialog(String title, String groupId) async {
    await showDialog(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        title: Text(
          'Enter group title',
        ),
        content: Form(
          key: _formKey,
          child: TextFormField(
            initialValue: title,
            onSaved: (val) {
              _enteredTitle = val!;
            },
            cursorColor: Theme.of(context).colorScheme.secondary,
            decoration: InputDecoration(
                hintText: 'New title',
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                )),
            onChanged: (value) {
              setState(() {
                _enteredTitle = value;
              });
            },
          ),
        ),
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
              'Save',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onPressed: () {
              updateTitle(_enteredTitle, groupId);
              Navigator.of(ctx).pop();
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

  showDialogAdmin(String uid, String groupId, String username) async {
    await showDialog(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        title: Text(
          'Make admin?',
        ),
        content: Text(
            'Your admin rights will be passed to $username, you\'ll no longer be admin of this group!'),
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
              'Okay',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onPressed: () async {
              await makeAdmin(uid, groupId);
              Navigator.of(context).pop();
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

  showDialogRemove(String uid, List<dynamic> members, String groupId,
      String username) async {
    await showDialog(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        title: Text(
          'Remove $username?',
        ),
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
              'Remove',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onPressed: () async {
              await removeParticipant(uid, members, groupId);
              Navigator.of(ctx).pop();
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

  showDialogLeave(String uid, List<dynamic> members, String groupId) async {
    await showDialog(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        title: Text(
          'Leave group?',
        ),
        content:
            Text('All chats will be lost and you cannot undo this action!'),
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
              'Leave',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onPressed: () async {
              await removeParticipant(uid, members, groupId);
              Navigator.of(context)
                  .pushReplacementNamed(ContactsScreen.routeName);
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
    final groupId = ModalRoute.of(context)!.settings.arguments as String;
    // final groupId = 'X5c2HqyYlKaR4egPk6Hz';
    return FutureBuilder(
        future:
            FirebaseFirestore.instance.collection('group').doc(groupId).get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              !snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          Map<String, dynamic>? data =
              snapshot.data!.data() as Map<String, dynamic>?;
          final String admin = data!['admin'];
          final members = data['members'];
          String imageUrl = data['dp'];
          final String title = data['title'];
          return Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor:
                      Theme.of(context).colorScheme.primary.withOpacity(0.25),
                  forceElevated: true,
                  expandedHeight: 300,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding:
                        EdgeInsetsDirectional.only(start: 20, bottom: 16),
                    centerTitle: false,
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.edit,
                            size: 18,
                          ),
                          onPressed: () async {
                            await showUpdateUsernameDialog(title, groupId);
                          },
                        )
                      ],
                    ),
                    background: GestureDetector(
                      onTap: () async {
                        final url = await PickImage(isGroup: true)
                            .pickImagefromGallery();
                        await FirebaseFirestore.instance
                            .collection('group')
                            .doc(groupId)
                            .update({
                          'dp': url,
                        });
                        setState(() {
                          imageUrl = url;
                        });
                      },
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.transparent,
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: imageUrl.isEmpty
                                      ? AssetImage('assets/images/group.png')
                                      : NetworkImage(imageUrl) as ImageProvider,
                                )),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                              begin: FractionalOffset.topCenter,
                              end: FractionalOffset.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                              stops: [
                                0.6,
                                1.0,
                              ],
                            )),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate([
                    Padding(
                      padding: const EdgeInsets.only(top: 20, left: 20),
                      child: Text(
                        '${members.length} participants',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    if (user!.uid == admin)
                      ListTile(
                        onTap: () {
                          addParticipant(groupId, members);
                        },
                        leading: CircleAvatar(
                          radius: 20,
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          child: Icon(
                            Icons.person_add,
                            color: Colors.white,
                          ),
                        ),
                        title: Text('Add Participant'),
                      ),
                    Divider(),
                    ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: members.length,
                        itemBuilder: (context, index) {
                          return FutureBuilder(
                              future: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(members[index])
                                  .get(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                                if (snapshot.connectionState ==
                                        ConnectionState.waiting ||
                                    !snapshot.hasData) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                }
                                Map<String, dynamic>? data = snapshot.data!
                                    .data() as Map<String, dynamic>?;
                                final username = data!['username'];
                                final imageUrl = data['image'];
                                return Column(
                                  children: [
                                    FocusedMenuHolder(
                                      openWithTap: true,
                                      menuWidth:
                                          MediaQuery.of(context).size.width *
                                              0.4,
                                      menuBoxDecoration: BoxDecoration(
                                        color: Color(0xFF0d0b14),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      onPressed: () {},
                                      menuItems: [
                                        if (members[index] != user!.uid)
                                          FocusedMenuItem(
                                              backgroundColor:
                                                  Color(0xFF0d0b14),
                                              title: Text(
                                                'Message',
                                              ),
                                              onPressed: () {
                                                final chatRoomId =
                                                    getChatRoomId(
                                                        members[index],
                                                        user!.uid);
                                                Navigator.of(context).pushNamed(
                                                    ChatScreen.routeName,
                                                    arguments: ScreenArguments(
                                                        username: username,
                                                        chatRoomId: chatRoomId,
                                                        imageUrl: imageUrl));
                                              }),
                                        if (user!.uid == admin &&
                                            members[index] != user!.uid)
                                          FocusedMenuItem(
                                              backgroundColor:
                                                  Color(0xFF0d0b14),
                                              title: Text(
                                                'Make admin',
                                              ),
                                              onPressed: () {
                                                showDialogAdmin(members[index],
                                                    groupId, username);
                                              }),
                                        if (user!.uid == admin &&
                                            members[index] != user!.uid)
                                          FocusedMenuItem(
                                              backgroundColor:
                                                  Color(0xFF0d0b14),
                                              title: Text(
                                                'Remove',
                                              ),
                                              onPressed: () async {
                                                showDialogRemove(members[index],
                                                    members, groupId, username);
                                              }),
                                      ],
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          radius: 20,
                                          backgroundImage: imageUrl.isEmpty
                                              ? AssetImage(
                                                  'assets/images/person.png',
                                                )
                                              : NetworkImage(
                                                  imageUrl,
                                                ) as ImageProvider,
                                        ),
                                        title: Text(
                                          username,
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Email' + data['email'],
                                              style:
                                                  TextStyle(color: Colors.grey),
                                            ),
                                            Text(
                                                "LastSeen : " +
                                                    data['Timestamp'],
                                                style: TextStyle(
                                                    color: Colors.grey))
                                          ],
                                        ),
                                        trailing: data['uid'] == admin
                                            ? Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 5),
                                                child: Text('Admin'),
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              )
                                            : null,
                                      ),
                                    ),
                                    Divider(),
                                  ],
                                );
                              });
                        }),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      child: TextButton(
                        onPressed: () async {
                          await showDialogLeave(user!.uid, members, groupId);
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Leave Group',
                          style: TextStyle(fontSize: 16),
                        ),
                        style: TextButton.styleFrom(
                          primary: Theme.of(context).errorColor,
                        ),
                      ),
                    )
                  ]),
                ),
              ],
            ),
          );
        });
  }
}
