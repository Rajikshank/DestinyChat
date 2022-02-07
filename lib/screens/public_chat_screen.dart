import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gvchat/helpers/encrytion.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:gvchat/screens/group_detail_screen.dart';
import 'package:gvchat/helpers/public_chat_meths.dart';
import 'package:gvchat/widgets/chats/group_messages.dart';
import 'package:gvchat/widgets/chats/message_bubble.dart';
import 'package:gvchat/widgets/chats/new_message.dart';

import '../widgets/chats/messages.dart';
import '../helpers/screen_arguements.dart';
import '../widgets/chats/Public_chat_message.dart';
import '../widgets/chats/Public_send_message.dart';

class public_screen extends StatefulWidget {
  static const routeName = '/public-chats';

  @override
  _public_screenState createState() => _public_screenState();
}

class _public_screenState extends State<public_screen> {
  bool public = false;
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as ScreenArguments;
    print('public can be implemented');
    return Scaffold(
      backgroundColor: Color(0xFF0d0b14),
      appBar: AppBar(
        backgroundColor: Color(0xFF0d0b14),
        title: GestureDetector(
          onTap: args.isGroup
              ? () {
                  Navigator.of(context).pushNamed(Public_details.routeName,
                      arguments: args.chatRoomId);
                }
              : null,
          child: Row(
            children: [
              CircleAvatar(
                radius: 15,
                backgroundImage: args.imageUrl.isEmpty
                    ? AssetImage(
                        'assets/images/person.png',
                      )
                    : NetworkImage(args.imageUrl) as ImageProvider,
              ),
              SizedBox(
                width: 12,
              ),
              Text(args.username),
              if (args.isGroup)
                IconButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(Public_details.routeName,
                          arguments: args.chatRoomId);
                    },
                    icon: Icon(
                      Icons.info_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    )),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(child: publicMessage(args.chatRoomId)),
          PublicNewMessage(args.chatRoomId),
        ],
      ),
    );
  }
}
