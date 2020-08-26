import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class User {
  User(
      {@required this.uid,
      @required this.photoUrl,
      @required this.displayName,
      this.location,
      this.friendlist,
        this.friendRequest,
      this.ratings,
      this.exp,
      this.percent,
      this.chattingWith,
      this.description,
      this.pushToken,
      this.lastSeen,
      this.categoryLevels});

  final Map<String, dynamic> location;
  final String pushToken;
  final String chattingWith;
  final String uid;
  final String photoUrl;
  final String displayName;
  final double ratings;
  final double exp;
  final String description;
  final double percent;
  final List<String> friendlist;
  final List<String> friendRequest;
  final Timestamp lastSeen;
  final List<Map<String, dynamic>> categoryLevels;

  factory User.fromMap(Map<String, dynamic> data) {
    if (data == null) {
      return null;
    }
    final String uid = data['uid'];
    final String photoUrl = data['photoUrl'];
    final String displayName = data['displayName'];
    final List<String> friendlist = List.from(data['friendlist']);
    List<Map<String, dynamic>> categoryLevels = [];
    final String description = data['description'];
    for (var i in data['categoryLevels']) {
      categoryLevels.add(Map.from(i));
    }
    final double ratings = data['ratings'];
    final Timestamp lastSeen = data['lastSeen'];
    final double exp = data['exp'];
    final double percent = data['percent'];
    final String chattingWith = data['chattingWith'];
    final String pushToken = data['pushToken'];
    Map<String, dynamic> location;
    if(data['location']!=null){
       location = Map.from(data['location']);
    }else{
       location = null;
    }
    final List<String> friendRequest = List.from(data['friendRequest']);


    return User(
      uid: uid,
      location: location,
      photoUrl: photoUrl,
      displayName: displayName,
      friendlist: friendlist,
      friendRequest: friendRequest,
      categoryLevels: categoryLevels,
      ratings: ratings,
      exp: exp,
      percent: percent,
      lastSeen: lastSeen,
      chattingWith: chattingWith,
      pushToken: pushToken,
      description: description,
    );
  }

  Map<String, dynamic> userToFriend(User user) {
    return {
      'uid': user.uid,
      'photoUrl': user.photoUrl,
      'displayName': user.displayName,
      'lastSeen': user.lastSeen,
    };
  }

  double percentage(double exp){
    return (exp.remainder(10))/10;
  }

  int expToLevel(double exp){
    return (exp/10).floor();
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'description': description,
      'photoUrl': photoUrl,
      'displayName': displayName,
      'friendlist': friendlist,
      'friendRequest': friendRequest,
      'lastSeen': lastSeen,
      'exp': exp,
      'ratings': ratings,
      'percent': percent,
      'categoryLevels': categoryLevels,
      'chattingWith': chattingWith,
      'pushToken': pushToken,
      'location': location,
    };
  }
}
