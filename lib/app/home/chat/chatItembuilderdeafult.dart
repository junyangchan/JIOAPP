import 'package:flutter/material.dart';
import 'package:jio/app/home/events/empty_content.dart';

typedef ItemWidgetBuilder<T> = Widget Function(BuildContext context, T item);

class ChatItemBuilderDefault<T> extends StatelessWidget {
  const ChatItemBuilderDefault({
    Key key,
    @required this.snapshot,
    @required this.itemBuilder,
    this.title,
  }) : super(key: key);
  final AsyncSnapshot<List<T>> snapshot;
  final ItemWidgetBuilder<T> itemBuilder;
  final String title;

  @override
  Widget build(BuildContext context) {
    if (snapshot.hasData) {
      final List<T> items = snapshot.data;
      if (items.isNotEmpty) {
        return _buildList(items,context);
      } else {
        return title!=null?EmptyContent(title: title,message: "",):EmptyContent();
      }
    } else if (snapshot.hasError) {
      return EmptyContent(
        title: 'Something went wrong',
        message: 'Can\'t load items right now',
      );
    }
    return Center(child: CircularProgressIndicator());
  }

  Widget _buildList(List<T> items,context) {
    return MediaQuery.removePadding(
      removeTop: true,
      context: context,
      child: ListView.separated(
          itemCount: items.length,
          separatorBuilder: (context, index) => Divider(height: 0.5,indent: 80,color: Colors.white54,),
          itemBuilder: (context, index) {
            return itemBuilder(context, items[index]);
          },
        ),
    );
  }
}
