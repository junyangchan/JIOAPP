import 'package:flutter/material.dart';

enum TabItem { events, myevent, jio, chat, account }

class TabItemData {
  TabItemData({this.title, @required this.icon});
  final IconData icon;
  final String title;

  static Map<TabItem, TabItemData> allTabs = {
    TabItem.events: TabItemData(icon: Icons.home,title: ""),
    TabItem.myevent: TabItemData(icon: Icons.view_headline,title:""),
    TabItem.jio: TabItemData(icon:Icons.title,title:""),
    TabItem.chat: TabItemData(icon: Icons.chat,title:""),
    TabItem.account: TabItemData(icon: Icons.person,title: ""),
  };
}