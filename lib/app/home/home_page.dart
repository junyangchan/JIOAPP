import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:jio/app/home/tabNavigator.dart';
import 'package:provider/provider.dart';
import 'package:jio/app/home/JIO/JioedPage.dart';
import 'package:jio/app/home/JIO/profiledisplay.dart';
import 'package:jio/app/home/account/friendRequestPage.dart';
import 'package:jio/app/home/chat/ConversationsPage.dart';
import 'package:jio/app/home/my_events/join_events_page.dart';
import 'package:jio/common_widgets/platform_exception_alert_dialog.dart';
import 'package:jio/services/Geolocator.dart';
import 'package:jio/services/api_path.dart';
import 'package:jio/services/auth.dart';
import 'package:jio/services/database.dart';
import 'FloatingActionButton.dart';
import 'TabItem.dart';
import 'models/event.dart';
import 'models/user.dart';

class HomePage extends StatefulWidget {
  const HomePage({@required this.database});
  final Database database;
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TabItem _currentTab = TabItem.events;
  int _currentIndex;
  double _deviceWidth;
  double _deviceHeight;
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    registerNotification();
    configLocalNotification();
  }

  Future<void> loadPosition() async {
    Position _position = await Geolocation.getCurrentLocation();
    Firestore.instance.document(APIPath.user(widget.database.host)).updateData({
      'location': {'lat': _position.latitude, 'long': _position.longitude}
    });
  }

  void registerNotification() {
    firebaseMessaging.requestNotificationPermissions();
    firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
      print('onMessage: $message');

      Platform.isAndroid
          ? showNotification(message)
          : showNotification(message['aps']['alert']);

      return;
    }, onResume: (Map<String, dynamic> message) async {
      print('onResume: $message');
      return;
    }, onLaunch: (Map<String, dynamic> message) async {
      print('onLaunch: $message');

      return;
    });
    //update host token
    firebaseMessaging.getToken().then((token) async {
      print('token: $token');
      await widget.database.updatePushToken(widget.database.host, token);
      //load position
      await loadPosition();
    }).catchError(
      (err) {
        PlatformExceptionAlertDialog(
          title: "Push Token Error",
          exception: err,
        ).show(context);
      },
    );
  }

  Future _notificationNavigator(String value) async {
    Map<String, dynamic> data = json.decode(value);
    print(data);

    var type = data['type'];
    if (type == "Chat") {
      ConversationsPage.show(
        context,
        conversationID: data['conversationID'],
        receiverID: data['receiverID'],
        receiverName: data['receiverName'],
        receiverImage:
            data['receiverImage'] != "none" ? data['receiverImage'] : null,
        database: widget.database,
      );
    } else if (type == "Event") {
      Event event = await widget.database.getEvent(data['eventID']);
      JoinEventsPage.show(context, event);
    } else if (type == "Friend Request") {
      FriendRequestPage.show(context, database: widget.database);
    } else if (type == "Friend Request Accepted") {
      final auth = Provider.of<AuthBase>(context);
      User friend = await auth.firebaseToUser(data['userFrom']);
      _deviceWidth = MediaQuery.of(context).size.width;
      _deviceHeight = MediaQuery.of(context).size.height;
      ProfileDetailPage.show(context,
          database: widget.database,
          user: friend,
          width: _deviceWidth,
          height: _deviceHeight,
          jio: false);
    } else if (type == "JIO") {
      var friend = await widget.database.getUserData([data['userFrom']]);
      await widget.database
          .jioRequest(widget.database.host, data['userFrom'], friend[0]);
      if (mounted) {
        JioRequestPage.show(
          context,
          database: widget.database,
        );
      }
    }
    return;
  }

  void showNotification(message) async {
    if (message['data']['type'] == "Event Chat") {
      final auth = Provider.of<AuthBase>(context);
      User user = await auth.firebaseToUser(widget.database.host);
      if (user.chattingWith == message['data']['conversationID']) {
        return;
      }
    }
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      'com.codingwithflutter.jio',
      'JIO APP',
      'Nothing MUCH',
      playSound: true,
      enableVibration: true,
      importance: Importance.Max,
      priority: Priority.High,
    );
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    print(message);
//    print(message['body'].toString());
//    print(json.encode(message));

    await flutterLocalNotificationsPlugin.show(
        0,
        message['notification']['title'].toString(),
        message['notification']['body'].toString(),
        platformChannelSpecifics,
        payload: json.encode(message['data']));

