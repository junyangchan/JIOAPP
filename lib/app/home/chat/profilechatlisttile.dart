import 'package:flutter/material.dart';
import 'package:jio/app/home/events/empty_content.dart';
import 'package:jio/app/home/models/user_conversations.dart';
import 'package:jio/services/database.dart';

typedef ItemWidgetBuilder<T> = Widget Function(
    BuildContext context, UserConversations item);

class ProfileChatListTile<T> extends StatelessWidget {
  const ProfileChatListTile({
    Key key,
    @required this.snapshot,
    @required this.itemBuilder,
  }) : super(key: key);
  final AsyncSnapshot<ChatData> snapshot;
  final ItemWidgetBuilder<T> itemBuilder;

  @override
  Widget build(BuildContext context) {
    if (snapshot.hasData) {
      final List<UserConversations> items = snapshot.data.conversations;
      items.removeWhere((element) => element.timestamp == null);
      if (items.isNotEmpty) {
        return _buildList(items, context);
      } else {
        return EmptyContent();
      }
    } else if (snapshot.hasError) {
      print(snapshot.error);
      return EmptyContent(
        title: 'Something went wrong',
        message: 'Can\'t load items right now',
      );
    }
    return Center(child: CircularProgressIndicator());
  }

  Widget _buildList(List<UserConversations> items, context) {
    return MediaQuery.removePadding(
      removeTop: true,
      context: context,
      child: ListView.separated(
        itemCount: items.length,
        separatorBuilder: (context, index) => Divider(height: 0.5,indent: 80,color: Colors.white30,thickness: 1,),
        itemBuilder: (context, index) {
          return itemBuilder(context, items[index]);
        },
      ),
    );
  }
}
