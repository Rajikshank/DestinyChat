import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gvchat/helpers/database_methods.dart';
import 'package:gvchat/helpers/image_picker.dart';
import 'package:gvchat/helpers/screen_arguements.dart';
import 'package:gvchat/screens/chat_screen.dart';

class NewPublicScreen extends StatefulWidget {
  static const routeName = '/new-public';

  @override
  _NewPublicScreenState createState() => _NewPublicScreenState();
}

class _NewPublicScreenState extends State<NewPublicScreen> {
  final user = FirebaseAuth.instance.currentUser;

  final _formKey = GlobalKey<FormState>();
  var _enteredText = '';
  String imageUrl = '';

  createNewGroup() async {
    print("Printing _enteredText: $_enteredText");

    final groupId =
        await DatabaseMethods().createPublicGroup(_enteredText, imageUrl);
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
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        floatingActionButtonLocation: null,
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
            'New Public Group',
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
                                  // ignore: unnecessary_null_comparison

                                  return null;
                                },
                                onSaved: (val) {
                                  _enteredText = val!;
                                },
                                maxLength: 15,
                                decoration: InputDecoration(
                                  hintText: 'Type Public group title here...',
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
            ],
          ),
        ),
      ),
    );
  }
}
