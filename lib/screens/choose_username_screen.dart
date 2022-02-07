import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:gvchat/screens/contacts_screen.dart';

class ChooseUsernameScreen extends StatefulWidget {
  static const routeName = '/username';

  @override
  _ChooseUsernameScreenState createState() => _ChooseUsernameScreenState();
}

class _ChooseUsernameScreenState extends State<ChooseUsernameScreen> {
  final _formKey = GlobalKey<FormState>();
  final user = FirebaseAuth.instance.currentUser;
  var _username = '';
  var _isLoading = false;

  _submitForm() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final searchKeywords = [];
      for (int i = 0; i < _username.length; i++) {
        searchKeywords.add(_username.substring(0, i + 1));
      }
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
        'uid': user!.uid,
        'username': _username.toLowerCase(),
        'email': user!.email,
        'image': user!.photoURL,
        'searchKeywords': searchKeywords,
      });
      Navigator.of(context).popAndPushNamed(ContactsScreen.routeName);
    } catch (error) {
      _showErrorDialog('Error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> usernameCheck() async {
    final result = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: _username)
        .get();
    return result.docs.isEmpty;
  }

  _showErrorDialog(String message) async {
    await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              title: Text('Error signing up!'),
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

  _trySubmit() async {
    var isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (isValid) {
      _formKey.currentState!.save();
      isValid = await usernameCheck();
      if (!isValid) {
        await _showErrorDialog('Username already exists');
      } else {
        await _submitForm();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.all(30.0),
          child: LayoutBuilder(
            builder: (ctx, viewportConstraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: viewportConstraints.maxHeight,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Choose\nUsername',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: 40,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'and get started!',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 40,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 45,
                        ),
                        Center(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  maxLength: 15,
                                  key: ValueKey('username'),
                                  validator: (value) {
                                    if (value!.isEmpty || value.length < 4) {
                                      return 'Username must be atleast 4 characters long';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    _username = value!;
                                  },
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    enabledBorder: InputBorder.none,
                                    prefixIcon: Icon(
                                      Icons.person,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                    hintText: 'Username',
                                    hintStyle: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary),
                                    fillColor: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.2),
                                    filled: true,
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.auto,
                                    focusedBorder: InputBorder.none,
                                  ),
                                ),
                                SizedBox(
                                  height: 25,
                                ),
                                if (_isLoading) CircularProgressIndicator(),
                                if (!_isLoading)
                                  ElevatedButton(
                                    onPressed: () async {
                                      await _trySubmit();
                                    },
                                    child: Text(
                                      'Submit',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                        minimumSize: Size(90, 42),
                                        primary: Colors.pink,
                                        elevation: 7,
                                        shadowColor: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(70.0)),
                                        onPrimary: Colors.white,
                                        textStyle: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        )),
                                  )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
