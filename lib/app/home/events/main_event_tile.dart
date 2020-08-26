import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jio/app/home/models/event.dart';
import 'package:jio/common_widgets/avatar.dart';
import 'package:jio/common_widgets/imagebutton.dart';

class MainEventListTile extends StatelessWidget {
  const MainEventListTile(
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
    return Container(
        height: 180,
        width: width,
        decoration: BoxDecoration(
          color: Colors.transparent,
        ),
        child: ImageButton(
          onPressed: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 120,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10)),
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(event.category['event']),
                      fit: BoxFit.cover,
                    )),
              ),
              Container(
                height: 60,
                width: width,
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10)),
                  color: Color.fromRGBO(32, 32, 32, 1),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex:8,
                          child: overflowText(
                            event.name,
                            Colors.white,
                            14.0,
                          ),
                        ),
                        Expanded(
                          flex:2,
                          child: Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Avatar(
                                  image: event.hostPhotoURL,
                                  radius: 20,
                                ),
                                event.participants.length>1?
                                    Text(' + ${(event.participants.length-1).toString()}',style: TextStyle(color: Colors.white),):
                                    Container()
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                            flex:9,
                            child: overflowText(event.location, Colors.white54, 12.0)),
                        Expanded(
                          flex: 3,
                          child: overflowText(
                              Event.convertDatetoString(event.startDate),
                              Colors.white54,
                              12.0),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
    );
  }

  Widget overflowText(String text, Color color, double size) {
    return Text(
      text,
      style: TextStyle(color: color, fontSize: size),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
