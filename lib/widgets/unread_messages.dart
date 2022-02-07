import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UnreadMessages extends StatelessWidget {
  final String uid;
  final int unreadMessages;
  final Timestamp timestamp;
  UnreadMessages(this.uid, this.unreadMessages, this.timestamp);
  final user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return unreadMessages == 0
        ? Container(
            width: 0,
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                "${timestamp.toDate().hour}:${timestamp.toDate().minute}",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              CircleAvatar(
                radius: 12,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  '$unreadMessages',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          );
  }
}
