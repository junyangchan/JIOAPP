import 'package:flutter/material.dart';
import 'package:jio/common_widgets/custom_raised_button.dart';

class FormSubmitButton extends CustomRaisedButton {
  FormSubmitButton({
    @required String text,
    VoidCallback onPressed,
  }) : super(
          child: Text(
            text,
            style: TextStyle(color: Colors.white, fontSize: 20.0),
          ),
          height: 44.0,
          color: Color.fromRGBO(15, 76, 129, 1),
          borderRadius: 4.0,
          onPressed: onPressed,
        );
}
