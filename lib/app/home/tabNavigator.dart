import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jio/services/database.dart';
import 'JIO/JIO_landingPage.dart';
import 'TabItem.dart';
import 'account/account_page.dart';
import 'chat/chat_home_page.dart';
import 'events/events_page.dart';
import 'models/user.dart';
import 'my_events/my_events_home_page.dart';

class TabNavigatorRoutes {
  static Map<TabItem,String> tabItemToString = {
    TabItem.myevent: '/myEvent',
    TabItem.events: '/',
    TabItem.account:'/account',
    TabItem.chat: '/chat',
    TabItem.jio: '/jio',
  };
  static const String event = '/';
  static const String myEvent = '/myEvent';
  static const String jio = '/jio';
  static const String account = '/account';
  static const String chat = '/chat';
}

class TabNavigator extends StatelessWidget {
  TabNavigator({this.navigatorKey, this.tabItem});
  final GlobalKey<NavigatorState> navigatorKey;
  final TabItem tabItem;

  Map<String, WidgetBuilder> _routeBuilders(BuildContext context) {
    final database = Provider.of<Database>(context);
    return {
      TabNavigatorRoutes.event: (context) => EventsPage(),
      TabNavigatorRoutes.myEvent: (context) => MyEventsHomePage(),
      TabNavigatorRoutes.jio: (context) => JIOLandingPage(
        database: database,
        host: Provider.of<User>(context),
      ),
      TabNavigatorRoutes.account: (context) => AccountPage(),
      TabNavigatorRoutes.chat: (context) => ChatHomePage(
        database: database,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final routeBuilders = _routeBuilders(context);
    return Navigator(
      key: navigatorKey,
      initialRoute: TabNavigatorRoutes.tabItemToString[tabItem],
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(
          builder: (context) => routeBuilders[routeSettings.name](context),
        );
      },
    );
  }
}