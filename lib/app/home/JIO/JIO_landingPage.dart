import 'package:flutter/material.dart';
import 'package:jio/app/home/JIO/index.dart';
import 'package:jio/app/home/events/empty_content.dart';
import 'package:jio/app/home/models/user.dart';
import 'package:jio/services/database.dart';

class JIOLandingPage extends StatelessWidget {
  const JIOLandingPage({this.database, this.host});
  final Database database;
  final User host;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<User>>(
          future: database.matchUser(host),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<User> users = snapshot.data;
              return JIO(
                users: users,
                database: database,
              );
            } else if (snapshot.hasError) {
              print(snapshot.error);
              return EmptyContent(title: "Something went Wrong",);
            } else {
              return Scaffold(
                backgroundColor: Colors.black,
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
          }),
    );
  }
}
