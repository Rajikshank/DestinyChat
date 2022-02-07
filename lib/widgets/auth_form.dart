import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class AuthForm extends StatefulWidget {
  final bool isLogin;
  final void Function(String message) showErrorDialog;
  AuthForm(this.isLogin, this.showErrorDialog);

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  bool _obscureText = true;
  final _formKey = GlobalKey<FormState>();
  var _userEmail = '';
  var _userPassword = '';
  var _username = '';
  final _auth = FirebaseAuth.instance;
  var _isLoading = false;

  Future<bool> usernameCheck() async {
    final result = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: _username)
        .get();
    return result.docs.isEmpty;
  }

  void _submitForm() async {
    try {
      setState(() {
        _isLoading = true;
      });
      // final prefs = await SharedPreferences.getInstance();
      UserCredential result;
      if (widget.isLogin) {
        result = await _auth.signInWithEmailAndPassword(
            email: _userEmail, password: _userPassword);
        print(result);
        final usernameInstance = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: _userEmail)
            .get();
        _username = usernameInstance.docs[0].data()['username'];
      } else {
        result = await _auth.createUserWithEmailAndPassword(
            email: _userEmail, password: _userPassword);
        print(result);
        final searchKeywords = [];
        _username = _username.toLowerCase();
        for (int i = 0; i < _username.length; i++) {
          searchKeywords.add(_username.substring(0, i + 1));
        }
        await FirebaseFirestore.instance
            .collection('users')
            .doc(result.user!.uid)
            .set({
          'uid': result.user!.uid,
          'username': _username.toLowerCase(),
          'email': _userEmail,
          'image': '',
          'searchKeywords': searchKeywords,
        });
      }
      // await prefs.setString('username', _username);
      // await prefs.setString('email', _userEmail);
    } on FirebaseAuthException catch (error) {
      var message = 'An error occured, please check your credentials!';
      if (error.message != null) {
        message = error.message!;
      }
      widget.showErrorDialog(message);
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      widget.showErrorDialog('Error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _trySubmit() async {
    var isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (isValid) {
      _formKey.currentState!.save();
      isValid = await usernameCheck();
      if (!isValid) {
        widget.showErrorDialog('Username already exists');
      } else {
        _submitForm();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              key: ValueKey('email'),
              validator: (value) {
                if (value!.isEmpty || !value.contains('@')) {
                  return 'Oops! That\' not a valid email';
                }
                return null;
              },
              onSaved: (value) {
                _userEmail = value!;
              },
              decoration: InputDecoration(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                prefixIcon: Icon(
                  Icons.email,
                  color: Theme.of(context).colorScheme.primary,
                ),
                disabledBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                hintText: 'Email address',
                hintStyle:
                    TextStyle(color: Theme.of(context).colorScheme.primary),
                fillColor:
                    Theme.of(context).colorScheme.primary.withOpacity(0.2),
                filled: true,
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                focusedBorder: InputBorder.none,
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(
              height: 15,
            ),
            if (!widget.isLogin)
              TextFormField(
                key: ValueKey('username'),
                validator: (value) {
                  if (value!.isEmpty || value.length < 4) {
                    return 'Username must be atleast 4 characters long';
                  }
                  if (value.length > 15) {
                    return 'Username must be atmost 15 characters long';
                  }
                  return null;
                },
                onSaved: (value) {
                  _username = value!;
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20)),
                  enabledBorder: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.person,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  hintText: 'Username',
                  hintStyle:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                  fillColor:
                      Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  filled: true,
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  focusedBorder: InputBorder.none,
                ),
              ),
            if (!widget.isLogin)
              SizedBox(
                height: 15,
              ),
            TextFormField(
              key: ValueKey('password'),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Enter password';
                }
                if (!widget.isLogin) {
                  if (value.length < 8) {
                    return 'Password must be atleast 8 characters long';
                  }
                }
                return null;
              },
              onSaved: (value) {
                _userPassword = value!;
              },
              obscureText: _obscureText,
              decoration: InputDecoration(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                enabledBorder: InputBorder.none,
                prefixIcon: Icon(
                  Icons.lock,
                  color: Theme.of(context).colorScheme.primary,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility),
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: _toggle,
                ),
                hintText: 'Password',
                hintStyle:
                    TextStyle(color: Theme.of(context).colorScheme.primary),
                fillColor:
                    Theme.of(context).colorScheme.primary.withOpacity(0.2),
                filled: true,
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                focusedBorder: InputBorder.none,
              ),
            ),
            SizedBox(
              height: 25,
            ),
            if (_isLoading) CircularProgressIndicator(),
            if (!_isLoading)
              ElevatedButton(
                onPressed: _trySubmit,
                child: Text(
                  widget.isLogin ? 'Login' : 'Sign Up',
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                    minimumSize: Size(90, 42),
                    primary: Colors.pink,
                    elevation: 7,
                    shadowColor: Theme.of(context).colorScheme.secondary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(70.0)),
                    onPrimary: Colors.white,
                    textStyle: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    )),
              )
          ],
        ),
      ),
    );
  }
}
