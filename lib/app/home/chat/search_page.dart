import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_focus_watcher/flutter_focus_watcher.dart';
import 'package:jio/app/home/events/empty_content.dart';
import 'package:provider/provider.dart';
import 'package:jio/app/home/JIO/profiledisplay.dart';
import 'package:jio/app/home/chat/ConversationsPage.dart';
import 'package:jio/app/home/chat/User_list_tile.dart';
import 'package:jio/app/home/chat/chatItembuilderdeafult.dart';
import 'package:jio/app/home/chat/chat_list_itembuilder.dart';
import 'package:jio/app/home/chat/friend_list_tile.dart';
import 'package:jio/app/home/models/friend.dart';
import 'package:jio/app/home/models/user.dart';
import 'package:jio/services/database.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _searchname;
  final myController = TextEditingController();
  bool _isGlobal;
  double _deviceHeight;
  double _deviceWidth;
  FocusNode focusNode;

  void initState() {
    super.initState();
    _searchname = '';
    _isGlobal = false;
  }

  void dispose() {
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final host = Provider.of<User>(context);
    _deviceWidth = MediaQuery.of(context).size.width;
    _deviceHeight = MediaQuery.of(context).size.height;
    return FocusWatcher(
      child: Container(
        constraints: BoxConstraints.expand(),
        decoration: BoxDecoration(
          color: Colors.black,
        ),
        child: Card(
            color: Colors.transparent,
            elevation: 0.0,
            margin: EdgeInsets.all(0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  _userSearchField(),
                  _isGlobal ? _userListView(host) : _userFriendListView(host),
                ],
              ),
            ),
          ),
      ),
    );
  }

  Widget _userSearchField() {
    return Container(
      height: _deviceHeight * 0.06,
      width: _deviceWidth,
      padding: EdgeInsets.symmetric(vertical: _deviceHeight * 0.01),
      child: TextField(
        autocorrect: false,
        style: TextStyle(color: Colors.white),
        controller: myController,
        focusNode: focusNode,
        onChanged: (_input) {
          if (_input.split("").first == '@') {
            setState(() {
              _isGlobal = true;
            });
          } else {
            setState(() {
              _isGlobal = false;
            });
          }
        },
        onSubmitted: (_input) {
          FocusScope.of(context).requestFocus(focusNode);
          if (_isGlobal) {
            setState(() {
              _searchname = _input.substring(1);
            });
          } else {
            setState(() {
              _searchname = _input;
            });
          }
        },
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.search,
            color: Colors.white,
          ),
          labelText: "Search",
          labelStyle: TextStyle(color: Colors.white),
          border: OutlineInputBorder(borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _userFriendListView(User host) {
    final database = Provider.of<Database>(context);
    return Container(
      height: _deviceHeight * 0.75,
      child: StreamBuilder<List<Friend>>(
        stream: database.userFriendData(database.host, _searchname),
        builder: (context, snapshot) {
          if(snapshot.hasData){
            return ChatItemBuilderDefault(
              snapshot: snapshot,
              itemBuilder: (context, friend) => FriendsSearchListTile(
                friend: friend,
                onTap: () async {
                  FocusScope.of(context).unfocus();
                  myController.clear();
                  String _conversationID = await database.createOrGetConversation(
                      context, database.host, friend.uid);
                  await database.updateChattingWith(database.host, friend.uid);
                  ConversationsPage.show(
                    context,
                    conversationID: _conversationID,
                    receiverID: friend.uid,
                    receiverImage: friend.photoUrl,
                    receiverName: friend.displayName,
                    database: database,
                  );
                },
              ),
            );
          }else if(snapshot.hasError){
            return EmptyContent();
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _userListView(User host) {
    final database = Provider.of<Database>(context);
    return Container(
      height: _deviceHeight * 0.75,
      child: StreamBuilder<List<User>>(
        stream: database.usersStream(_searchname),
        builder: (context, snapshot) {
          if (snapshot.hasData){
            return ChatListItemsBuilder(
              snapshot: snapshot,
              database: database,
              itemBuilder: (context, user) => AllUserSearchListTile(
                user: user,
                onTap: () async {
                  FocusScope.of(context).unfocus();
                  myController.clear();
                  ProfileDetailPage.show(
                    context,
                    user: user,
                    database: database,
                    width: _deviceWidth,
                    height: _deviceHeight,
                    jio: false,
                  );
                },
              ),
            );
          }else if(snapshot.hasError){
            return EmptyContent();
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
