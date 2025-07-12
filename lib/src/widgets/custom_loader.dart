import 'dart:async';
import 'package:flutter/material.dart';

showLoaderDialog(BuildContext context) {
  AlertDialog alert =  AlertDialog(
    insetPadding: EdgeInsets.symmetric(horizontal: 100),
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10.0))),
    content: SizedBox(
      height: 70,
      // width: 50.w,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Colors.black,
          ),
        ],
      ),
    ),
  );
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
