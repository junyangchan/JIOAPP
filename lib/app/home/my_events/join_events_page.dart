import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:jio/app/home/events/empty_content.dart';
import 'package:jio/app/home/events/participants_list.dart';
import 'package:jio/app/home/models/event.dart';
import 'package:jio/common_widgets/platform_alert_dialog.dart';
import 'package:jio/services/database.dart';

class JoinEventsPage extends StatefulWidget {
  const JoinEventsPage(
      {@required this.database, @required this.event, this.past});
  final Database database;
  final Event event;
  final bool past;

  static Future<void> show(BuildContext context, Event event,
      {bool past: false}) async {
    final Database database = Provider.of<Database>(context);
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        fullscreenDialog: false,
        builder: (context) =>
            JoinEventsPage(database: database, event: event, past: past),
      ),
    );
  }

  @override
  _JoinEventsPageState createState() => _JoinEventsPageState();
}

class _JoinEventsPageState extends State<JoinEventsPage> {
  bool _isLoading = false;
  double _deviceHeight;
  double _deviceWidth;
  //List<int> _selectedList = [];
  //List<String> _inviteList = [];

  //callback(newlist, selectedList) {
  //setState(() {
  //_selectedList = selectedList;
  //_inviteList = newlist;
  //});
  //}

  Future<void> _join(BuildContext context, Event event, String type) async {
    setState(() {
      _isLoading = true;
    });
    await widget.database
        .updateEventParticipants(event, widget.database.host, type);
    type == "add"
        ? await FirebaseMessaging().subscribeToTopic(event.id)
        : await FirebaseMessaging().unsubscribeFromTopic(event.id);
    if (mounted) {
      setState(() {
        _isLoading = false;
        PlatformAlertDialog(
          title: type == "add" ? 'Joined Event' : 'Quit Event',
          content: type == "add"
              ? 'Successfully joined the event'
              : 'Successfully left the event',
          defaultActionText: 'OK',
          special: true,
        ).show(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return StreamBuilder<Event>(
        stream: widget.past
            ? widget.database.pastEventStream(
                uid: widget.event.hostid, eventId: widget.event.id)
            : widget.database.eventStream(eventId: widget.event.id),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final event = snapshot.data;
            if (event != null) {
              return buildScaffold(event, context);
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
        });
  }

  Widget buildScaffold(Event event, BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ModalProgressHUD(
        inAsyncCall: _isLoading,
        color: Colors.transparent,
        child: CustomScrollView(
          shrinkWrap: false,
          slivers: <Widget>[
            SliverAppBar(
              elevation: 0.0,
              expandedHeight: _deviceWidth * 0.75,
              pinned: true,
              snap: false,
              floating: false,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  "${event.hostDisplayName}'s Event",
                  style: TextStyle(
                    fontFamily: 'KaushanScript',
                    color: Colors.white,
                    fontSize: 18.0,
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    Container(
                      height: _deviceWidth * 0.75,
                      width: _deviceWidth,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          colorFilter: ColorFilter.mode(
                              Colors.black.withOpacity(0.6), BlendMode.dstATop),
                          image: CachedNetworkImageProvider(
                              event.category['event']),
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text(
                    event.participants.contains(widget.database.host)
                        ? 'Quit'
                        : 'Join',
                    style: TextStyle(
                        fontSize: 18,
                        color: widget.past
                            ? Color.fromRGBO(1, 1, 1, 0)
                            : Colors.white),
                  ),
                  onPressed: () {
                    if (!widget.past) {
                      if (!event.participants.contains(widget.database.host)) {
                        _join(context, event, "add");
                      } else {
                        _join(context, event, "remove");
                      }
                    }
                  },
                ),
              ],
              backgroundColor: Colors.black,
            ),
            SliverList(
              delegate: SliverChildListDelegate(<Widget>[
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                  ),
                  child: Padding(
                      padding: EdgeInsets.only(
                          top: 12, left: 24, right: 24, bottom: 0),
                      child: _buildForm()),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildTitle(),
        SizedBox(
          height: _deviceHeight * 0.02,
        ),
        Divider(
          color: Colors.white,
        ),
        SizedBox(
          height: _deviceHeight * 0.02,
        ),
        ParticipantsList(
          database: widget.database,
          event: widget.event,
        ),
        widget.event.description != ''
            ? Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: new Text(
                  "Description",
                  style: new TextStyle(color: Colors.white, fontSize: 16.0),
                ),
              )
            : Container(),
        Text(
          widget.event.description,
          style: new TextStyle(color: Colors.white70, fontSize: 14.0),
        ),
        SizedBox(
          height: _deviceWidth - kToolbarHeight,
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Text(
          widget.event.name,
          style: TextStyle(fontSize: 24.0, color: Colors.white),
        ),
        SizedBox(
          height: _deviceHeight * 0.02,
        ),
        Row(
          children: <Widget>[
            Text(
              Event.convertDatetoString(widget.event.startDate),
              style: TextStyle(fontSize: 12.0, color: Colors.white54),
            ),
            SizedBox(
              width: _deviceWidth * 0.04,
            ),
            Text(
              widget.event.location,
              style: TextStyle(fontSize: 12.0, color: Colors.white54),
            ),
          ],
        )
      ],
    );
  }
}
