import 'package:flutter/material.dart';

class ImageButton extends StatelessWidget {
  ImageButton({
    @required this.child,
    @required this.onPressed,
    this.height,
  });

  final Widget child;
  final VoidCallback onPressed;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: FlatButton(
            child:Container(),
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onPressed: onPressed,
            color: Color.fromRGBO(12, 12, 12, 0),
          ),
        ),
      ],
    );
  }
}
