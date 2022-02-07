import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

import '../../helpers/encrytion.dart';

class NewMessage extends StatefulWidget {
  final String chatRoomId;
  final bool isGroup;
  NewMessage(this.chatRoomId, this.isGroup);

  @override
  _NewMessageState createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _controller = new TextEditingController();
  var _enteredMessage = '';

  void _sendMessage() async {
    FocusScope.of(context).unfocus();
    final user = FirebaseAuth.instance.currentUser;
    // final user = await FirebaseAuth.instance.currentUser();
    // final userData =
    //     await Firestore.instance.collection('users').document(user.uid).get();
    var message = Encryption.encryptAES(_enteredMessage);
    print("printing encrypted message here: $message");
    print("printing encrypted message base64 here: ${message.base64}");
    message = message is encrypt.Encrypted ? message.base64 : message;
    if (!widget.isGroup) {
      await FirebaseFirestore.instance
          .collection('chatroom')
          .doc(widget.chatRoomId)
          .collection('chats')
          .add({
        'message': message,
        'sender': user!.uid,
        'createdAt': Timestamp.now(),
        // 'read': false,
      });
      _controller.clear();
      await FirebaseFirestore.instance
          .collection('chatroom')
          .doc(widget.chatRoomId)
          .update({
        'lastMessageBy': user.uid,
        'latestMessage': message,
        'timestamp': Timestamp.now(),
        'unreadMessages': FieldValue.increment(1),
      });
    } else {
      await FirebaseFirestore.instance
          .collection('group')
          .doc(widget.chatRoomId)
          .collection('chats')
          .add({
        'message': message,
        'sender': user!.uid,
        'createdAt': Timestamp.now(),
        // 'read': false,
      });
      _controller.clear();
      await FirebaseFirestore.instance
          .collection('group')
          .doc(widget.chatRoomId)
          .update({
        'lastMessageBy': user.uid,
        'latestMessage': message,
        'timestamp': Timestamp.now(),
        'unreadMessages': FieldValue.increment(1),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: (value) {
                setState(() {
                  _enteredMessage = value;
                });
              },
              minLines: 1,
              maxLines: 5,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: Icon(Icons.send_rounded),
                  onPressed:
                      _enteredMessage.trim().isEmpty ? null : _sendMessage,
                ),
                isDense: true,
                contentPadding: EdgeInsets.only(left: 20),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(40)),
                    borderSide: BorderSide(
                      width: 0,
                      style: BorderStyle.none,
                    )),
                filled: true,
                hintStyle:
                    TextStyle(color: Theme.of(context).colorScheme.primary),
                fillColor:
                    Theme.of(context).colorScheme.primary.withOpacity(0.2),
                hintText: 'Send a message',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
