import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instant/instant.dart';
import 'package:jio/app/home/models/user.dart';
import 'package:jio/common_widgets/avatar.dart';
import 'package:timeago/timeago.dart';

class AllUserSearchListTile extends StatelessWidget {
  const AllUserSearchListTile({Key key, @required this.user, this.onTap})
      : super(key: key);
  final User user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    var currentTime = dateTimeByUtcOffset(offset: 8);
    bool _isUserActive = !user.lastSeen.toDate().isBefore(
          currentTime.subtract(Duration(hours: 1)),
        );
    return ListTile(
      onTap: onTap,
      title: Text(
        user.displayName,
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      leading: Avatar(
          image: user.photoUrl,
          radius: 50,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          _isUserActive
              ? Text(
                  "Active",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                )
              : Text(
                  "Last Seen",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
          _isUserActive
              ? Container(
                  height: 12,
                  width: 12,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(100),
                  ),
                )
              : Text(
                  format(user.lastSeen.toDate()),
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
        ],
      ),
    );
  }
}
