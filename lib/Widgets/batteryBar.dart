import 'package:flutter/material.dart';

Widget BatteryBar({required int level}) {
  return Container(
    width: 34,
    height: 12,
    decoration: BoxDecoration(
      color: (level > 65)
          ? const Color(0xff34CC34)
          : (level > 35)
              ? Color.fromARGB(255, 144, 209, 144)
              : Colors.red,
      borderRadius: BorderRadius.circular(24),
    ),
  );
}
