import 'package:flutter/material.dart';
import 'package:jio/app/home/events/empty_content.dart';
import 'package:provider/provider.dart';
import 'package:jio/app/home/JIO/profiledisplay.dart';
import 'package:jio/app/home/account/friendRequestTile.dart';
import 'package:jio/app/home/chat/ConversationsPage.dart';
import 'package:jio/app/home/models/friend.dart';
import 'package:jio/app/home/models/user.dart';
import 'package:jio/common_widgets/List_items_builder.dart';
import 'package:jio/services/auth.dart';
import 'package:jio/services/database.dart';

class JioRequestPage extends StatefulWidget {
  const JioRequestPage(
      {Key key, @required this.database})
      : super(key: key);
  final Database database;

  static Future<void> show(
      BuildContext context, {
        Database database,
      }) async {
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => JioRequestPage(
          database: database,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  _JioRequestPageState createState() => _JioRequestPageState();
}

class _JioRequestPageState extends State<JioRequestPage> {
  @override
  Widget build(BuildContext context) {
    final _deviceHeight = MediaQuery.of(context).size.height;
    final _deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "You're Jioed!",
          style: TextStyle(
            fontFamily: 'KaushanScript',
            color: Colors.white,
            fontSize: 32.0,
          ),
        ),
        backgroundColor: Colors.black,
      ),
      body: Container(
        constraints: BoxConstraints.expand(),
        decoration: BoxDecoration(
          color: Colors.black,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16.0, 16.0, 16.0),
          child: Card(
            elevation: 0.0,
            margin: EdgeInsets.all(0),
            color: Colors.transparent,
            child: _buildContents(context, _deviceWidth, _deviceHeight),
          ),
        ),
      ),
    );
  }

  Widget _buildContents(
      BuildContext context, double _deviceWidth, double _deviceHeight) {
    final auth = Provider.of<AuthBase>(context);
    return StreamBuilder<List<Friend>>(
      stream: widget.database.jioRequestlist(widget.database.host),
      builder: (context, snapshot) {
        if(snapshot.hasData){
          return ListItemsBuilder<Friend>(
            title: "No Jio Request",
            snapshot: snapshot,
            itemBuilder: (context, friend) => FriendRequestTile(
              friend: friend,
              onTap: () async {
                User _friend = await auth.firebaseToUser(friend.uid);
                ProfileDetailPage.show(
                  context,
                  user: _friend,
                  database: widget.database,
                  width: _deviceWidth,
                  height: _deviceHeight,
                  jio: false,
                );
              },
              onAccept: () async{
                await widget.database.deleteJioedRequest(widget.database.host, friend.uid);
                String _conversationID = await widget.database.createOrGetConversation(
                    context, widget.database.host, friend.uid);
                await widget.database.updateChattingWith(widget.database.host, friend.uid);
                ConversationsPage.show(
                  context,
                  conversationID: _conversationID,
                  receiverID: friend.uid,
                  receiverImage: friend.photoUrl,
                  receiverName: friend.displayName,
                  database: widget.database,
                );
              },
              onReject: () async{
                await widget.database.deleteJioedRequest(widget.database.host, friend.uid);
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
