import 'package:flutter/material.dart';

class Friend {
  Friend(
      {@required this.uid,
        @required this.photoUrl,
        @required this.displayName});

  final String uid;
  final String photoUrl;
  final String displayName;

  factory Friend.fromMap(Map<String, dynamic> data) {
    if (data == null) {
      return null;
    }
    final String uid = data['uid'];
    final String photoUrl = data['photoUrl'];
    final String displayName = data['displayName'];

    return Friend(
      uid: uid,
      photoUrl: photoUrl,
      displayName: displayName,
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'photoUrl': photoUrl,
      'displayName': displayName,
    };
  }
}