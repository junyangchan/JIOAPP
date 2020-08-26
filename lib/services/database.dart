import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jio/common_widgets/platform_exception_alert_dialog.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart';
import 'package:jio/app/home/models/Conversations.dart';
import 'package:jio/app/home/models/friend.dart';
import 'package:jio/app/home/models/user_conversations.dart';
import 'package:jio/app/home/models/event.dart';
import 'package:jio/app/home/models/user.dart';
import 'package:jio/services/Geolocator.dart';
import 'package:jio/services/api_path.dart';
import 'package:jio/services/firestore_service.dart';

abstract class Database {
  Future<void> setEvent(Event event);
  Future<void> deleteEvent(Event event);
  Future<Event> getEvent(String eventID);
  Stream<List<Event>> eventsStream(String _eventName, List<String> _category,int value);
  Stream<Event> eventStream({@required String eventId});
  Stream<List<Event>> pastEventsStream(String uid);
  Stream<Event> pastEventStream({String uid, String eventId});
  Stream<List<Event>> currentEventsStream(String uid);
  Future<void> updateEventParticipants(Event event, String uid, String type);

  Stream<User> userStream(String uid);
  Stream<List<User>> usersStream(String _searchname);
  Stream<List<Friend>> userFriendData(String uid, String _searchname);
  Future<List<Map<String, dynamic>>> getUserData(List<String> uid);
  Future<double> getUserExp(String uid);
  Future<void> changeUsername(User user, String username);
  Future<void> updateHostName(User user, String username);
  Future<void> changeProfilePic(User user, String photoURL);
  Future<void> updateProfilePic(User user, String photoURL);
  Future<void> changeUserBio(User user, String bio);
  String get host;
  Future<void> friendRequest(String friend, User you);
  Future<void> addFriend(String friend, String host);
  Future<void> deleteFriendRequest(String friend, String you);
  Stream<List<Friend>> friendRequestStream(String uid);
  Future<List<User>> matchUser(User host);
  Future<void> jio(String uid, String jioed);
  Future<void> bojio(String uid, String bojioed);
  Future<void> jioRequest(String uid, String jioer, Map<String, dynamic> data);
  Stream<List<Friend>> jioRequestlist(String uid);
  Future<void> deleteJioedRequest(String you, String friend);
  Future<List<String>> jiolist(String uid);
  Future<List<String>> bojiolist(String uid);
  Future<List<Map<String, dynamic>>> categoryList();

  Stream<List<UserConversations>> conversationStream(String uid);
  Stream<Conversations> getConversation(String _conversationID, String type);
  Future<void> sendMessage(
      String _conversationID, Message _message, String type);
  Future<String> uploadMediaMessage(String _uid, File _file, String type);
  Future<File> getImage();
  Future<void> deleteImage(String _uid, String imageurl);
  Future<String> createOrGetConversation(
      BuildContext context, String _currentID, String _recepientID);
  Future<void> createGroupConversation(BuildContext context, Event _event);
  Future<void> updateChattingWith(String uid, String receiverID);
  Future<void> updatePushToken(String uid, String token);
  Future<void> createInviteList(
      List<String> inviteList, String eventID, String userID);
}

String documentIdFromCurrentDate() =>
    Timestamp.now().millisecondsSinceEpoch.toString();

class ChatData {
  const ChatData(this.conversations, this.user);
  final List<UserConversations> conversations;
  final User user;
}

class FirestoreDatabase implements Database {
  FirestoreDatabase({@required this.user}) : assert(user != null);
  final String user;
  final _service = FirestoreService.instance;
  final _firestore = Firestore.instance;
  final StorageReference _firebaseStorageRef = FirebaseStorage.instance.ref();

  String get host {
    return user;
  }

  @override
  Future<void> setEvent(Event event) async {
    await _service.setData(
      path: APIPath.eventOngoing(event.id),
      data: event.toMap(),
    );
    await _service.setData(
        path: APIPath.eventCurrent(event.hostid, event.id),
        data: event.toMap());
  }

