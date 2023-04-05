import 'package:KiwiCity/Helpers/constant.dart';
import 'package:flutter/material.dart';

Widget TermsTitle({
  required String text,
}) {
  return Text(
    text,
    textAlign: TextAlign.center,
    style: TextStyle(
        color: Color(0xff0B0B0B),
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: FontStyles.fSemiBold,
        height: 1),
  );
}

Widget TermsContent({
  required String text,
}) {
  return Container(
    alignment: Alignment.center,
    padding: const EdgeInsets.only(top: 10, left: 50, right: 30),
    child: Text(
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xff666666),
          fontSize: 14,
          fontFamily: FontStyles.fMedium,
          height: 1.6,
        ),
        text),
  );
}
