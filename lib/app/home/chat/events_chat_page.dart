import 'package:flutter/material.dart';
import 'package:jio/app/home/events/empty_content.dart';
import 'package:provider/provider.dart';
import 'package:jio/app/home/chat/chatItembuilderdeafult.dart';
import 'package:jio/app/home/chat/event_chat_list_tile.dart';
import 'package:jio/app/home/chat/group_conversationPage.dart';
import 'package:jio/app/home/models/event.dart';
import 'package:jio/app/home/models/user.dart';
import 'package:jio/services/database.dart';

class EventsChatPage extends StatelessWidget {
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
    final user = Provider.of<User>(context);
    return StreamBuilder<List<Event>>(
      stream: database.currentEventsStream(database.host),
      builder: (context, snapshot) {
        if(snapshot.hasData){
          return ChatItemBuilderDefault<Event>(
            snapshot: snapshot,
            itemBuilder: (context, event) => EventChatListTile(
              event: event,
              onTap: () async{
                await database.updateChattingWith(
                    database.host, event.id);
                GroupConversationsPage.show(
                  context,
                  database: database,
                  event: event,
                  conversationID: event.id,
                  user: user,
                );
              },
            ),
          );
        }else if(snapshot.hasError){
          print(snapshot.error);
          return EmptyContent();
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