  @override
  Future<void> deleteEvent(Event event) async {
    // delete event in overall page
    await _firestore
        .collection(APIPath.eventInviteList(event.id))
        .getDocuments()
        .then((value) => value.documents.forEach((element) {
              element.reference.delete();
            }));
    await _firestore.document(APIPath.groupConversation(event.id)).delete();
    await _service.deleteData(path: APIPath.eventOngoing(event.id));
    // delete event in own page
    for (int x = 0; x < event.participants.length; x++) {
      await _service.deleteData(
          path: APIPath.eventCurrent(event.participants[x], event.id));
    }
  }

  @override
  Stream<User> userStream(String uid) => _service.documentStream(
        path: APIPath.user(uid),
        builder: (data, id) => User.fromMap(data),
      );

  @override
  Stream<List<User>> usersStream(String _searchname) {
    var ref = _firestore
        .collection(APIPath.users())
        .where('displayName', isGreaterThanOrEqualTo: _searchname)
        .where('displayName', isLessThan: _searchname + 'z');
    return ref.getDocuments().asStream().map((event) {
      return event.documents.map((e) {
        return User.fromMap(e.data);
      }).toList();
    });
  }

  @override
  Future<List<User>> matchUser(User host) async {
    List<String> visited = [];
    await _firestore.collection(APIPath.userjios(host.uid)).getDocuments().then(
          (value) => value.documents.forEach(
            (element) {
              visited.add(element.documentID);
            },
          ),
        );
    await _firestore
        .collection(APIPath.userbojios(host.uid))
        .getDocuments()
        .then(
          (value) => value.documents.forEach(
            (element) {
              visited.add(element.documentID);
            },
          ),
        );
    var ref = _firestore
        .collection(APIPath.users())
        .where('lastSeen',
            isGreaterThanOrEqualTo: DateTime.now().subtract(Duration(hours: 4)))
        .orderBy('lastSeen', descending: true);
    //find similar users model
    List<User> users = await ref.getDocuments().then((users) {
      return users.documents.map((e) {
        return User.fromMap(e.data);
      }).toList();
    });
    visited.add(host.uid);
    users.removeWhere((element) => visited.contains(element.uid));
    List<User> result = [];
    if(host.location == null){
      await loadPosition();
    }
    for (User user in users) {
      print(user.location);
      print(host.location);
      var distance = await Geolocation.distanceFromHost(host.location['lat'],
          host.location['long'], user.location['lat'], user.location['long']);
      if (distance < 10000) {
        result.add(user);
      }
    }
    return result;
  }

  Future<void> loadPosition() async {
    Position _position = await Geolocation.getCurrentLocation();
    _firestore.document(APIPath.user(host)).updateData({
      'location': {'lat': _position.latitude, 'long': _position.longitude}
    });
  }

  @override
  Stream<Event> eventStream({@required String eventId}) =>
      _service.documentStream(
        path: APIPath.eventOngoing(eventId),
        builder: (data, documentId) => Event.fromMap(data, documentId),
      );

  @override
  Stream<List<Event>> eventsStream(String _eventName, List<String> _category,int value) {
    var ref =_category.isNotEmpty
        ?  _firestore
            .collection(APIPath.eventsOngoing())
            .where('category.name', whereIn: _category)
            .where('name', isGreaterThanOrEqualTo: _eventName)
            .where('name', isLessThan: _eventName + 'z').orderBy('name').orderBy("startDate",descending: false).limit(value)
        : _firestore
            .collection(APIPath.eventsOngoing())
            .where('name', isGreaterThanOrEqualTo: _eventName)
            .where('name', isLessThan: _eventName + 'z').orderBy('name').orderBy("startDate",descending: false).limit(value);
    return ref.getDocuments().asStream().map((event) {
      return event.documents.map((e) {
        return Event.fromMap(e.data,e.documentID);
      }).toList();
    });
  }

