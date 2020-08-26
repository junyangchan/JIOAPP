import 'package:flutter/material.dart';
import 'package:jio/app/home/events/empty_content.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:jio/app/home/chat/ConversationsPage.dart';
import 'package:jio/app/home/chat/conversations_list_tile.dart';
import 'package:jio/app/home/chat/profilechatlisttile.dart';
import 'package:jio/app/home/models/user.dart';
import 'package:jio/app/home/models/user_conversations.dart';
import 'package:jio/services/database.dart';

class ChatPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints.expand(),
      decoration: BoxDecoration(
        color: Colors.black,
      ),
      child: Card(
          color: Colors.transparent,
          elevation: 0.0,
          margin: EdgeInsets.all(0),
          child: _buildContents(context)),
    );
  }

  Widget _buildContents(BuildContext context) {
    final database = Provider.of<Database>(context);
    return StreamBuilder<ChatData>(
      stream: CombineLatestStream.combine2(
          database.conversationStream(database.host),
          database.userStream(database.host),
          (List<UserConversations> a, User b) => ChatData(a, b)),
      builder: (context, snapshot) {
        if(snapshot.hasData){
          return ProfileChatListTile<UserConversations>(
            snapshot: snapshot,
            itemBuilder: (context, conversation) => ConversationsListTile(
              conversation: conversation,
              onTap: () async {
                await database.updateChattingWith(
                    database.host, conversation.receiverID);
                ConversationsPage.show(
                  context,
                  database: database,
                  conversationID: conversation.id,
                  receiverName: conversation.name,
                  receiverImage: conversation.image,
                  receiverID: conversation.receiverID,
                );
              },
            ),
          );
        }else if(snapshot.hasError){
          return EmptyContent();
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
