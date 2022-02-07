import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../widgets/chats/message_bubble.dart';
import '../../helpers/encrytion.dart';

class Messages extends StatelessWidget {
  final String chatRoomId;
  final String imageUrl;
  Messages(this.chatRoomId, this.imageUrl);
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chatroom')
            .doc(chatRoomId)
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
                // final text = chatDocs[index]['message'] as encrypt.Encrypted;
                final String message = Encryption.decryptAES(
                    encrypt.Encrypted.fromBase64(chatDocs[index]['message']));

                return MessageBubble(
                  isMe: isMe,
                  message: message,
                  timestamp: chatDocs[index]['createdAt'],
                  isGroup: false,
                  imageUrl: imageUrl,
                );
              });
        });
  }
}
