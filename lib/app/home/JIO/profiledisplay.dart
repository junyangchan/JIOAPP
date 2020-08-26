import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:jio/app/home/events/empty_content.dart';
import 'package:jio/app/home/models/user.dart';
import 'package:jio/common_widgets/CategoryLevel.dart';
import 'package:jio/common_widgets/platform_alert_dialog.dart';
import 'package:jio/services/Geolocator.dart';
import 'package:jio/services/database.dart';
import 'package:timeago/timeago.dart';

class ProfileDetailPage extends StatefulWidget {
  const ProfileDetailPage(
      {Key key,
      this.user,
      this.database,
      this.width,
      this.height,
      this.jio: false})
      : super(key: key);
  final User user;
  final Database database;
  final double width;
  final double height;
  final bool jio;

  static Future<void> show(
    BuildContext context, {
    User user,
    Database database,
    double width,
    double height,
    bool jio,
  }) async {
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => ProfileDetailPage(
          user: user,
          database: database,
          width: width,
          height: height,
          jio: jio,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  _ProfileDetailPageState createState() => _ProfileDetailPageState();
}

class _ProfileDetailPageState extends State<ProfileDetailPage>
    with TickerProviderStateMixin {
  AnimationController _containerController;
  Animation<double> width;
  Animation<double> height;
  bool _isLoading = false;

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
        body: new Hero(
          tag: "img",
          child: new Card(
            elevation: 0,
            color: Colors.transparent,
            margin: EdgeInsets.all(0.0),
            child: new Container(
              alignment: Alignment.center,
              width: width.value,
              height: height.value,
              decoration: new BoxDecoration(
                color: Color.fromRGBO(32, 32, 32, 1),
              ),
              child: ModalProgressHUD(
                inAsyncCall: _isLoading,
                color: Colors.transparent,
                child: new Stack(
                  alignment: AlignmentDirectional.bottomCenter,
                  children: <Widget>[
                    StreamBuilder<User>(
                        stream: widget.database.userStream(widget.database.host),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            User host = snapshot.data;
                            return new CustomScrollView(
                              shrinkWrap: false,
                              slivers: <Widget>[
                                buildSliverAppBar(context, host),
                                buildSliverList(context,host),
                              ],
                            );
                          } else if (snapshot.hasError) {
                            return EmptyContent();
                          }
                          return Center(child: CircularProgressIndicator());
                        }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  SliverList buildSliverList(BuildContext context, User host) {
    return SliverList(
      delegate: new SliverChildListDelegate(<Widget>[
        new Container(
          color: Colors.transparent,
          child: new Padding(
            padding: const EdgeInsets.all(35.0),
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Container(
                  padding: new EdgeInsets.only(bottom: 20.0),
                  alignment: Alignment.center,
                  decoration: new BoxDecoration(
                      color: Colors.transparent,
                      border: new Border(
                          bottom: new BorderSide(color: Colors.white))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        widget.user.displayName,
                        style: TextStyle(fontSize: 24, color: Colors.white),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          new Row(
                            children: <Widget>[
                              new Icon(
                                Icons.access_time,
                                color: Colors.cyan,
                              ),
                              new Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  format(widget.user.lastSeen.toDate()),
                                  style: TextStyle(color: Colors.white),
                                ),
                              )
                            ],
                          ),
                          new Row(
                            children: <Widget>[
                              new Icon(
                                Icons.map,
                                color: Colors.cyan,
                              ),
                              new Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: buildDistance(host),
                              )
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                new Padding(
                  padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                  child: CategoryLevel(
                    context: context,
                    database: widget.database,
                    user: widget.user,
                    title: Container(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: widget.user.description != null
                      ? Text(
                          "About Me",
                          style: new TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold),
                        )
                      : Container(),
                ),
                widget.user.description != null
                    ? Text(
                        widget.user.description,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                        ),
                      )
                    : Container(),
                Container(
                  height: widget.width * 0.25,
                )
              ],
            ),
          ),
        ),
      ]),
    );
  }

  Widget buildSliverAppBar(BuildContext context, User host) {
    return SliverAppBar(
      elevation: 0.0,
      forceElevated: true,
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
          onPressed: () async {
            if (host.uid != widget.user.uid &&
                !host.friendlist.contains(widget.user.uid)) {
              if (host.friendRequest.contains(widget.user.uid)) {
                //remove friend request
                final deleteFriendRequest = await PlatformAlertDialog(
                  title: 'Remove Friend Request',
                  content:
                      'Remove your friend request to ${widget.user.displayName}?',
                  cancelActionText: 'No',
                  defaultActionText: 'Yes',
                ).show(context);
                if (deleteFriendRequest == true) {
                  setState(() {
                    _isLoading = true;
                  });
                  await widget.database
                      .deleteFriendRequest(host.uid, widget.user.uid);
                  setState(() {
                    _isLoading = false;
                  });
                }
              } else {
                //add friend
                final addFriendRequest = await PlatformAlertDialog(
                  title: 'Add Friend',
                  content: 'Send ${widget.user.displayName} a friend request?',
                  cancelActionText: 'No',
                  defaultActionText: 'Yes',
                ).show(context);
                if (addFriendRequest == true) {
                  setState(() {
                    _isLoading = true;
                  });
                  await widget.database.friendRequest(widget.user.uid, host);
                  setState(() {
                    _isLoading = false;
                  });
                }
              }
            }
          },
          icon: Icon(
            host.friendRequest.contains(widget.user.uid)
                ? Icons.done
                : Icons.person_add,
            color: host.uid != widget.user.uid &&
                    !host.friendlist.contains(widget.user.uid)
                ? Colors.white
                : Colors.transparent,
            size: 30,
          ),
        )
      ],
      expandedHeight: width.value,
      pinned: false,
      floating: true,
      snap: false,
      flexibleSpace: new FlexibleSpaceBar(
        background: new Stack(
          fit: StackFit.expand,
          children: <Widget>[
            new Container(
              width: width.value,
              height: width.value,
              decoration: new BoxDecoration(
                image: DecorationImage(
                  image: widget.user.photoUrl != null
                      ? CachedNetworkImageProvider(widget.user.photoUrl)
                      : AssetImage('images/placeholder.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDistance(User host) {
    return FutureBuilder(
        future: Geolocation.distanceFromHost(
            host.location['lat'],
            host.location['long'],
            widget.user.location['lat'],
            widget.user.location['long']),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            int distance = (snapshot.data / 1000).floor();
            return Text(
              "${distance}km",
              style: TextStyle(color: Colors.white),
            );
          } else if (snapshot.hasError) {
            return EmptyContent(
              title: "Something went Wrong",
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }

  Widget buildOptions() {
    return Container(
      width: widget.width,
      height: widget.height * 0.10,
      decoration: new BoxDecoration(
        color: Colors.black87,
      ),
      alignment: Alignment.center,
      child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            new FlatButton(
                padding: new EdgeInsets.all(0.0),
                onPressed: () {},
                child: new Container(
                  height: widget.height * 0.08,
                  width: widget.width * 0.4,
                  alignment: Alignment.center,
                  decoration: new BoxDecoration(
                    color: Colors.red,
                    borderRadius: new BorderRadius.circular(60.0),
                  ),
                  child: new Text(
                    "BOJIO",
                    style: new TextStyle(color: Colors.white),
                  ),
                )),
            new FlatButton(
                padding: new EdgeInsets.all(0.0),
                onPressed: () {},
                child: new Container(
                  height: widget.height * 0.08,
                  width: widget.width * 0.4,
                  alignment: Alignment.center,
                  decoration: new BoxDecoration(
                    color: Colors.cyan,
                    borderRadius: new BorderRadius.circular(60.0),
                  ),
                  child: new Text(
                    "JIO",
                    style: new TextStyle(color: Colors.white),
                  ),
                ))
          ]),
    );
  }
}
