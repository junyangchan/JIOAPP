import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';


class UserConversations {
  UserConversations(
      {@required this.id,
        @required this.image,
        @required this.lastMessage,
        @required this.receiverID,
        @required this.type,
        @required this.name,
        @required this.timestamp,
        @required this.unseenCount,
        });
  final String id;
  final String image;
  final String lastMessage;
  final String receiverID;
  final String name;
  final Timestamp timestamp;
  final int unseenCount;
  final String type;

  factory UserConversations.fromMap(Map<String, dynamic> data) {
    if (data == null) {
      return null;
    }

    var _messageType = "text";
    if(data['type']!=null){
      switch(data['type']){
        case "text":
          break;
        case "image":
          _messageType= "image";
          break;
      }
    }
    final String id = data['conversationsID'];
    final String image = data['image'];
    final String lastMessage = data['lastMessage'];
    final String receiverID = data['receiverID'];
    final String name = data['name'];
    final Timestamp timestamp = data['timestamp'] != null ? data["timestamp"]: null;
    final int unseenCount = data['unseenCount'];
    final String type = _messageType;

    return UserConversations(
      id: id,
      name: name,
      image: image,
      lastMessage: lastMessage,
      timestamp: timestamp,
      unseenCount: unseenCount,
      receiverID: receiverID,
      type:type,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'image': image,
      'conversationsID': id,
      'lastMessage':lastMessage,
      'timestamp':timestamp,
      'unseenCount':unseenCount,
      'receiverID':receiverID,
    };
  }
}
