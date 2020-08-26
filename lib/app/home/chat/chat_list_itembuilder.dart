import 'package:flutter/material.dart';
import 'package:jio/app/home/events/empty_content.dart';
import 'package:jio/app/home/models/user.dart';
import 'package:jio/services/database.dart';

typedef ItemWidgetBuilder<T> = Widget Function(BuildContext context, User item);

class ChatListItemsBuilder<T> extends StatelessWidget {
  const ChatListItemsBuilder({
    Key key,
    @required this.snapshot,
    @required this.itemBuilder,
    this.database,
  }) : super(key: key);
  final AsyncSnapshot<List<User>> snapshot;
  final ItemWidgetBuilder<T> itemBuilder;
  final Database database;

  @override
  Widget build(BuildContext context) {
    if (snapshot.hasData) {
      final List<User> items = snapshot.data;
      items.removeWhere((element) => element.uid == database.host);
      if (items.isNotEmpty) {
        return _buildList(items, context);
      } else {
        return EmptyContent();
      }
    } else if (snapshot.hasError) {
      return EmptyContent(
        title: 'Something went wrong',
        message: 'Can\'t load items right now',
      );
    }
    return Center(child: CircularProgressIndicator());
  }

  Widget _buildList(List<User> items, context) {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
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
