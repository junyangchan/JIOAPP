import 'package:flutter/material.dart';
import 'package:jio/app/home/events/empty_content.dart';
import 'package:provider/provider.dart';
import 'package:jio/app/home/events/edit_event_page.dart';
import 'package:jio/app/home/my_events/event_list_tile.dart';
import 'package:jio/app/home/models/event.dart';
import 'package:jio/app/home/my_events/join_events_page.dart';
import 'package:jio/common_widgets/List_items_builder.dart';
import 'package:jio/services/database.dart';

class MyEventsPage extends StatelessWidget {
  const MyEventsPage({this.isOngoing});
  final bool isOngoing;

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
        child: isOngoing
            ? _buildCurrentContents(context)
            : _buildPastContents(context),
      ),
    );
  }

  Widget _buildCurrentContents(BuildContext context) {
    final database = Provider.of<Database>(context);
    return StreamBuilder<List<Event>>(
      stream: database.currentEventsStream(database.host),
      builder: (context, snapshot) {
        if(snapshot.hasData){
          return ListItemsBuilder<Event>(
            snapshot: snapshot,
            itemBuilder: (context, event) => EventListTile(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width-16.0,
                event: event,
                onTap: () {
                  if (event.hostid == database.host) {
                    EditEventPage.show(context, event: event, database: database);
                  } else {
                    JoinEventsPage.show(context, event);
                  }

                }),
          );
        }else if(snapshot.hasError){
          return EmptyContent();
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildPastContents(BuildContext context) {
    final database = Provider.of<Database>(context);
    return StreamBuilder<List<Event>>(
      stream: database.pastEventsStream(database.host),
      builder: (context, snapshot) {
        if(snapshot.hasData){
          return ListItemsBuilder<Event>(
            snapshot: snapshot,
            itemBuilder: (context, event) => EventListTile(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width-16.0,
              event: event,
              past: true,
              onTap: () {
                JoinEventsPage.show(context, event, past: true);
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