  @override
  Stream<List<Event>> pastEventsStream(String uid){
    var ref = _firestore.collection(APIPath.eventsPast(uid)).orderBy('startDate',descending: true);
    return ref.getDocuments().asStream().map((event) {
      return event.documents.map((e) {
        return Event.fromMap(e.data,e.documentID);
      }).toList();
    });
  }

  @override
  Stream<Conversations> getConversation(String _conversationID, String type) =>
      _service.documentStream(
        path: type == "Group"
            ? APIPath.groupConversation(_conversationID)
            : APIPath.conversations(_conversationID),
        builder: (data, documentID) => Conversations.fromMap(data),
      );

  @override
  Stream<Event> pastEventStream({String uid, String eventId}) =>
      _service.documentStream(
        path: APIPath.eventPast(uid, eventId),
        builder: (data, documentId) => Event.fromMap(data, documentId),
      );
  @override
  Stream<List<Event>> currentEventsStream(String uid){
    var ref = _firestore.collection(APIPath.eventsCurrent(uid)).orderBy('startDate',descending: false);
    return ref.getDocuments().asStream().map((event) {
      return event.documents.map((e) {
        return Event.fromMap(e.data,e.documentID);
      }).toList();
    });
  }

  @override
  Future<void> updateHostName(User user, String username) async {
    //update profile username in overall events page
    _firestore
        .collection(APIPath.eventsOngoing())
        .where('hostid', isEqualTo: user.uid)
        .getDocuments()
        .then((data) {
      data.documents.forEach((element) {
        element.reference
            .updateData({"hostDisplayName": username ?? user.displayName});
        for (int i = 0; i < element.data['participants'].length; i++) {
          _firestore
              .document(APIPath.eventCurrent(
                  element.data['participants'][i], element.documentID))
              .updateData({"hostDisplayName": username ?? user.displayName});
        }
      });
    });
    //update profile username in overall events page
    _firestore
        .collection(APIPath.eventsPast(user.uid))
        .getDocuments()
        .then((data) {
      data.documents.forEach((element) {
        for (int i = 0; i < element.data['participants'].length; i++) {
          _firestore
              .document(APIPath.eventPast(
                  element.data['participants'][i], element.documentID))
              .updateData({"hostDisplayName": username ?? user.displayName});
        }
      });
    });

    //update all conversations page
    List<String> userID = [];
    var result = await _firestore
        .collection(APIPath.profileconversations(user.uid))
        .getDocuments();
    result.documents.forEach((data) {
      userID.add(data.documentID);
    });
    for (var x in userID) {
      _firestore
          .document(APIPath.personalconversation(x, user.uid))
          .updateData({'name': username});
    }
    //update all friends document
    List<String> friendsID = [];
    var friendsList = await _firestore
        .collection(APIPath.userfriendlist(user.uid))
        .getDocuments();
    friendsList.documents.forEach((data) {
      friendsID.add(data.documentID);
    });
    for (var x in friendsID) {
      _firestore
          .document(APIPath.userfriend(x, user.uid))
          .updateData({'displayName': username});
    }
  }

  @override
  Future<void> changeUsername(User user, String username) async {
    //update profile username
    await _firestore
        .document(APIPath.user(user.uid))
        .updateData({'displayName': username ?? user.displayName});
  }

  @override
  Future<void> changeUserBio(User user, String bio) async {
    //update profile username
    await _firestore
        .document(APIPath.user(user.uid))
        .updateData({'description': bio ?? user.description});
  }

