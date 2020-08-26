import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jio/common_widgets/imagebutton.dart';

class DateListTile extends StatelessWidget {
  const DateListTile({Key key, @required this.date, this.onTap, this.color,this.selectedDate,this.deviceHeight,this.deviceWidth})
      : super(key: key);
  final String date;
  final VoidCallback onTap;
  final Color color;
  final String selectedDate;
  final deviceHeight;
  final deviceWidth;
  @override
  Widget build(BuildContext context) {
    return ImageButton(
      onPressed: onTap,
      child: Container(
          height: deviceHeight * 0.10,
          child: Center(
              child: date != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          date.split(" ")[0],
                          style: TextStyle(color: selectedDate==date?color:Colors.white, fontSize: 18.0),
                        ),
                        Text(
                          date.split(" ")[1],
                          style: TextStyle(color: selectedDate==date?color:Colors.white, fontSize: 16.0),
                        ),
                      ],
                    )
                  : Text(
                      "All",
                      style: TextStyle(color: selectedDate==date?color:Colors.white, fontSize: 18.0),
                    ))),
    );
  }
}
