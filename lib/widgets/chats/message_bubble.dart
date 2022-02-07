import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final bool isGroup;
  final String imageUrl;
  final String username;
  final Timestamp timestamp;

  MessageBubble({
    required this.isMe,
    required this.message,
    required this.isGroup,
    required this.imageUrl,
    required this.timestamp,
    this.username = '',
  });

  @override
  Widget build(BuildContext context) {
    print("printing group messages imageUrl inside message bubble : $imageUrl");
    return Container(
      constraints: BoxConstraints(
        maxWidth: 3 * MediaQuery.of(context).size.width / 4,
      ),
      padding: EdgeInsets.only(
        left: isMe ? 0 : 16,
        right: isMe ? 16 : 0,
      ),
      margin: EdgeInsets.symmetric(vertical: 4),
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (!isMe)
            CircleAvatar(
              radius: 15,
              backgroundImage: imageUrl.isEmpty
                  ? AssetImage(
                      'assets/images/person.png',
                    )
                  : NetworkImage(
                      imageUrl,
                    ) as ImageProvider,
            ),
          if (!isMe)
            SizedBox(
              width: 10,
            ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isGroup && !isMe)
                Text(
                  "$username, ${timestamp.toDate().hour}:${timestamp.toDate().minute}",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              SizedBox(
                height: 4,
              ),
              Container(
                constraints: BoxConstraints(
                  maxWidth: 3 * MediaQuery.of(context).size.width / 4,
                ),
                padding: EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: isMe
                      ? Theme.of(context).colorScheme.primary
                      : Color(0x1AFFFFFF),
                  borderRadius: BorderRadius.only(
                    topLeft: isMe ? Radius.circular(12) : Radius.circular(0),
                    topRight: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                    bottomRight:
                        isMe ? Radius.circular(0) : Radius.circular(12),
                  ),
                ),
                child: Text(
                  message,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
