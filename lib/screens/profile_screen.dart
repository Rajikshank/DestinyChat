import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../helpers/screen_arguements.dart';
import '../helpers/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profile';
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  var _enteredUsername = '';
  var isLoading = false;
  String username = '';
  String imageUrl = '';
  bool isInit = true;

  _showErrorDialog(String message) async {
    await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              title: Text('Failed!'),
              content: Text(message),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    'Okay',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                )
              ],
            ));
  }

  Future<bool> usernameCheck() async {
    final result = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: _enteredUsername)
        .get();
    return result.docs.isEmpty;
  }

  updateUsername(String newUsername) async {
    _formKey.currentState!.save();
    final isValid = await usernameCheck();
    if (!isValid) {
      await _showErrorDialog('Username already exists!');
    } else {
      setState(() {
        isLoading = true;
      });
      setState(() {
        username = newUsername;
      });
      final searchKeywords = [];
      for (int i = 0; i < newUsername.length; i++) {
        searchKeywords.add(newUsername.substring(0, i + 1));
      }
      final user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({
        'username': newUsername,
        'searchKeywords': searchKeywords,
      });
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pop();
    }
  }

  showUpdateUsernameDialog() async {
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        title: Text(
          'Enter your username',
        ),
        content: Form(
          key: _formKey,
          child: TextFormField(
            maxLength: 15,
            initialValue: username,
            onSaved: (val) {
              _enteredUsername = val!;
            },
            cursorColor: Theme.of(context).colorScheme.secondary,
            decoration: InputDecoration(
                hintText: 'New username',
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                )),
            onChanged: (value) {
              setState(() {
                _enteredUsername = value;
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
              updateUsername(_enteredUsername);
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

  showOptionsForImageUpload() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Text(
                'Choose Photo',
                style: TextStyle(fontSize: 20),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    setState(() {
                      imageUrl = 'loading';
                    });
                    final String url = await PickImage().pickImagefromCamera();
                    setState(() {
                      imageUrl = url;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.photo_camera,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        Text(
                          'Camera',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    primary: Colors.transparent,
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    setState(() {
                      imageUrl = 'loading';
                    });
                    final String url = await PickImage().pickImagefromGallery();
                    setState(() {
                      imageUrl = url;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.image,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        Text(
                          'Gallery',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    primary: Colors.transparent,
                  ),
                ),
                if (imageUrl.isNotEmpty)
                  ElevatedButton(
                    onPressed: () {
                      PickImage().removeImage();
                      setState(() {
                        imageUrl = '';
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.delete,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          Text(
                            'Remove',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      primary: Colors.transparent,
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as ScreenArguments;
    if (isInit) {
      username = args.username;
      imageUrl = args.imageUrl;
      isInit = false;
    }

    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            Theme.of(context).colorScheme.primary.withOpacity(0.25),
        title: Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              children: [
                SizedBox(
                  height: 30,
                ),
                GestureDetector(
                  child: Stack(
                    alignment: AlignmentDirectional.center,
                    children: [
                      CircleAvatar(
                        radius: width / 7,
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.5),
                        child: imageUrl == 'loading'
                            ? Text('Loading...',
                                style: TextStyle(
                                  color: Colors.white,
                                ))
                            : null,
                        backgroundImage: imageUrl.isEmpty
                            ? AssetImage(
                                'assets/images/person.png',
                              )
                            : imageUrl == 'loading'
                                ? null
                                : NetworkImage(
                                    imageUrl,
                                  ) as ImageProvider,
                      ),
                      if (imageUrl.isEmpty)
                        CircleAvatar(
                          radius: width / 7,
                          backgroundColor: Color(0xFF0d0b14).withOpacity(0.6),
                        ),
                      if (imageUrl.isEmpty)
                        Center(
                            child: Icon(
                          Icons.edit,
                          size: 35,
                          color: Colors.white70,
                        )),
                    ],
                  ),
                  onTap: showOptionsForImageUpload,
                ),
                SizedBox(
                  height: 30,
                ),
                ListTile(
                  leading: Icon(
                    Icons.person,
                    color: Colors.grey,
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: Icon(
                      Icons.edit,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      showUpdateUsernameDialog();
                    },
                  ),
                  onTap: () {
                    showUpdateUsernameDialog();
                  },
                  title: Text(
                    'Username',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                    ),
                  ),
                  selectedTileColor: Colors.white,
                  subtitle: Text(
                    username,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 20,
                    ),
                  ),
                  horizontalTitleGap: 10,
                ),
                ListTile(
                  leading: Icon(
                    Icons.mail,
                    color: Colors.grey,
                  ),
                  isThreeLine: true,
                  title: Text(
                    'Email',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                    ),
                  ),
                  selectedTileColor: Colors.white,
                  subtitle: Text(
                    args.email,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 20,
                    ),
                  ),
                  horizontalTitleGap: 10,
                ),
              ],
            ),
            if (isLoading)
              Center(
                child: CircularProgressIndicator(
                  value: 100,
                ),
              )
          ],
        ),
      ),
    );
  }
}
