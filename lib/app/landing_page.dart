import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jio/app/home/home_page.dart';
import 'package:jio/app/home/models/user.dart';
import 'package:jio/app/sign_in/sign_in_page.dart';
import 'package:jio/services/auth.dart';
import 'package:jio/services/database.dart';

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    return StreamBuilder<FirebaseUser>(
        stream: auth.onAuthStateChanged,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            FirebaseUser user = snapshot.data;
            if (user == null) {
              return SignInPage.create(context);
            }
            return FutureProvider<User>.value(
              value: auth.firebaseToUser(user.uid),
              catchError: (_,error) {
                print(error);
                return(error);
              },
              child: Provider<Database>(
                create: (_) => FirestoreDatabase(user: user.uid),
                child: HomePage(database: FirestoreDatabase(user: user.uid),),
              ),
            );
          } else {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        });
  }
}
