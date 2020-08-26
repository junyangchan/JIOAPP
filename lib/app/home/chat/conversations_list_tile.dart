import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jio/app/home/models/user_conversations.dart';
import 'package:jio/common_widgets/avatar.dart';
import 'package:timeago/timeago.dart';

class ConversationsListTile extends StatelessWidget {
  const ConversationsListTile(
      {Key key, @required this.conversation, this.onTap})
      : super(key: key);
  final UserConversations conversation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(
        conversation.name,
        style: TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        conversation.type == "text" ? conversation.lastMessage : "Image",
        style: TextStyle(fontFamily: "Blinker", color: Colors.white54),
      ),
      leading: Avatar(
        image: conversation.image,
        radius: 50,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Text(
            format(conversation.timestamp.toDate()),
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          Container(
            height: 12,
            width: 12,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(100),
            ),
          ),
        ],
      ),
    );
  }
}
