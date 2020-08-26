import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_focus_watcher/flutter_focus_watcher.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:jio/app/home/chat/group_info_page.dart';
import 'package:jio/app/home/events/edit_event_page.dart';
import 'package:jio/app/home/events/empty_content.dart';
import 'package:jio/app/home/models/Conversations.dart';
import 'package:jio/app/home/models/event.dart';
import 'package:jio/app/home/models/user.dart';
import 'package:jio/common_widgets/avatar.dart';
import 'package:jio/common_widgets/imagebutton.dart';
import 'package:jio/services/database.dart';

class GroupConversationsPage extends StatefulWidget {
  const GroupConversationsPage(
      {Key key,
      @required this.conversationID,
      @required this.event,
      @required this.user,
      @required this.database})
      : super(key: key);

  final String conversationID;
  final Database database;
  final Event event;
  final User user;

  static Future<void> show(
    BuildContext context, {
    conversationID,
    event,
    user,
    database,
  }) async {
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => GroupConversationsPage(
          conversationID: conversationID,
          database: database,
          event: event,
          user: user,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  _GroupConversationsPageState createState() => _GroupConversationsPageState();
}

class _GroupConversationsPageState extends State<GroupConversationsPage> {
  double _deviceHeight;
  double _deviceWidth;
  GlobalKey<FormState> _formkey;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  int integer;
  Map<String, Map<String, dynamic>> _participantsDetails;
  String _messageText;
  String hostID;
  String groupImage;
  String groupName;
  List<String> participants;

  void initState() {
    super.initState();
    _formkey = GlobalKey<FormState>();
    _messageText = '';
    integer = 20;
    _participantsDetails = {};
    hostID = widget.event.hostid;
    groupImage = widget.event.category['logo'];
    groupName = widget.event.name;
    participants = widget.event.participants;
  }

  void _onLoading() async {
    // monitor network fetch
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    await Future.delayed(Duration(milliseconds: 100));
    if (mounted)
      setState(() {
        integer += 20;
      });
    _refreshController.loadComplete();
  }

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  String convertTimeStampToString(Timestamp timeStamp) {
    DateTime currentDate = timeStamp.toDate();
    String startTimeHour = currentDate.hour.toString().split("").length == 1
        ? "0${currentDate.hour.toString()}"
        : currentDate.hour.toString();
    String startTimeMinute = currentDate.minute.toString().split("").length == 1
        ? "0${currentDate.minute.toString()}"
        : currentDate.minute.toString();
    return "$startTimeHour:$startTimeMinute";
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async {
        await widget.database.updateChattingWith(widget.database.host, null);
        return Future.value(true);
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black87,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () async {
              await widget.database
                  .updateChattingWith(widget.database.host, null);
              Navigator.of(context).pop();
            },
          ),
          title: ImageButton(
            onPressed: () {
              GroupInfoPage.show(context,
                  width: _deviceWidth,
                  height: _deviceHeight,
                  database: widget.database,
                  event: widget.event);
            },
            child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              Avatar(
                image: groupImage,
                radius: 40,
              ),
              SizedBox(
                width: 10.0,
              ),
              Flexible(
                  child: Text(
                groupName,
                overflow: TextOverflow.ellipsis,
              )),
            ]),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.edit,
                  color: widget.database.host == hostID
                      ? Colors.white
                      : Color.fromRGBO(1, 1, 1, 0)),
              onPressed: () {
                if (widget.database.host == hostID) {
                  EditEventPage.show(context,
                      database: widget.database, event: widget.event);
                }
              },
            )
          ],
        ),
        body: FocusWatcher(
          child: Stack(children: [
            _conversationPageUI(context),
            Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _messageField(context, widget.database)),
          ]),
        ),
      ),
    );
  }

  Widget _conversationPageUI(context) {
    return Container(
      height:
          _deviceHeight - kToolbarHeight - MediaQuery.of(context).padding.top,
      width: _deviceWidth,
      color: Colors.black,
      child: FutureBuilder(
          future: widget.database.getUserData(participants),
          builder: (BuildContext context, snapshot) {
            if (snapshot.hasData) {
              for (Map<String, dynamic> i in snapshot.data) {
                _participantsDetails.addAll({i['uid']: i});
              }
              return _messageListView(context, widget.database);
            } else if (snapshot.hasError) {
              print(snapshot.error);
              return EmptyContent(
                title: 'Something went wrong',
                message: 'Can\'t load items right now',
              );
            }
            return Center(child: CircularProgressIndicator());
          }),
    );
  }

  Widget _messageListView(BuildContext context, Database database) {
    return StreamBuilder<Conversations>(
      stream: database.getConversation(widget.conversationID, "Group"),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          Conversations _conversation = snapshot.data;
          List<Message> message;
          if (_conversation.messages.length != 0) {
            message = _conversation.messages;
            if (_conversation.messages.length > integer) {
              message = _conversation.messages
                  .sublist(_conversation.messages.length - integer);
            }
            return Padding(
              padding: EdgeInsets.only(bottom: _deviceHeight * 0.10),
              child: SmartRefresher(
                onLoading: _onLoading,
                onRefresh: _onRefresh,
                controller: _refreshController,
                enablePullUp: true,
                child: ListView.separated(
                    reverse: true,
                    //controller: _listViewController,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                    itemCount: message.length,
                    separatorBuilder: (context, int) => Divider(
                          height: _deviceHeight * 0.01,
                        ),
                    itemBuilder: (BuildContext context, int _index) {
                      Message _message = message[message.length - _index - 1];
                      return listViewChild(_message);
                    }),
              ),
            );
          } else {
            return Align(
              alignment: Alignment.center,
              child: Text(
                "Let's start a conversation!",
                style: TextStyle(color: Colors.white, fontSize: 18.0),
              ),
            );
          }
        } else if (snapshot.hasError) {
          return EmptyContent(
            title: 'Something went wrong',
            message: 'Can\'t load items right now',
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget listViewChild(Message _message) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Avatar(
            image: _participantsDetails[_message.senderID]['photoUrl'],
            radius: _deviceHeight * 0.05,
          ),
          SizedBox(
            width: _deviceWidth * 0.02,
          ),
          _message.type == "text"
              ? _textMessageBubble(
                  _message.content,
                  _participantsDetails[_message.senderID]['displayName'],
                  _message.timestamp,
                  _message.senderID,
                )
              : _imageMessageBubble(
                  _message.content,
                  _participantsDetails[_message.senderID]['displayName'],
                  _message.timestamp,
                  _message.senderID),
        ],
      ),
    );
  }

  Widget _textMessageBubble(String _message, String _messageName,
      Timestamp _timestamp, String _senderID) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: Text(
            _messageName,
            style: TextStyle(
              fontFamily: "Blinker",
              fontWeight: FontWeight.bold,
              color: widget.event.hostid == _senderID
                  ? Colors.redAccent
                  : Colors.white,
            ),
          ),
        ),
        SizedBox(
          height: _deviceHeight * 0.01,
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: Color.fromRGBO(32, 32, 32, 1),
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(10),
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10)),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: _deviceHeight * 0.03,
              maxWidth: _deviceWidth * 0.75,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Flexible(
                  child: Text(
                    _message,
                    style: TextStyle(
                      fontFamily: "Blinker",
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(
                  width: _deviceWidth * 0.03,
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    convertTimeStampToString(_timestamp),
                    style: TextStyle(
                        color: Colors.white60,
                        fontFamily: "Blinker",
                        fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _imageMessageBubble(String _imageURL, String _messageName,
      Timestamp _timestamp, String _senderID) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: Text(
            _messageName,
            style: TextStyle(
              fontFamily: "Blinker",
              fontWeight: FontWeight.bold,
              color: widget.event.hostid == _senderID
                  ? Colors.redAccent
                  : Colors.white,
            ),
          ),
        ),
        SizedBox(
          height: _deviceHeight * 0.01,
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          decoration: BoxDecoration(
          color: Colors.transparent,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: _deviceWidth * 0.50,
              maxHeight: _deviceHeight*0.3,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Container(
                        decoration:BoxDecoration(
                          color: Color.fromRGBO(32,32,32,1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        padding: EdgeInsets.all(2),
                        child: CachedNetworkImage(
                          imageUrl: _imageURL,
                          placeholder: (context, url) => CircularProgressIndicator(),
                          errorWidget: (context, url, error) => Icon(Icons.error),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: _deviceWidth * 0.03,
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        convertTimeStampToString(_timestamp),
                        style: TextStyle(
                            color: Colors.white60,
                            fontFamily: "Blinker",
                            fontSize: 10),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _messageField(BuildContext context, Database database) {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromRGBO(32, 32, 32, 1),
      ),
      child: Form(
        key: _formkey,
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              SizedBox(
                width: _deviceWidth * 0.04,
              ),
              sendImageButton(database),
              SizedBox(
                width: _deviceWidth * 0.04,
              ),
              Flexible(child: _messageTextField()),
              sendmessagebutton(database, context),
            ],
          ),
        ),
      ),
    );
  }

  Widget sendImageButton(Database database) {
    return Container(
      width: _deviceWidth * 0.05,
      child: FloatingActionButton(
        child: Icon(
          Icons.camera_enhance,
          color: Colors.white,
        ),
        onPressed: () async {
          var _image = await database.getImage();
          if (_image != null) {
            var _imageUrl = await database.uploadMediaMessage(
                database.host, _image, "message");
            await database.sendMessage(
                widget.conversationID,
                Message(
                    content: _imageUrl,
                    senderID: database.host,
                    timestamp: Timestamp.now(),
                    type: "image"),
                "Group");
          }
        },
      ),
    );
  }

  Widget sendmessagebutton(Database database, BuildContext context) {
    return Container(
      width: _deviceWidth * 0.05,
      child: IconButton(
        icon: Icon(
          Icons.send,
          color: Colors.blueAccent,
        ),
        onPressed: () {
          if (_formkey.currentState.validate()) {
            _formkey.currentState.save();
            if (_messageText != "") {
              database.sendMessage(
                  widget.conversationID,
                  Message(
                      content: _messageText,
                      timestamp: Timestamp.now(),
                      senderID: database.host,
                      type: "text"),
                  "Group");
            }
            _formkey.currentState.reset();
            FocusScope.of(context).unfocus();
          }
        },
      ),
    );
  }

  Widget _messageTextField() {
    return Container(
      width: _deviceWidth * 0.75,
      margin: EdgeInsets.symmetric(vertical: _deviceHeight * 0.015),
      child: TextFormField(
        textCapitalization: TextCapitalization.sentences,
        maxLines: null,
        keyboardType: TextInputType.multiline,
        enableSuggestions: true,
        style: TextStyle(
          fontFamily: "Blinker",
          decoration: TextDecoration.none,
          color: Colors.white,
        ),
        onSaved: (_input) {
          _messageText = _input;
        },
        decoration: new InputDecoration(
          isDense: true,
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          hintText: "Type a message",
          hintStyle: TextStyle(
            fontFamily: "KaushanScript",
            color: Colors.white30,
          ),
          contentPadding: EdgeInsets.fromLTRB(
              _deviceWidth * 0.02, 0, _deviceWidth * 0.02, 0),
        ),
        cursorColor: Colors.white,
        autocorrect: false,
      ),
    );
  }
}
