import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jio/app/home/models/friend.dart';
import 'package:jio/common_widgets/avatar.dart';

class FriendRequestTile extends StatelessWidget {
  const FriendRequestTile(
      {Key key, @required this.friend, this.onAccept, this.onReject,this.onTap,this.special:false})
      : super(key: key);
  final Friend friend;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onTap;
  final bool special;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top:8.0,bottom: 8.0),
      decoration: BoxDecoration(
       color: Color.fromRGBO(32, 32, 32, 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Flexible(
            flex: 3,
            child: Container(
                  child: ListTile(
                    onTap: onTap,
                    title: Text(friend.displayName,style: TextStyle(color: Colors.white),overflow: TextOverflow.ellipsis,),
                    leading: Avatar(
                      image: friend.photoUrl,
                      radius: 50,
                    ),
                  ),
                ),
          ),
          !special?Flexible(
            flex: 2,
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.close,color: Colors.white,),
                      onPressed: onReject,
                    ),
                    IconButton(
                      icon: Icon(Icons.done,color: Colors.white,),
                      onPressed: onAccept,
                  ),
                ],
              ),
            ),
          ):Container(),
        ],
      ),
    );
  }
}
