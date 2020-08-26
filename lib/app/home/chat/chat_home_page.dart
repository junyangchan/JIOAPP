import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jio/app/home/chat/chat_page.dart';
import 'package:jio/app/home/chat/events_chat_page.dart';
import 'package:jio/app/home/chat/search_page.dart';
import 'package:jio/services/database.dart';

class ChatHomePage extends StatefulWidget {
  const ChatHomePage({this.database});
  final Database database;

  @override
  _ChatHomePageState createState() => _ChatHomePageState();
}

class _ChatHomePageState extends State<ChatHomePage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;


  _ChatHomePageState() {
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
  }


  Widget _tabBarPages() {
    return TabBarView(
      controller: _tabController,
      children: <Widget>[
        SearchPage(),
        ChatPage(),
        EventsChatPage(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    _tabController.addListener(() {
      int index = _tabController.index;
      if(index!=0){
        FocusScope.of(context).unfocus();
      }
    });

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        elevation: 1.0,
        backgroundColor: Color.fromRGBO(32, 32, 32, 1),
        automaticallyImplyLeading: false,
        title: Center(
          child: Text(
            'Chats',
            style: TextStyle(
              fontFamily: 'KaushanScript',
              color: Colors.white,
              fontSize: 32.0,
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          unselectedLabelColor: Colors.white30,
          indicatorColor: Colors.transparent,
          labelColor: Colors.white,
          tabs: <Widget>[
            Tab(
              icon: Icon(Icons.people_outline, size: 25),
            ),
            Tab(
              icon: Icon(Icons.chat_bubble_outline, size: 25),
            ),
            Tab(
              icon: Icon(Icons.event, size: 25),
            ),
          ],
        ),
      ),
      body: _tabBarPages(),
    );
  }
}
