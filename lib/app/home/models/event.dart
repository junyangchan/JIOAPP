import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class Event {
  Event(
      {@required this.id,
      @required this.name,
      @required this.location,
      @required this.hostid,
      @required this.startDate,
      @required this.category,
      @required this.hostPhotoURL,
      @required this.hostDisplayName,
      @required this.description,
      @required this.participants,
      @required this.averageLevel});

  final String id;
  final String name;
  final String location;
  final Map<String,dynamic> category;
  final String hostid;
  final List<String> participants;
  double averageLevel;
  final int startDate;
  final String hostPhotoURL;
  final String hostDisplayName;
  final String description;

  factory Event.fromMap(Map<String, dynamic> data, String documentId) {
    if (data == null) {
      return null;
    }
    final String name = data['name'];
    final String location = data['location'];
    final String hostid = data['hostid'];
    final String hostPhotoURL = data['hostPhotoURL'];
    final String hostDisplayName = data['hostDisplayName'];
    final Map<String,dynamic> category = Map.from(data['category']);
    final List<String> participants = List.from(data['participants']);
    final int startDate = data["startDate"];
    final String description = data['description'];
    final double averageLevel = data['averageLevel'];

    return Event(
      id: documentId,
      name: name,
      location: location,
      hostid: hostid,
      category: category,
      participants: participants,
      startDate: startDate,
      hostDisplayName: hostDisplayName,
      hostPhotoURL: hostPhotoURL,
      description: description,
      averageLevel: averageLevel
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'location': location,
      'hostid': hostid,
      'category': category,
      'participants': participants,
      'startDate': startDate,
      'hostPhotoURL': hostPhotoURL,
      'description': description,
      'hostDisplayName': hostDisplayName,
      'averageLevel':averageLevel
    };
  }

  static Map<int, String> monthsInYear = {
    1: "Jan",
    2: "Feb",
    3: "March",
    4: "April",
    5: "May",
    6: "June",
    7: "July",
    8: "Aug",
    9: "Sept",
    10: "Oct",
    11: "Nov",
    12: "Dec",
  };

  static String convertDatetoStringDate(dynamic startDate) {
    DateTime sDate;
    if(startDate is int){
      sDate = DateTime.fromMillisecondsSinceEpoch(startDate);
    }else{
      sDate = startDate;
    }
    String startDay = sDate.day.toString();
    String startMonth = monthsInYear[sDate.month];
    return "$startDay $startMonth";
  }

  static String convertDatetoString(int startDate) {
    DateTime sDate = DateTime.fromMillisecondsSinceEpoch(startDate);
    String startTimehour = sDate.hour.toString().split("").length == 1
        ? "0${sDate.hour.toString()}"
        : sDate.hour.toString();
    String startTimeminute = sDate.minute.toString().split("").length == 1
        ? "0${sDate.minute.toString()}"
        : sDate.minute.toString();
    String startDay = sDate.day.toString();
    String startMonth = monthsInYear[sDate.month];
    return "$startTimehour$startTimeminute, $startDay $startMonth";
  }
}

class Category{
  Category({
    @required this.name,
    @required this.logo,
    @required this.event,
      });
  final String name;
  final String logo;
  final String event;


}