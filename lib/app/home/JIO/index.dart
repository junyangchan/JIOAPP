import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:jio/app/home/JIO/JioedPage.dart';
import 'package:jio/app/home/JIO/active_profile.dart';
import 'package:jio/app/home/JIO/dummy_profiles.dart';
import 'package:jio/app/home/events/empty_content.dart';
import 'package:jio/app/home/models/user.dart';
import 'package:jio/services/database.dart';

class JIO extends StatefulWidget {
  const JIO({this.users, this.database});
  final List<User> users;
  final Database database;
  @override
  JIOState createState() => new JIOState();
}

class JIOState extends State<JIO> with TickerProviderStateMixin {
  AnimationController _buttonController;
  Animation<double> rotate;
  Animation<double> right;
  Animation<double> bottom;
  Animation<double> width;
  int flag = 0;
  void initState() {
    super.initState();
    _buttonController = new AnimationController(
        duration: new Duration(milliseconds: 1000), vsync: this);

    rotate = new Tween<double>(
      begin: -0.0,
      end: -40.0,
    ).animate(
      new CurvedAnimation(
        parent: _buttonController,
        curve: Curves.ease,
      ),
    );
    rotate.addListener(() {
      setState(() {
        if (rotate.isCompleted) {
          widget.users.removeLast();
          _buttonController.reset();
        }
      });
    });

    right = new Tween<double>(
      begin: 0.0,
      end: 400.0,
    ).animate(
      new CurvedAnimation(
        parent: _buttonController,
        curve: Curves.ease,
      ),
    );
    bottom = new Tween<double>(
      begin: 15.0,
      end: 100.0,
    ).animate(
      new CurvedAnimation(
        parent: _buttonController,
        curve: Curves.ease,
      ),
    );
    width = new Tween<double>(
      begin: 20.0,
      end: 25.0,
    ).animate(
      new CurvedAnimation(
        parent: _buttonController,
        curve: Curves.bounceOut,
      ),
    );
  }

  @override
  void dispose() {
    _buttonController.dispose();
    super.dispose();
  }

  Future<Null> _swipeAnimation() async {
    try {
      await _buttonController.forward();
    } on TickerCanceled {}
  }

  dismissImg(User user) {
    widget.database.bojio(widget.database.host, user.uid);
    if(mounted){
      setState(() {
        widget.users.remove(user);
      });
    }
  }

  addImg(User user) {
    widget.database.jio(widget.database.host,user.uid);
    if(mounted){
      setState(() {
        widget.users.remove(user);
      });
    }
  }

  swipeRight(User user) {
    widget.database.jio(widget.database.host,user.uid);
    if (flag == 0)
      setState(() {
        flag = 1;
      });
    _swipeAnimation();
  }

  swipeLeft(User user) {
    widget.database.bojio(widget.database.host, user.uid);
    if (flag == 1)
      setState(() {
        flag = 0;
      });
    _swipeAnimation();
  }

  @override
  Widget build(BuildContext context) {
    timeDilation = 0.4;
    int dataLength = widget.users.length;
    double initialBottom = 15.0;
    double backCardPosition = initialBottom + (dataLength - 1) * 10 + 10;
    double backCardWidth = -10.0;
    return buildScaffold(dataLength, backCardWidth, context, backCardPosition);
  }

  Widget buildScaffold(dataLength, double backCardWidth, BuildContext context, double backCardPosition) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.black,
        centerTitle: true,
        leading:Icon(Icons.format_list_bulleted,color:Color.fromRGBO(1, 1, 1, 0),),
        actions: [
          IconButton(
            icon: Icon(Icons.format_list_bulleted,color:Colors.white,),
            onPressed: ()=>JioRequestPage.show(
              context,
              database:widget.database,
            ),
          )
        ],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "JIO",
              style: new TextStyle(fontFamily: "KaushanScript",fontSize: 32.0),
            ),
            Container(
              width: 15.0,
              height: 15.0,
              margin: EdgeInsets.only(bottom: 20.0),
              alignment: Alignment.center,
              child: Text(
                dataLength.toString(),
                style: TextStyle(fontSize: 10.0),
              ),
              decoration:
                  BoxDecoration(color: Colors.red, shape: BoxShape.circle),
            ),
          ],
        ),
      ),
      body: Container(
        color: Colors.black,
        alignment: Alignment.center,
        child: dataLength > 0
            ? Stack(
                alignment: AlignmentDirectional.center,
                children: widget.users.map((user) {
                  var index = widget.users.indexOf(user);
                  if (index == dataLength - 1) {
                    return cardActive(
                        widget.users[index],
                        widget.database,
                        bottom.value,
                        right.value,
                        0.0,
                        backCardWidth + 10,
                        rotate.value,
                        rotate.value < -10 ? 0.1 : 0.0,
                        context,
                        dismissImg,
                        flag,
                        addImg,
                        swipeRight,
                        swipeLeft);
                  } else {
                    backCardPosition = backCardPosition - 10;
                    backCardWidth = backCardWidth + 10;
                    return cardDummy(user.photoUrl, backCardPosition, 0.0, 0.0,
                        backCardWidth, 0.0, 0.0, context);
                  }
                }).toList())
            : EmptyContent(title:"No swipes left",message: "Please wait for an hour",),
      ));
  }
}
