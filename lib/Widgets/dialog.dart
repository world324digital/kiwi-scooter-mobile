import 'package:flutter/material.dart';

class Dialogs {
  static Future<void> showLoadingDarkDialog(
      {required BuildContext context,
      required GlobalKey key,
      required String title,
      Color? backgroundColor,
      Color? indicatorColor,
      Color? textColor}) async {
    return showDialog<void>(
        barrierColor: Colors.black.withOpacity(0.1),
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
              onWillPop: () async {
                return false;
              },
              child: SimpleDialog(
                  key: key,
                  backgroundColor:
                      backgroundColor ?? Theme.of(context).primaryColor,
                  // backgroundColor: Colors.transparent,
                  children: <Widget>[
                    Center(
                      child: Column(children: [
                        CircularProgressIndicator(
                          color: indicatorColor ?? Colors.white,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          title,
                          style: TextStyle(
                              fontSize: 16, color: textColor ?? Colors.white),
                        )
                      ]),
                    )
                  ]));
        });
  }

  // Loading Progressbar Dialog
  static Future<void> showProgressBarDialog(
      BuildContext context, GlobalKey key, String title) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new WillPopScope(
              onWillPop: () async {
                return true;
              },
              child: SimpleDialog(
                  key: key,
                  backgroundColor: Colors.white,
                  children: <Widget>[
                    Center(
                      child: Column(children: [
                        CircularProgressIndicator(),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          title,
                          style: TextStyle(color: Colors.black),
                        )
                      ]),
                    )
                  ]));
        });
  }
}
