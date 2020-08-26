import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jio/app/home/models/friend.dart';
import 'package:jio/common_widgets/avatar.dart';

class FriendsSearchListTile extends StatelessWidget {
  const FriendsSearchListTile({Key key, @required this.friend, this.onTap})
      : super(key: key);
  final Friend friend;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(
        friend.displayName,
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      leading: Avatar(
          image: friend.photoUrl,
          radius: 50,
        ),
    );
  }
}
