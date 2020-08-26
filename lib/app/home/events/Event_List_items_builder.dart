import 'package:flutter/material.dart';
import 'package:jio/app/home/events/empty_content.dart';
import 'package:jio/app/home/models/event.dart';
import 'package:jio/services/database.dart';

typedef ItemWidgetBuilder<T> = Widget Function(
    BuildContext context, Event item);
typedef ItemWidgetBuilder_2<T> = Widget Function(
    BuildContext context, String item);

class EventListItemsBuilder<T> extends StatefulWidget {
  const EventListItemsBuilder({
    Key key,
    @required this.database,
    @required this.snapshot,
    @required this.itemBuilder_1,
    @required this.itemBuilder_2,
    this.selectedDate,
    this.color,
    this.deviceHeight,
    this.deviceWidth,
    this.onPressed,
  }) : super(key: key);
  final AsyncSnapshot<List<Event>> snapshot;
  final ItemWidgetBuilder_2<T> itemBuilder_1;
  final ItemWidgetBuilder<T> itemBuilder_2;
  final Database database;
  final String selectedDate;
  final Color color;
  final double deviceHeight;
  final double deviceWidth;
  final onPressed;

  @override
  _EventListItemsBuilderState<T> createState() =>
      _EventListItemsBuilderState<T>();
}

class _EventListItemsBuilderState<T> extends State<EventListItemsBuilder<T>> {
  @override
  Widget build(BuildContext context) {
    if (widget.snapshot.hasData && widget.snapshot.data!=null) {
      final List<Event> items = widget.snapshot.data;
      return _buildList(items, context);
    } else if (widget.snapshot.hasError) {
      print(widget.snapshot.error);
      return EmptyContent(
        title: 'Something went wrong',
        message: 'Can\'t load items right now',
      );
    }
    return Center(child: CircularProgressIndicator());
  }

  Widget _buildList(List<Event> items, BuildContext context) {
    List<String> dateList = [null];
    for (Event event in items) {
      String date = Event.convertDatetoStringDate(event.startDate);
      if (!dateList.contains(date)) {
        dateList.add(date);
      }
    }
    if (widget.selectedDate != null) {
      items.removeWhere((element) =>
          Event.convertDatetoStringDate(element.startDate) !=
          widget.selectedDate);
    }
    return Row(children: <Widget>[
      Flexible(
        flex: 1,
        child: Container(
          decoration: BoxDecoration(
              color: Color.fromRGBO(
                  32, 32, 32, 1) //past? Colors.white70:Colors.transparent,
              ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                flex:1,
                child: IconButton(
                  icon: Icon(
                    Icons.search,
                    color: widget.color,
                    size: 20,
                  ),
                  onPressed: widget.onPressed,
                ),
              ),
              Flexible(
                flex:10,
                child: ListView.builder(
                  itemCount: dateList.length + 2,
                  itemBuilder: (context, index) {
                    if (index == 0 || index == dateList.length + 1) {
                      return Container();
                    }
                    return widget.itemBuilder_1(context, dateList[index - 1]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      Flexible(
        flex: 5,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10.0),
                bottomLeft: Radius.circular(10.0)),
            color: Colors.black,
          ),
          padding: EdgeInsets.all(8.0),
          child: ListView.separated(
            itemCount: items.length + 2,
            separatorBuilder: (context, index) => Divider(height: 8.0),
            itemBuilder: (context, index) {
              if (index == 0 || index == items.length + 1) {
                return Container();
              }
              return widget.itemBuilder_2(context, items[index - 1]);
            },
          ),
        ),
      ),
    ]);
  }
}
