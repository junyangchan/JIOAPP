import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';


class Message {
  Message({
    this.timestamp,
    this.content,
    this.senderID,
    this.type,
  });
  final String senderID;
  final String content;
  final Timestamp timestamp;
  final String type;
}

class Conversations {
  Conversations({
    @required this.id,
    @required this.members,
    @required this.messages,
    @required this.ownerID,
  });
  final String id;
  final List members;
  final List<Message> messages;
  final String ownerID;

  factory Conversations.fromMap(Map<String, dynamic> data) {
    if (data == null) {
      return null;
    }
    final String id = data['conversationsID'];
    final List<String> members = List.from(data['members']);
    List messages = List.from(data['messages']);

    if (messages != null) {
      messages = messages.map((_m) {
        return Message(
            senderID: _m['senderID'],
            content: _m['content'],
            timestamp: _m['timestamp'],
            type: _m['type']);
      }).toList();
    } else {
      messages = null;
    }

    final String ownerID = data['ownerID'];

    return Conversations(
      id: id,
      members: members,
      messages: messages,
      ownerID: ownerID,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'conversationsID': id,
      'members': members,
      'messages': messages,
      'ownerID': ownerID,
    };
  }
}
