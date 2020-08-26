import 'package:flutter/material.dart';
import 'package:jio/app/home/models/user.dart';
import 'package:jio/common_widgets/PictureTextIcon.dart';
import 'package:jio/services/database.dart';

class CategoryLevel extends StatelessWidget {
  const CategoryLevel({this.context, this.database, this.user, this.title});
  final BuildContext context;
  final Database database;
  final User user;
  final Widget title;
  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> data = user.categoryLevels;
    if (data == []) {
      return Container();
    } else {
      data.sort((Map a, Map b) {
        if (a['level'] > b['level']) {
          return -1;
        } else if (a['level'] < b['level']) {
          return 1;
        } else {
          return 0;
        }
      });
      List<Map<String, dynamic>> _data;
      if (data.length > 5) {
        _data = data.sublist(0, 5);
      } else {
        _data = data;
      }
      return PictureText(
        title: title,
        text: "level",
        data: _data,
        category: true,
        database: database,
      );
    }
  }
}