//    await flutterLocalNotificationsPlugin.show(
//        0, 'plain title', 'plain body', platformChannelSpecifics,
//        payload: 'item x');
  }

  void configLocalNotification() {
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: _notificationNavigator);
    flutterLocalNotificationsPlugin.cancelAll();
  }

  final Map<TabItem, GlobalKey<NavigatorState>> navigatorKeys = {
    TabItem.events: GlobalKey<NavigatorState>(),
    TabItem.myevent: GlobalKey<NavigatorState>(),
    TabItem.jio: GlobalKey<NavigatorState>(),
    TabItem.chat: GlobalKey<NavigatorState>(),
    TabItem.account: GlobalKey<NavigatorState>(),
  };

  void _selectedTab(int index) {
    TabItem tabItem = indexToTabItem[index];
    setState(() {
      _currentTab = tabItem;
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    _deviceWidth = MediaQuery.of(context).size.width;
    _deviceHeight = MediaQuery.of(context).size.height;
    //update host current location
    return WillPopScope(
      onWillPop: () async {
        final isFirstRouteInCurrentTab =
            !await navigatorKeys[_currentTab].currentState.maybePop();
        if (isFirstRouteInCurrentTab) {
          // if not on the 'main' tab
          if (_currentTab != TabItem.events) {
            // select 'main' tab
            _selectedTab(0);
            // back button handled by app
            return false;
          }
        }
        // let system handle back button if we're on the first route
        return isFirstRouteInCurrentTab;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        resizeToAvoidBottomInset: false,
        body:
            IndexedStack(index: tabItemToIndex[_currentTab], children: <Widget>[
          _buildOffstageNavigator(TabItem.events),
          _buildOffstageNavigator(TabItem.myevent),
          _buildOffstageNavigator(TabItem.chat),
          _buildOffstageNavigator(TabItem.account),
          _buildOffstageNavigator(TabItem.jio),
        ]),
        floatingActionButton: Container(
          height: _deviceWidth * 0.20,
          width: _deviceWidth * 0.20,
          child: FloatingActionButton(
            child: Container(
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage('images/app_logo.jpeg'),
                    fit: BoxFit.cover,
                  )),
            ),
            tooltip: 'Increment',
            backgroundColor: Colors.transparent,
            elevation: 5.0,
            onPressed: () => _selectedTab(4),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: FABBottomAppBar(
          centerItemText: '',
          color: Colors.grey,
          backgroundColor: Color.fromRGBO(32, 32, 32, 1),
          selectedColor: Colors.blueAccent,
          notchedShape: CircularNotchedRectangle(),
          onTabSelected: _selectedTab,
          items: [
            FABBottomAppBarItem(iconData: Icons.home, text: 'Events'),
            FABBottomAppBarItem(iconData: Icons.menu, text: 'My Event'),
            FABBottomAppBarItem(iconData: Icons.chat_bubble, text: 'Chats'),
            FABBottomAppBarItem(iconData: Icons.person, text: 'Account'),
          ],
        ),
        // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }

  Map<TabItem, int> tabItemToIndex = {
    TabItem.events: 0,
    TabItem.myevent: 1,
    TabItem.jio: 4,
    TabItem.chat: 2,
    TabItem.account: 3,
  };
  Map<int, TabItem> indexToTabItem = {
    0: TabItem.events,
    1: TabItem.myevent,
    4: TabItem.jio,
    2: TabItem.chat,
    3: TabItem.account,
  };

  Widget _buildOffstageNavigator(TabItem tabItem) {
    return Visibility(
      visible: _currentTab == tabItem,
      child: TabNavigator(
        navigatorKey: navigatorKeys[tabItem],
        tabItem: tabItem,
      ),
    );
  }
}
