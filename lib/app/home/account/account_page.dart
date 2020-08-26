import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:jio/app/home/account/edit_profile_page.dart';
import 'package:jio/app/home/account/friendsPage.dart';
import 'package:jio/app/home/events/empty_content.dart';
import 'package:jio/app/home/models/user.dart';
import 'package:jio/common_widgets/CategoryLevel.dart';
import 'package:jio/common_widgets/avatar.dart';
import 'package:jio/common_widgets/imagebutton.dart';
import 'package:jio/common_widgets/platform_alert_dialog.dart';
import 'package:jio/services/auth.dart';
import 'package:jio/services/database.dart';

class AccountPage extends StatelessWidget {
  Future<void> _signOut(BuildContext context) async {
    try {
      final auth = Provider.of<AuthBase>(context);
      await auth.signOut();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final didRequestSignOut = await PlatformAlertDialog(
      title: 'Logout',
      content: 'Are you sure that you want to logout?',
      cancelActionText: 'Cancel',
      defaultActionText: 'Logout',
    ).show(context);
    if (didRequestSignOut == true) {
      _signOut(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context);
    final _deviceHeight = MediaQuery.of(context).size.height;
    final _deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        title: Center(
          child: Text(
            'My Profile',
            style: TextStyle(
              fontFamily: "KaushanScript",
              color: Colors.white,
              fontSize: 32.0,
            ),
          ),
        ),
      ),
      body: Container(
        constraints: BoxConstraints.expand(),
        decoration: BoxDecoration(
          color: Colors.black,
        ),
        child: StreamBuilder<User>(
          stream: database.userStream(database.host),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final User user = snapshot.data;
              if (user != null) {
                return _build(user, context, _deviceHeight, _deviceWidth);
              } else {
                return EmptyContent();
              }
            } else if (snapshot.hasError) {
              print(snapshot.error);
              return EmptyContent(
                title: 'Something went wrong',
                message: 'Can\'t load items right now',
              );
            }
            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _build(User user, BuildContext context, double _deviceHeight,
      double _deviceWidth) {
    final database = Provider.of<Database>(context);
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: _deviceHeight * 0.02,
          ),
          _buildtitle(user),
          SizedBox(
            height: _deviceHeight * 0.02,
          ),
          _buildAvatar(context, user, _deviceHeight, _deviceWidth),
          SizedBox(
            height: _deviceHeight * 0.02,
          ),
          CategoryLevel(
            context: context,
            database: database,
            user: user,
            title: Container(),
          ),
          SizedBox(
            height: _deviceHeight * 0.02,
          ),
          Text(
            "Level ${user.expToLevel(user.exp)}",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24.0,
              color: Colors.white,
            ),
          ),
          SizedBox(
            height: _deviceHeight * 0.06,
          ),
          _buildsettings(context, user, _deviceHeight, _deviceWidth, database),
        ]);
  }

  Widget _buildsettings(BuildContext context, User user, double _deviceHeight,
      double _deviceWidth, Database database) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Color.fromRGBO(32, 32, 32, 1),
          borderRadius: BorderRadius.circular(10),
        ),
        height: _deviceHeight * 0.15,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Expanded(
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Flexible(
                      child: ImageButton(
                        child: _buildIcon(context, Icons.person, "Edit Profile",
                            Colors.blueAccent, _deviceHeight, _deviceWidth),
                        onPressed: () => EditProfile.show(
                          context,
                          user: user,
                          database: database,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: _deviceWidth * 0.01,
                    ),
                    Flexible(
                      child: ImageButton(
                        child: _buildIcon(
                            context,
                            Icons.people,
                            "Friends",
                            Colors.redAccent,
                            _deviceHeight,
                            _deviceWidth),
                        onPressed: () => FriendPage.show(
                          context,
                          database: database,
                          host: database.host,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: _deviceWidth * 0.01,
                    ),
                    Flexible(
                      child: ImageButton(
                        child: _buildIcon(context, Icons.star, "My Ratings",
                            Colors.yellow, _deviceHeight, _deviceWidth),
                        onPressed: () {},
                      ),
                    ),
                    SizedBox(
                      width: _deviceWidth * 0.01,
                    ),
                    Flexible(
                      child: ImageButton(
                        child: _buildIcon(context, Icons.exit_to_app, "Logout",
                            Colors.white70, _deviceHeight, _deviceWidth),
                        onPressed: () => _confirmSignOut(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context, IconData icon, String text,
      Color color, double _deviceHeight, double _deviceWidth) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Flexible(
              flex: 5,
              child: Icon(
                icon,
                color: color,
                size: _deviceHeight * 0.08,
              )),
          Flexible(
            flex: 3,
            child: Align(
              alignment: Alignment.center,
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, User user, double _deviceHeight,
      double _deviceWidth) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      Align(
        alignment: Alignment.center,
        child: CircularPercentIndicator(
          radius: _deviceHeight * 0.2,
          lineWidth: _deviceHeight * 0.006,
          percent: user.percent,
          progressColor: Colors.red,
          backgroundColor: Colors.grey,
          animation: true,
          circularStrokeCap: CircularStrokeCap.round,
          animationDuration: 1200,
          center: Avatar(
            image: user.photoUrl,
            radius: _deviceHeight * 0.19,
          ),
        ),
      ),
    ]);
  }

  //Widget _buildRatingBar(User user, double _deviceHeight) {
  //  return RatingBar(
  //    itemSize: _deviceHeight * 0.04,
  //    initialRating: user.ratings,
  //    minRating: 1,
  //    direction: Axis.horizontal,
  //    allowHalfRating: true,
  //    itemCount: 5,
  //    itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
  //    itemBuilder: (context, _) => Icon(
  //      Icons.star,
  //      color: Colors.amber,
  //    ),
  //    onRatingUpdate: null,
  //  );
  //}

  Widget _buildtitle(User user) {
    return Text(
      user.displayName,
      style: TextStyle(
        fontSize: 24.0,
        color: Colors.white,
      ),
      textAlign: TextAlign.center,
    );
  }
}
