import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:gvchat/helpers/image_picker.dart';
import 'package:gvchat/helpers/screen_arguements.dart';

import 'package:gvchat/screens/contacts_screen.dart';
import 'package:gvchat/screens/public_chat.dart';
import '../widgets/search/search.dart';
import '../screens/chat_screen.dart';

class Public_details extends StatefulWidget {
  static const routeName = '/public_detail';
  const Public_details({Key? key}) : super(key: key);

  @override
  _Public_detailsState createState() => _Public_detailsState();
}

class _Public_detailsState extends State<Public_details> {
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

  updateTitle(String newTitle, String groupId) async {
    _formKey.currentState!.save();
    await FirebaseFirestore.instance.collection('public').doc(groupId).update({
      'Id': newTitle,
    });
    setState(() {});
    Navigator.of(context).pop();
  }

  removegrp(List<dynamic> blocked, List<dynamic> members, String docId) async {
    blocked.add(user!.uid);
    members.remove(user!.uid);
    await FirebaseFirestore.instance
        .collection('public')
        .doc(docId)
        .update({'blocked': blocked, 'members': members});
    setState(() {});
    int count = 0;
    Navigator.of(context).popUntil((_) => count++ >= 2);
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

  @override
  Widget build(BuildContext context) {
    final groupId = ModalRoute.of(context)!.settings.arguments as String;
    // final groupId = 'X5c2HqyYlKaR4egPk6Hz';
    return FutureBuilder(
        future:
            FirebaseFirestore.instance.collection('public').doc(groupId).get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              !snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          Map<String, dynamic>? data =
              snapshot.data!.data() as Map<String, dynamic>?;
          final String admin = data!['Id'];
          final members = data['members'];
          final blocked = data['blocked'];
          String imageUrl = data['dp'];
          final String title = data['Id'];
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
                            .collection('public')
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
                        onTap: () {},
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
                          removegrp(blocked, members, data['Docid']);
                        },
                        child: Text(
                          'Leave and Block This Group',
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
