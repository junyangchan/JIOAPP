import 'package:flutter/material.dart';
import 'package:jio/app/home/models/friend.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:jio/app/home/events/empty_content.dart';
import 'package:jio/app/home/events/invite_list_tile.dart';
import 'package:jio/services/database.dart';

class InvitePlayersList extends StatefulWidget {
  const InvitePlayersList(
      {this.database, this.participants, this.specialInvite,this.callback, this.selectedList});
  final Database database;
  final List<String> participants;
  final Friend specialInvite;
  final callback;
  final List<int> selectedList;

  @override
  _InvitePlayersListState createState() => _InvitePlayersListState();
}

class _InvitePlayersListState extends State<InvitePlayersList> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Friend>>(
        stream: widget.database.userFriendData(widget.database.host, ''),
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasData) {
            List<Friend> friendlist = snapshot.data;
            List<Friend> invitelist = [];
            for(Friend x in friendlist){
              if(!widget.participants.contains(x.uid)){
                invitelist.add(x);
              }
            }
            if (widget.specialInvite!=null ) {
              var add = true;
              for(Friend x in invitelist){
                if(x.uid == widget.specialInvite.uid){
                  add = false;
                  break;
                }
              }
              if(add){invitelist.add(widget.specialInvite);}
            }
            if (invitelist != null) {
              return _buildDropdownList(invitelist);
            }
          } else if (snapshot.hasError) {
            print(snapshot.error);
            return EmptyContent(
              title: 'Something went wrong',
              message: 'Can\'t load items right now',
            );
          }
          return Center(child: LinearProgressIndicator());
        });
  }

  Widget _buildDropdownList(List<Friend> invitelist) {
    List<DropdownMenuItem> items = invitelist.map((Friend value) {
      return DropdownMenuItem<Friend>(
        value: value,
        child: InviteListTile(
            name: value.displayName, photoUrl: value.photoUrl),
      );
    }).toList();
    return new SearchableDropdown.multiple(
      items: items,
      selectedItems: widget.selectedList,
      hint: Text("Invite Players",style: TextStyle(color:Colors.black54),),
      iconEnabledColor: Colors.blueAccent,
      iconDisabledColor: Colors.grey,
      underline: Container(),
      searchHint: "Select any",
      onChanged: (value) {
        List<String> newlist = [];
        for(var i in value){
          newlist.add(invitelist[i].uid);
        }
        widget.callback(newlist,value);
      },
      dialogBox: true,
      isExpanded: true,
    );
  }
}
