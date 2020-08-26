import 'package:flutter/material.dart';
import 'package:jio/app/home/events/empty_content.dart';
import 'package:jio/app/home/models/event.dart';
import 'package:jio/common_widgets/PictureTextIcon.dart';
import 'package:jio/services/database.dart';

class ParticipantsList extends StatelessWidget {
  const ParticipantsList({this.database, this.event, this.edit: false});
  final Database database;
  final Event event;
  final bool edit;

  @override
  Widget build(BuildContext context) {
    if (event != null) {
      return FutureBuilder<List<Map<String, dynamic>>>(
          future: database.getUserData(event.participants),
          initialData: [],
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final List<Map<String, dynamic>> items = snapshot.data;
              if (items != null) {
                return PictureText(
                  data: items,
                  title: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "I'm Down:",
                        style: TextStyle(
                            color: !edit ? Colors.white : Colors.black,
                            fontSize: 16.0),
                      ),
                      Text(
                        "${event.participants.length.toString()} joined",
                        style: TextStyle(
                            color: !edit ? Colors.white : Colors.black,
                            fontSize: 16.0),
                      )
                    ],
                  ),
                  text: "displayName",
                  category: false,
                );
              } else {
                return Container();
              }
            } else if (snapshot.hasError) {
              return EmptyContent(
                title: 'Something went wrong',
                message: 'Can\'t load items right now',
              );
            }
            return Center(child: CircularProgressIndicator());
          });
    }
    return Container(
      width: 0,
      height: 0,
    );
  }
}