  @override
  Future<void> updateEventParticipants(
      Event event, String uid, String type) async {
    //update event participants
    double exp = await getUserExp(uid);
    if (type == "add") {
      event.participants.add(uid);
      event.averageLevel = (event.averageLevel*(event.participants.length-1) + exp)/event.participants.length;
    } else {
      event.participants.remove(uid);
      event.averageLevel = (event.averageLevel*(event.participants.length+1) - exp)/event.participants.length;
    }
    //for overall events page
    await _firestore
        .document(APIPath.eventOngoing(event.id))
        .updateData({'participants': event.participants});
    //for individual event page
    await _firestore
        .document(APIPath.eventCurrent(event.hostid, event.id))
        .updateData({'participants': event.participants});
    //add event to current user events
    type == "add"
        ? await _service.setData(
            path: APIPath.eventCurrent(uid, event.id), data: event.toMap())
        : await _service.deleteData(path: APIPath.eventCurrent(uid, event.id));
  }

  @override
  Future<void> changeProfilePic(User user, String photoURL) async =>
      await _firestore
          .document(APIPath.user(user.uid))
          .updateData({'photoUrl': photoURL ?? user.photoUrl});

  @override
  Future<void> updateProfilePic(User user, String photoURL) async {
    //update overall events page
    _firestore
        .collection(APIPath.eventsOngoing())
        .where('hostid', isEqualTo: user.uid)
        .getDocuments()
        .then((data) {
      data.documents.forEach((element) {
        element.reference
            .updateData({"hostPhotoURL": photoURL ?? user.photoUrl});
        //update own events page(current)
        print(element.data);
        for (int i = 0; i < element.data['participants'].length; i++) {
          _firestore
              .document(APIPath.eventCurrent(
                  element.data['participants'][i], element.documentID))
              .updateData({"hostPhotoURL": photoURL ?? user.photoUrl});
        }
      });
    });
    //update own events page(past)
    _firestore
        .collection(APIPath.eventsPast(user.uid))
        .getDocuments()
        .then((data) {
      data.documents.forEach((element) {
        for (int i = 0; i < element.data['participants'].length; i++) {
          _firestore
              .document(APIPath.eventPast(
                  element.data['participants'][i], element.documentID))
              .updateData({"hostPhotoURL": photoURL ?? user.photoUrl});
        }
      });
    });
    //update all conversations page
    List<String> userID = [];
    var result = await _firestore
        .collection(APIPath.profileconversations(user.uid))
        .getDocuments();
    result.documents.forEach((data) {
      userID.add(data.documentID);
    });
    for (var x in userID) {
      _firestore
          .document(APIPath.personalconversation(x, user.uid))
          .updateData({'image': photoURL});
    }

    //update all friends document
    List<String> friendsID = [];
    var friendsList = await _firestore
        .collection(APIPath.userfriendlist(user.uid))
        .getDocuments();
    friendsList.documents.forEach((data) {
      friendsID.add(data.documentID);
    });
    for (var x in friendsID) {
      _firestore
          .document(APIPath.userfriend(x, user.uid))
          .updateData({'photoUrl': photoURL});
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getUserData(List<String> uid) async {
    List<Map<String, dynamic>> initial = [];
    for (int i = 0; i < uid.length; i++) {
      await _firestore.document(APIPath.user(uid[i])).get().then((value) {
        initial.add({
          "displayName": value.data['displayName'],
          "photoUrl": value.data['photoUrl'],
          "uid": value.data['uid'],
        });
      });
    }
    return initial;
  }

  @override
  Stream<List<Friend>> userFriendData(String uid, String _searchname) {
    var ref = _firestore
        .collection(APIPath.userfriendlist(uid))
        .where('displayName', isGreaterThanOrEqualTo: _searchname)
        .where('displayName', isLessThan: _searchname + 'z');
    return ref.getDocuments().asStream().map((event) {
      return event.documents.map((e) {
        return Friend.fromMap(e.data);
      }).toList();
    });
  }

  @override
  Stream<List<UserConversations>> conversationStream(String uid) =>
      _service.collectionStream(
        path: APIPath.profileconversations(uid),
        builder: (data, documentID) => UserConversations.fromMap(data),
      );

  @override
  Future<void> sendMessage(
      String _conversationID, Message _message, String type) async {
    String docRef = APIPath.conversations(_conversationID);
    if (type == "Group") {
      docRef = APIPath.groupConversation(_conversationID);
    }
    _firestore.document(docRef).updateData({
      "messages": FieldValue.arrayUnion(
        [
          {
            "content": _message.content,
            "senderID": _message.senderID,
            "timestamp": _message.timestamp,
            "type": _message.type,
          },
        ],
      ),
    });
  }

  Future<File> getImage() async {
    ImagePicker picker = ImagePicker();
    var image = await picker.getImage(source: ImageSource.gallery);
    return File(image.path);
  }

  Future<String> uploadMediaMessage(
      String _uid, File _file, String type) async {
    String fileName = basename(_file.path);
    var storageRef =
        _firebaseStorageRef.child(_uid).child(type).child(fileName);
    StorageUploadTask uploadTask = storageRef.putFile(_file);
    await uploadTask.onComplete;
    var url = await storageRef.getDownloadURL();
    return url;
  }

  Future<void> deleteImage(String _uid, String imageurl) async {
    var fileUrl = Uri.decodeFull(basename(imageurl))
        .replaceAll(new RegExp(r'(\?alt).*'), '');
    var storageRef = _firebaseStorageRef.child(fileUrl);
    await storageRef.delete();
  }

  @override
  Future<double> getUserExp(String uid) async{
    return _firestore.document(APIPath.user(uid)).get().then((value) => value.data['exp']);
  }
  @override
  Future<String> createOrGetConversation(
      BuildContext context, String _currentID, String _recepientID) async {
    var ref = _firestore.collection(APIPath.allConversations());
    var _userConversationRef =
        _firestore.collection(APIPath.profileconversations(_currentID));
    try {
      var conversation =
          await _userConversationRef.document(_recepientID).get();
      if (conversation.data != null) {
        return conversation.data['conversationsID'];
      }
      var _conversationRef = ref.document();
      await _conversationRef.setData(
        {
          "members": [_currentID, _recepientID],
          "ownerID": _currentID,
          "messages": [],
          "conversationsID": _conversationRef.documentID,
        },
      );
      return _conversationRef.documentID;
    } on PlatformException catch (e) {
      PlatformExceptionAlertDialog(
        title: "Backend error",
        exception: e,
      ).show(context);
    }
    return null;
  }

  @override
  Future<void> createGroupConversation(
      BuildContext context, Event _event) async {
    try {
      var _conversationRef =
          _firestore.document(APIPath.groupConversation(_event.id));
      await _conversationRef.setData(
        {
          "members": _event.participants,
          "ownerID": _event.hostid,
          "messages": [],
          "conversationsID": _event.id,
        },
      );
    } on PlatformException catch (e) {
      PlatformExceptionAlertDialog(
        title: "Backend error",
        exception: e,
      ).show(context);
    }
  }

  @override
  Future<void> updateChattingWith(String uid, String receiverID) async {
    await _firestore
        .collection('users')
        .document(uid)
        .updateData({'chattingWith': receiverID});
  }

  @override
  Future<void> updatePushToken(String uid, String token) async {
    await _firestore
        .collection('users')
        .document(uid)
        .updateData({'pushToken': token});
  }

  @override
  Future<void> createInviteList(
      List<String> invitelist, String eventID, String userId) async {
    await _firestore
        .collection(APIPath.eventInviteList(eventID))
        .add({'inviteList': invitelist, "userFrom": userId});
  }

  @override
  Future<Event> getEvent(String eventID) async {
    Event event;
    await _firestore
        .document(APIPath.eventOngoing(eventID))
        .get()
        .then((value) {
      event = Event.fromMap(value.data, eventID);
    });
    return event;
  }

  @override
  Future<void> friendRequest(String friend, User you) async {
    await _service.setData(
        path: APIPath.userfriendRequest(friend, you.uid),
        data: you.userToFriend(you));
    List<String> newList;
    await _firestore
        .document(APIPath.user(you.uid))
        .get()
        .then((value) => newList = List.from(value.data['friendRequest']));
    newList.add(friend);
    await _firestore
        .document(APIPath.user(you.uid))
        .updateData({'friendRequest': newList});
  }



  @override
  Stream<List<Friend>> friendRequestStream(String uid) =>
      _service.collectionStream(
        path: APIPath.userfriendRequestlist(uid),
        builder: (data, documentId) => Friend.fromMap(data),
      );

  @override
  Future<void> addFriend(String friend, String host) async {
    //get friend data
    List<Map<String, dynamic>> friendData = await getUserData([friend]);
    //get own data
    List<Map<String, dynamic>> ownData = await getUserData([host]);
    friendData[0].addAll({'AcceptedByMe': true});
    ownData[0].addAll({'AcceptedByMe': false});
    //add friend
    await _service.setData(
        path: APIPath.userfriend(host, friend), data: friendData[0]);
    List<String> newList;
    await _firestore
        .document(APIPath.user(host))
        .get()
        .then((value) => newList = List.from(value.data['friendlist']));
    newList.add(friend);
    await _firestore
        .document(APIPath.user(host))
        .updateData({'friendlist': newList});
    //add yourself for friend
    await _service.setData(
        path: APIPath.userfriend(friend, host), data: ownData[0]);
    await _firestore
        .document(APIPath.user(friend))
        .get()
        .then((value) => newList = List.from(value.data['friendlist']));
    newList.add(host);
    await _firestore
        .document(APIPath.user(friend))
        .updateData({'friendlist': newList});

    await deleteFriendRequest(friend, host);
  }

  @override
  Future<void> deleteFriendRequest(String friend, String you) async {
    await _service.deleteData(path: APIPath.userfriendRequest(you, friend));
    List<String> newList;
    await _firestore
        .document(APIPath.user(friend))
        .get()
        .then((value) => newList = List.from(value.data['friendRequest']));
    newList.remove(you);
    await _firestore
        .document(APIPath.user(friend))
        .updateData({'friendRequest': newList});
  }

  @override
  Future<void> deleteJioedRequest(String you, String friend) async {
    await _service.deleteData(path: APIPath.userjioRequest(you, friend));
  }

  @override
  Future<void> jio(String uid, String jioed) async {
    await _service
        .setData(path: APIPath.userjioed(uid, jioed), data: {'uid': jioed});
  }

  @override
  Future<void> jioRequest(
      String uid, String jioer, Map<String, dynamic> data) async {
    await _service.setData(
        path: APIPath.userjioRequest(uid, jioer), data: data);
  }

  @override
  Stream<List<Friend>> jioRequestlist(String uid) => _service.collectionStream(
      path: APIPath.userjioRequestlist(uid),
      builder: (data, documentID) => Friend.fromMap(data));

  @override
  Future<void> bojio(String uid, String bojioed) async {
    await _service.setData(
        path: APIPath.userbojioed(uid, bojioed), data: {'uid': bojioed});
  }

  @override
  Future<List<String>> jiolist(String uid) async {
    List<String> jiolist = [];
    await _firestore
        .collection(APIPath.userjios(uid))
        .getDocuments()
        .then((value) => value.documents.forEach((element) {
              jiolist.add(element.documentID);
            }));
    return jiolist;
  }

  @override
  Future<List<String>> bojiolist(String uid) async {
    List<String> bojiolist = [];
    await _firestore
        .collection(APIPath.userbojios(uid))
        .getDocuments()
        .then((value) => value.documents.forEach((element) {
              bojiolist.add(element.documentID);
            }));
    return bojiolist;
  }

  @override
  Future<List<Map<String, dynamic>>> categoryList() async {
    List<Map<String, dynamic>> result = [];
    await _firestore
        .collection(APIPath.categoryList())
        .getDocuments()
        .then((value) => value.documents.forEach((element) {
              result.add(element.data);
            }));
    return result;
  }
}
