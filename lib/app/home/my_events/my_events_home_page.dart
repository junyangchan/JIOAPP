import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jio/app/home/events/edit_event_page.dart';
import 'package:jio/app/home/my_events/my_event_page.dart';
import 'package:jio/services/database.dart';

class MyEventsHomePage extends StatefulWidget {
  @override
  _MyEventsHomePageState createState() => _MyEventsHomePageState();
}

class _MyEventsHomePageState extends State<MyEventsHomePage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  _MyEventsHomePageState() {
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
  }

  Widget _tabBarPages() {
    return TabBarView(
      controller: _tabController,
      children: <Widget>[
        MyEventsPage(isOngoing: true,),
        MyEventsPage(isOngoing: false,)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Color.fromRGBO(32, 32, 32, 1),
        leading: Opacity(
          child: Icon(Icons.add),
          opacity: 0.0,
        ),
        title: Center(
          child: Text(
            'My Events',
            style: TextStyle(
              fontFamily: 'KaushanScript',
              color: Colors.white,
              fontSize: 32.0,
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.transparent,
          labelColor: Colors.white,
          tabs: <Widget>[
            Tab(
              icon: Text("Now",),
            ),
            Tab(
              icon: Text("Past",),
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: () => EditEventPage.show(
              context,
              database: Provider.of<Database>(context),
            ),
          ),
        ],
      ),
      body: _tabBarPages(),
    );
  }
}
