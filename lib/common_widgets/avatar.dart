import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  const Avatar({Key key, @required this.image, @required this.radius})
      : super(key: key);
  final dynamic image;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: radius,
      width: radius,
      decoration: new BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(width: 2.0,color: Colors.white),
          image: new DecorationImage(image: _image(image), fit: BoxFit.fill)),
    );
  }

  ImageProvider _image(image) {
    if (image != null) {
      if (image is String) {
        return CachedNetworkImageProvider(image);
      } else {
        return FileImage(
          image,
        );
      }
    }
    return AssetImage(
      "images/placeholder.png",
    );
  }
}
