import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gvchat/helpers/database_methods.dart';
import 'package:gvchat/helpers/image_picker.dart';
import 'package:gvchat/helpers/screen_arguements.dart';
import 'package:gvchat/screens/chat_screen.dart';

class NewGroupScreen extends StatefulWidget {
  static const routeName = '/new-group';

  @override
  _NewGroupScreenState createState() => _NewGroupScreenState();
}

class _NewGroupScreenState extends State<NewGroupScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final _formKey = GlobalKey<FormState>();
  var _enteredText = '';
  String imageUrl = '';
  late List<dynamic> participants;

  createNewGroup() async {
    print("Printing _enteredText: $_enteredText");
    participants.add(user!.uid);
    final groupId = await DatabaseMethods()
        .createGroup(user!.uid, participants, _enteredText, imageUrl);
    Navigator.of(context).popAndPushNamed(ChatScreen.routeName,
        arguments: ScreenArguments(
          username: _enteredText,
          chatRoomId: groupId,
          imageUrl: imageUrl,
          isGroup: true,
        ));
  }

  tryCreateGroup() {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (isValid) {
      _formKey.currentState!.save();
      createNewGroup();
    }
  }

  @override
  Widget build(BuildContext context) {
    participants = ModalRoute.of(context)!.settings.arguments as List<dynamic>;
    return SafeArea(
      child: Scaffold(
        floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
        floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Icon(
            Icons.check,
            size: 30,
          ),
          onPressed: tryCreateGroup,
        ),
        appBar: AppBar(
          backgroundColor:
              Theme.of(context).colorScheme.primary.withOpacity(0.25),
          title: Text(
            'New group',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 155,
                padding: EdgeInsets.all(20),
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Add a group title and optional group icon",
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 18,
                    ),
                    Container(
                      // margin: EdgeInsets.all(15),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              final url = await PickImage(isGroup: true)
                                  .pickImagefromGallery();
                              setState(() {
                                imageUrl = url;
                              });
                            },
                            child: CircleAvatar(
                              backgroundImage: imageUrl.isEmpty
                                  ? AssetImage('assets/images/group.png')
                                  : NetworkImage(imageUrl) as ImageProvider,
                              radius: 20,
                            ),
                          ),
                          SizedBox(
                            width: 16,
                          ),
                          Expanded(
                            child: Form(
                              key: _formKey,
                              child: TextFormField(
                                validator: (value) {
                                  if (value!.trim().isEmpty) {
                                    return 'Add a title!';
                                  }
                                  if (participants.isEmpty) {
                                    return 'No members added!';
                                  }
                                  return null;
                                },
                                onSaved: (val) {
                                  _enteredText = val!;
                                },
                                maxLength: 15,
                                decoration: InputDecoration(
                                  hintText: 'Type group title here...',
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 18, bottom: 8, left: 18),
                child: Text(
                  'Participants: ${participants.length}',
                  style: TextStyle(
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: participants.length,
                itemBuilder: (context, index) {
                  return FutureBuilder(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(participants[index])
                          .get(),
                      builder: (BuildContext context,
                          AsyncSnapshot<DocumentSnapshot> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: LinearProgressIndicator());
                        }
                        Map<String, dynamic>? data =
                            snapshot.data!.data() as Map<String, dynamic>?;
                        final username = data!['username'];
                        final imageUrl = data['image'];
                        return Padding(
                          padding: const EdgeInsets.all(10.0),
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
                            trailing: IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () {
                                setState(() {
                                  participants.remove(participants[index]);
                                });
                              },
                            ),
                            title: Text(
                              username,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
