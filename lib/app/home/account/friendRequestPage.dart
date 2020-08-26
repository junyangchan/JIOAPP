import 'package:flutter/material.dart';
import 'package:jio/app/home/events/empty_content.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:jio/app/home/JIO/profiledisplay.dart';
import 'package:jio/app/home/account/friendRequestTile.dart';
import 'package:jio/app/home/models/friend.dart';
import 'package:jio/app/home/models/user.dart';
import 'package:jio/common_widgets/List_items_builder.dart';
import 'package:jio/services/auth.dart';
import 'package:jio/services/database.dart';

class FriendRequestPage extends StatefulWidget {
  const FriendRequestPage(
      {Key key, @required this.database})
      : super(key: key);
  final Database database;

  static Future<void> show(
    BuildContext context, {
    Database database,
  }) async {
    await Navigator.of(context, rootNavigator: true).push(
      PageTransition(
        type: PageTransitionType.rightToLeftWithFade,
        child:FriendRequestPage(
          database: database,
        ),
      ),
    );
  }

  @override
  _FriendRequestPageState createState() => _FriendRequestPageState();
}

class _FriendRequestPageState extends State<FriendRequestPage> {
  bool _isLoading = false;
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
          "Add Friends",
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
      stream: widget.database.friendRequestStream(widget.database.host),
      builder: (context, snapshot) {
        if(snapshot.hasData){
          return ModalProgressHUD(
            inAsyncCall: _isLoading,
            color: Colors.transparent,
            child: ListItemsBuilder<Friend>(
              title: "No Friend Request",
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
                onAccept: () async {
                  setState(() {
                    _isLoading = true;
                  });
                  await widget.database.addFriend(friend.uid, widget.database.host);
                  setState(() {
                    _isLoading = false;
                  });
                },
                onReject: () async{
                  setState(() {
                    _isLoading = true;
                  });
                  await widget.database
                      .deleteFriendRequest(friend.uid, widget.database.host);
                  setState(() {
                    _isLoading = false;
                  });
                },
              ),
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
