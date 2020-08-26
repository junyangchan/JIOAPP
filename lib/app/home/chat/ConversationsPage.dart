import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_focus_watcher/flutter_focus_watcher.dart';
import 'package:jio/app/home/models/friend.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:jio/app/home/JIO/profiledisplay.dart';
import 'package:jio/app/home/events/edit_event_page.dart';
import 'package:jio/app/home/events/empty_content.dart';
import 'package:jio/app/home/models/Conversations.dart';
import 'package:jio/common_widgets/avatar.dart';
import 'package:jio/common_widgets/imagebutton.dart';
import 'package:jio/services/auth.dart';
import 'package:jio/services/database.dart';

class ConversationsPage extends StatefulWidget {
  const ConversationsPage(
      {Key key,
      this.conversationID,
      this.receiverID,
      this.receiverName,
      this.receiverImage,
      this.database})
      : super(key: key);

  final String conversationID;
  final String receiverID;
  final String receiverImage;
  final String receiverName;
  final Database database;

  static Future<void> show(
    BuildContext context, {
    conversationID,
    receiverID,
    receiverImage,
    receiverName,
    database,
  }) async {
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => ConversationsPage(
          conversationID: conversationID,
          receiverID: receiverID,
          receiverImage: receiverImage,
          receiverName: receiverName,
          database: database,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  _ConversationsPageState createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ConversationsPage> {
  double _deviceHeight;
  double _deviceWidth;
  GlobalKey<FormState> _formkey;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  int integer;

  String _messageText;
  _ConversationsPageState() {
    _formkey = GlobalKey<FormState>();
    _messageText = '';
    integer = 20;
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
    DateTime currentDate = timeStamp.toDate().add(Duration(hours: 8));
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
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () async {
              await widget.database
                  .updateChattingWith(widget.database.host, null);
              Navigator.of(context).pop();
            },
          ),
          title: ImageButton(
            onPressed: () async {
              final auth = Provider.of<AuthBase>(context);
              final user = await auth.firebaseToUser(widget.receiverID);
              ProfileDetailPage.show(
                context,
                user: user,
                database: widget.database,
                width: _deviceWidth,
                height: _deviceHeight,
                jio: false,
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Avatar(
                  image: widget.receiverImage,
                  radius: 40,
                ),
                SizedBox(
                  width: 10.0,
                ),
                Text(widget.receiverName),
              ],
            ),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.add_to_photos,
                color: Colors.white,
                size: 32.0,
              ),
              onPressed: () => EditEventPage.show(context,
                  database: widget.database,
                  specialInvite: Friend(
                    uid: widget.receiverID,
                    displayName: widget.receiverName,
                    photoUrl: widget.receiverImage,
                  )),
            )
          ],
        ),
        body: FocusWatcher(child: _conversationPageUI(context)),
      ),
    );
  }

  Widget _conversationPageUI(context) {
    return Builder(
      builder: (BuildContext context) {
        return Stack(
          children: <Widget>[
            _messageListView(context, widget.database),
            Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _messageField(context, widget.database)),
          ],
        );
      },
    );
  }

  Widget _messageListView(BuildContext context, Database database) {
    return Container(
      height:
          _deviceHeight - kToolbarHeight - MediaQuery.of(context).padding.top,
      width: _deviceWidth,
      color: Colors.black,
      child: StreamBuilder<Conversations>(
        stream: database.getConversation(widget.conversationID, "Individual"),
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
                  child: ListView.builder(
                      reverse: true,
                      //controller: _listViewController,
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                      itemCount: message.length,
                      itemBuilder: (BuildContext context, int _index) {
                        Message _message = message[message.length - _index - 1];
                        bool _isOwnMessage = _message.senderID == database.host;
                        return listViewChild(_isOwnMessage, _message);
                      }),
                ),
              );
            } else {
              return Align(
                alignment: Alignment.center,
                child: Text(
                  "Let's start a conversation!",
                  style: TextStyle(color: Colors.white),
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
      ),
    );
  }

  Widget listViewChild(bool _isOwnMessage, Message _message) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment:
            _isOwnMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: <Widget>[
          !_isOwnMessage
              ? Avatar(
                  image: widget.receiverImage,
                  radius: _deviceHeight * 0.05,
                )
              : Container(),
          SizedBox(
            width: _deviceWidth * 0.02,
          ),
          _message.type == "text"
              ? _textMessageBubble(
                  _isOwnMessage, _message.content, _message.timestamp)
              : _imageMessageBubble(
                  _isOwnMessage, _message.content, _message.timestamp),
        ],
      ),
    );
  }

  Widget _textMessageBubble(
      bool _isOwnMessage, String _message, Timestamp _timestamp) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
            color: _isOwnMessage ? Colors.transparent : Colors.white30),
        color:
            _isOwnMessage ? Color.fromRGBO(32, 32, 32, 1) : Colors.transparent,
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
          children: <Widget>[
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
                    color: Colors.white60, fontFamily: "Blinker", fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageMessageBubble(
      bool _isOwnMessage, String _imageURL, Timestamp _timestamp) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: _isOwnMessage ? Colors.transparent : Colors.white30),
        color:
            _isOwnMessage ? Color.fromRGBO(32, 32, 32, 1) : Colors.transparent,
      ),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: _deviceWidth * 0.50,
          maxHeight: _deviceHeight * 0.3,
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
                  child: CachedNetworkImage(
                    imageUrl: _imageURL,
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
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
                "Individual");
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
                  "Individual");
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
        cursorColor: Colors.blueAccent,
        autocorrect: false,
      ),
    );
  }
}
