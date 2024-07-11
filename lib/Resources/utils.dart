import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'constants.dart';
class Utils {

  static void fieldFocusChange(BuildContext context, FocusNode current,
      FocusNode nextFocus) {
    current.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  static toastMessage(String message) {
    Fluttertoast.showToast(
        msg: message,
        textColor: kPrimaryLightColor,
        backgroundColor: kPrimaryTextColor,
        gravity: ToastGravity.BOTTOM,
        fontSize: 12,
        toastLength: Toast.LENGTH_LONG,
    );
  }
  static showSnackBar({required BuildContext context, required String message}) {
    SnackBar snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
  }

