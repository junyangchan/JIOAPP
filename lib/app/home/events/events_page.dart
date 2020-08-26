import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_focus_watcher/flutter_focus_watcher.dart';
import 'package:jio/app/home/events/searchDialogBox.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:jio/app/home/events/DateListTile.dart';
import 'package:jio/app/home/events/edit_event_page.dart';
import 'package:jio/app/home/events/main_event_tile.dart';
import 'package:jio/app/home/models/event.dart';
import 'package:jio/app/home/my_events/join_events_page.dart';
import 'package:jio/services/database.dart';
import 'Event_List_items_builder.dart';
import 'empty_content.dart';

class EventsPage extends StatefulWidget {
  @override
  _EventsPageState createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  String selectedDate;
  Color selectedColor;
  double _deviceHeight;
  double _deviceWidth;
  FocusNode focusNode;
  String _searchName;
  Color color = Colors.white;
  List<String> _list = [];
  List<int> _selectedList = [];
  List<String> _category = [];
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  int _numEvents = 50;
  TextEditingController myController;

  callback(newlist, selectedList) {
    setState(() {
      _selectedList = selectedList;
      _list = newlist;
    });
  }

  completed(text) {
    setState(() {
      _searchName = text;
      _category = _list;
    });
  }

  colorCallback() {
    setState(() {
      if (_searchName != '' || _category.isNotEmpty) {
        color = Colors.redAccent;
      } else {
        color = Colors.white;
      }
    });
  }

  void _onLoading() async {
    // monitor network fetch
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    await Future.delayed(Duration(milliseconds: 100));
    if (mounted)
      setState(() {
        _numEvents += 20;
      });
    _refreshController.loadComplete();
  }

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void initState() {
    super.initState();
    _searchName = '';
    selectedDate = null;
    selectedColor = Colors.redAccent;
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    final database = Provider.of<Database>(context);
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Color.fromRGBO(32, 32, 32, 1),
        leading: Icon(
          Icons.create,
          color: Color.fromRGBO(1, 1, 1, 0),
          size: 32,
        ),
        title: Center(
          child: Text(
            "Events",
            style: TextStyle(
              color: Colors.white,
              fontSize: 32.0,
              fontFamily: "KaushanScript",
            ),
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.create, color: Colors.white, size: 32.0),
            onPressed: () => EditEventPage.show(
              context,
              database: database,
            ),
          ),
        ],
      ),
      body: Container(
          constraints: BoxConstraints.expand(),
          decoration: BoxDecoration(
            color: Color.fromRGBO(32, 32, 32, 1),
          ),
          child: FocusWatcher(child: _buildContents(context, database))),
    );
  }

  Widget _buildContents(BuildContext context, Database database) {
    return StreamBuilder<List<Event>>(
      stream: database.eventsStream(_searchName, _category, _numEvents),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return SmartRefresher(
            onRefresh: _onRefresh,
            onLoading: _onLoading,
            controller: _refreshController,
            enablePullUp: true,
            child: EventListItemsBuilder<Event>(
              deviceHeight: _deviceHeight,
              deviceWidth: _deviceWidth,
              database: database,
              snapshot: snapshot,
              selectedDate: selectedDate,
              color: color,
              onPressed: () {
                SearchDialogBox.show(
                  context,
                  database: database,
                  categoryCallback: callback,
                  selectedCategoryList: _selectedList,
                  colorCallback: colorCallback,
                  completed: completed,
                  deviceHeight: _deviceHeight,
                  deviceWidth: _deviceWidth,
                  myController: myController =
                      TextEditingController(text: _searchName),
                );
              },
              itemBuilder_1: (context, date) => DateListTile(
                deviceHeight: _deviceHeight,
                deviceWidth: _deviceWidth,
                date: date,
                color: selectedColor,
                selectedDate: selectedDate,
                onTap: () {
                  setState(() {
                    selectedDate = date;
                  });
                },
              ),
              itemBuilder_2: (context, event) => MainEventListTile(
                height: _deviceHeight,
                width: _deviceWidth * 0.80,
                event: event,
                onTap: () {
                  if (event.hostid == database.host) {
                    EditEventPage.show(context,
                        event: event, database: database);
                  } else {
                    JoinEventsPage.show(context, event);
                  }
                },
              ),
            ),
          );
        } else if (snapshot.hasError) {
          print(snapshot.error);
          return EmptyContent(title: "Something went wrong");
        }
        return Container(
          color: Color.fromRGBO(32, 32, 32, 1),
          padding: EdgeInsets.symmetric(),
          child: Row(
            children: <Widget>[
              Flexible(
                flex: 1,
                child: Container(
                  width: _deviceWidth * 0.2,
                  padding: EdgeInsets.only(top: 14),
                  decoration: BoxDecoration(
                      color: Color.fromRGBO(32, 32, 32,
                          1) //past? Colors.white70:Colors.transparent,
                      ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              Flexible(
                flex: 5,
                child: Container(
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            bottomLeft: Radius.circular(10))),
                    child: Center(child: CircularProgressIndicator())),
              ),
            ],
          ),
        );
      },
    );
  }
}
