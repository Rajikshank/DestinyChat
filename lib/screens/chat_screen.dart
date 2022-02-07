import 'package:flutter/material.dart';
import 'package:gvchat/screens/group_detail_screen.dart';
import 'package:gvchat/widgets/chats/group_messages.dart';
import 'package:gvchat/widgets/chats/new_message.dart';

import '../widgets/chats/messages.dart';
import '../helpers/screen_arguements.dart';

class ChatScreen extends StatefulWidget {
  static const routeName = '/chats';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
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
                  Navigator.of(context).pushNamed(GroupDetailScreen.routeName,
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
                      Navigator.of(context).pushNamed(
                          GroupDetailScreen.routeName,
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
          Expanded(
            child: args.isGroup
                ? GroupMessages(args.chatRoomId)
                : Messages(args.chatRoomId, args.imageUrl),
          ),
          NewMessage(args.chatRoomId, args.isGroup),
        ],
      ),
    );
  }
}
