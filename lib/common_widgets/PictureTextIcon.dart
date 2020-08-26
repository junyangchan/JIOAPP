import 'package:flutter/material.dart';
import 'package:jio/common_widgets/avatar.dart';
import 'package:jio/services/database.dart';

class PictureText extends StatelessWidget {
  const PictureText(
      {@required this.title,
      @required this.data,
      @required this.text,
        this.database,
      this.category});
  final List<Map<String, dynamic>> data;
  final Widget title;
  final String text;
  final bool category;
  final Database database;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        title,
        SizedBox(height: category ? 0 : 10.0),
        Container(
          height: 80.0,
          child: ListView.builder(
              shrinkWrap: category,
              itemCount: data.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return buildPictureText(
                    context,
                    category?data[index]['category']['logo']:data[index]['photoUrl'],
                    data[index][text]);
              }),
        ),
      ],
    );
  }

  Widget buildPictureText(
      BuildContext context, dynamic picture, dynamic title) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
          Avatar(
            image: picture,
            radius: category ? 40 : 50,
          ),
        Container(
          width: 80,
          child: Center(
            child: Text(
              category ? title.toString() : "",
              style: TextStyle(
                  fontSize: 12.0,
                  color: Colors.white),
            ),
          ),
        )
      ],
    );
  }
}
