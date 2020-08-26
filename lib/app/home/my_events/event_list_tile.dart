import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jio/app/home/models/event.dart';
import 'package:jio/common_widgets/avatar.dart';
import 'package:jio/common_widgets/imagebutton.dart';

class EventListTile extends StatelessWidget {
  const EventListTile(
      {Key key,
      @required this.event,
      this.past: false,
      this.onTap,
      this.height,
      this.width})
      : super(key: key);
  final double height;
  final double width;
  final Event event;
  final VoidCallback onTap;
  final bool past;

  @override
  Widget build(BuildContext context) {
    return ImageButton(
        onPressed: onTap,
        child: Container(
          height: 80,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: past
                  ? Colors.grey
                  : Color.fromRGBO(
                      32, 32, 32, 1) //past? Colors.white70:Colors.transparent,
              ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                width: width * 0.25,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Avatar(
                      image: event.category['logo'],
                      radius: width * 0.15,
                    ),
                  ],
                ),
              ),
              Container(
                width: width * 0.50,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    overflowText(event.name, Colors.white, width * 0.50),
                    overflowText(event.location, Colors.white54, width * 0.50),
                    Text(
                      Event.convertDatetoString(event.startDate),
                      style: TextStyle(color: Colors.white54),
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              Container(
                width: width * 0.25,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Avatar(
                      image: event.hostPhotoURL,
                      radius: width * 0.08,
                    ),
                    Text(
                      "${event.participants.length.toString()} joined",
                      style: TextStyle(color: Colors.white),
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
    );
  }

  Widget overflowText(String text, Color color, double size) {
    return Text(
      text,
      style: TextStyle(color: color),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
