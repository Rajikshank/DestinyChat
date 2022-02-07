import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

import '../../widgets/chats/message_bubble.dart';
import '../../helpers/encrytion.dart';

class GroupMessages extends StatelessWidget {
  // updateReadStatus(String messageId) async {
  //   await FirebaseFirestore.instance
  //       .collection('chatroom')
  //       .doc(chatRoomId)
  //       .collection('chats')
  //       .doc(messageId)
  //       .update({
  //     'read': true,
  //   });
  // }

  final String groupId;
  GroupMessages(this.groupId);
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('group')
            .doc(groupId)
            .collection('chats')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (ctx, AsyncSnapshot<QuerySnapshot> chatSnapshot) {
          if (chatSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          final chatDocs = chatSnapshot.data!.docs;
          return ListView.builder(
              itemCount: chatDocs.length,
              reverse: true,
              itemBuilder: (ctx, index) {
                print(
                    "This is what you needed to check cyrus: ${chatDocs[index]}");
                final bool isMe = chatDocs[index]['sender'] == user!.uid;
                // if (!isMe) {
                //   updateReadStatus(chatDocs[index].toString());
                // }

                return FutureBuilder(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(chatDocs[index]['sender'])
                        .get(),
                    builder: (BuildContext context,
                        AsyncSnapshot<DocumentSnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting ||
                          !snapshot.hasData) {
                        return Container();
                      }
                      Map<String, dynamic>? data =
                          snapshot.data!.data() as Map<String, dynamic>?;
                      final username = data!['username'];
                      final imageUrl = data['image'];
                      print("printing group messages imageUrl : $imageUrl");
                      final String message = Encryption.decryptAES(
                          encrypt.Encrypted.fromBase64(
                              chatDocs[index]['message']));
                      return MessageBubble(
                        isMe: isMe,
                        message: message,
                        timestamp: chatDocs[index]['createdAt'],
                        isGroup: true,
                        imageUrl: imageUrl,
                        username: username,
                      );
                    });
              });
        });
  }
}
