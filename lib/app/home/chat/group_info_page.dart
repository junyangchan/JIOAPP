import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jio/app/home/JIO/profiledisplay.dart';
import 'package:jio/app/home/events/edit_event_page.dart';
import 'package:jio/app/home/models/event.dart';
import 'package:jio/common_widgets/List_items_builder.dart';
import 'package:jio/common_widgets/avatar.dart';
import 'package:jio/services/auth.dart';
import 'package:jio/services/database.dart';

class GroupInfoPage extends StatefulWidget {
  const GroupInfoPage(
      {Key key, this.event, this.database, this.width, this.height})
      : super(key: key);
  final Event event;
  final Database database;
  final double width;
  final double height;

  static Future<void> show(
    BuildContext context, {
    Event event,
    Database database,
    double width,
    double height,
  }) async {
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => GroupInfoPage(
          event: event,
          database: database,
          width: width,
          height: height,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  _GroupInfoPageState createState() => _GroupInfoPageState();
}

class _GroupInfoPageState extends State<GroupInfoPage>
    with TickerProviderStateMixin {
  AnimationController _containerController;
  Animation<double> width;
  Animation<double> height;

  void initState() {
    _containerController = new AnimationController(
        duration: new Duration(milliseconds: 2000), vsync: this);
    super.initState();
    width = new Tween<double>(
      begin: widget.width,
      end: widget.width,
    ).animate(
      new CurvedAnimation(
        parent: _containerController,
        curve: Curves.ease,
      ),
    );
    height = new Tween<double>(
      begin: widget.height - 100,
      end: widget.height,
    ).animate(
      new CurvedAnimation(
        parent: _containerController,
        curve: Curves.ease,
      ),
    );
    height.addListener(() {
      setState(() {
        if (height.isCompleted) {}
      });
    });
    _containerController.forward();
  }

  @override
  void dispose() {
    _containerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.of(context).pop();
        return Future.value(true);
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(width.value*0.5),
          child: AppBar(
            elevation: 0.0,
            backgroundColor: Color.fromRGBO(32, 32, 32, 1),
            leading: new IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: new Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 30,
              ),
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.edit,
                    color: widget.database.host == widget.event.hostid
                        ? Colors.white
                        : Color.fromRGBO(1, 1, 1, 0)),
                onPressed: () {
                  if (widget.database.host == widget.event.hostid) {
                    EditEventPage.show(context,
                        database: widget.database, event: widget.event);
                  }
                },
              )
            ],
            flexibleSpace: SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Avatar(
                      image: widget.event.category['logo'],
                      radius: width.value*0.3,
                    ),
                    SizedBox(height: height.value*0.03,),
                    Text(
                      widget.event.name,
                      style: TextStyle(color: Colors.white,fontSize: 28),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        body: Card(
          elevation: 0,
          color: Colors.transparent,
          margin: EdgeInsets.all(0.0),
          child: new Container(
            alignment: Alignment.center,
            width: width.value,
            height: height.value,
            decoration: new BoxDecoration(
              color: Colors.black,
            ),
            child: Container(
              child: FutureBuilder(
                future: widget.database.getUserData(widget.event.participants),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListItemsBuilder<Map<String, dynamic>>(
                      title: "No participants",
                      snapshot: snapshot,
                      itemBuilder: (context, data) => Container(
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(32, 32, 32, 1),
                          borderRadius: BorderRadius.circular(10)
                        ),
                        child: ListTile(
                          onTap: () async{
                            final auth = Provider.of<AuthBase>(context);
                            final user = await auth.firebaseToUser(data['uid']);
                            ProfileDetailPage.show(
                              context,
                              user: user,
                              database: widget.database,
                              width: width.value,
                              height: height.value,
                            );
                          },
                          leading: Avatar(
                            image: data['photoUrl'],
                            radius: 40,
                          ),
                          title: Text(
                            data['displayName'],
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    );
                  }
                  return Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
