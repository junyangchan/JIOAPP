import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jio/common_widgets/avatar.dart';

class InviteListTile extends StatelessWidget {
  const InviteListTile({Key key, @required this.name, @required this.photoUrl})
      : super(key: key);
  final String name;
  final dynamic photoUrl;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Avatar(
            image: photoUrl,
            radius: 40,
          ),
        ),
        Text(
          name,
          style: TextStyle(fontFamily: "PermanentMarker"),
        ),
      ],
    );
  }
}
