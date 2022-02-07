import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class DatabaseMethods {
  createChatRoom(String chatRoomId, List<String> users) async {
    await FirebaseFirestore.instance
        .collection('chatroom')
        .doc(chatRoomId)
        .set({
      'chatroomId': chatRoomId,
      'users': users,
      'unreadMessages': 0,
      'latestMessage': '',
      'timestamp': Timestamp.now(),
    });
  }

  createGroup(
      String userId, List<dynamic> users, String title, String imageUrl) async {
    return await FirebaseFirestore.instance.collection('group').add({
      'dp': imageUrl,
      'groupId': '',
      'title': title,
      'members': users,
      'admin': userId,
      'unreadMessages': 0,
      'latestMessage': '',
      'timestamp': Timestamp.now(),
    }).then((value) async {
      await FirebaseFirestore.instance
          .collection('group')
          .doc(value.id)
          .update({
        'groupId': value.id,
      });
      return value.id;
    });
  }

  createPublicGroup(String title, String imageUrl) async {
    final user = FirebaseAuth.instance.currentUser;
    List<dynamic> users = new List.from({user!.uid});
    List<dynamic> blocked = new List.empty();

    return await FirebaseFirestore.instance.collection('public').add({
      'dp': imageUrl,
      'Id': title,
      'members': users,
      'unreadMessages': 0,
      'latestMessage': '',
      'timestamp': Timestamp.now(),
      'blocked': blocked
    }).then((value) async {
      await FirebaseFirestore.instance
          .collection('public')
          .doc(value.id)
          .update({
        'Docid': value.id,
      });
      return value.id;
    });
  }

  updateTime() async {
    final user = FirebaseAuth.instance.currentUser;
    var now = new DateTime.now();
    var formatter = new DateFormat('dd-MM-yyyy');
    String formattedTime = DateFormat('kk:mm:a').format(now);
    String formattedDate = formatter.format(now);

    return {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({'Timestamp': formattedTime + "   " + formattedDate})
    };
  }
}
