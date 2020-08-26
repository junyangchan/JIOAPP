import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jio/app/landing_page.dart';
import 'package:jio/services/auth.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider<AuthBase>(
      create: (context) => Auth(),
      child: MaterialApp(
        title: 'JIO',
        theme: ThemeData(
          primaryColor: Color.fromRGBO(15, 76, 129, 1),
          fontFamily: "Regular",
        ),
        home: LandingPage(),
      ),
    );
  }
}
