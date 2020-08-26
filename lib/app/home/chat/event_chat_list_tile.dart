import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jio/app/home/models/event.dart';
import 'package:jio/common_widgets/avatar.dart';

class EventChatListTile extends StatelessWidget {
  const EventChatListTile({Key key, @required this.event, this.onTap})
      : super(key: key);
  final Event event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top:8.0,bottom: 8.0),
      child: ListTile(
        onTap: onTap,
        title: Text(
          event.name,
          style: TextStyle(color: Colors.white),
        ),
        subtitle: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              event.location,
              style: TextStyle(color: Colors.white54),
            ),
            Text(
              Event.convertDatetoString(event.startDate),
              style: TextStyle(color: Colors.white54),
            ),
          ],
        ),
        leading: Avatar(
          image: event.category['logo'],
          radius: 50,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text(
              "${event.participants.length.toString()} joined",
              style: TextStyle(color: Colors.white),
            ),
            Container(
              height: 12,
              width: 12,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(100),
              ),
            )
          ],
        ),
      ),
    );
  }
}
