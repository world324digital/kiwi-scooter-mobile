import 'package:KiwiCity/Helpers/constant.dart';
import 'package:flutter/material.dart';

Widget PrimaryButton({
  required BuildContext context,
  required Function onTap,
  String? title,
  Widget? icon,
  double? horizontalPadding = 14,
  double? verticalPadding = 4,
  double? height,
  double? width,
  EdgeInsets? margin,
  Color? color = ColorConstants.cPrimaryBtnColor,
  String? fontFamily,
  BorderRadius? borderRadius,
  Color? txtColor = Colors.white,
  Color? borderColor = ColorConstants.cPrimaryBtnColor,
}) {
  return Container(
    margin: margin ?? EdgeInsets.all(0),
    width: width ?? double.infinity,
    height: height ?? MediaQuery.of(context).size.height * 0.075,
    padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding ?? 14, vertical: verticalPadding ?? 4),
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? ColorConstants.cPrimaryBtnColor,
        textStyle: TextStyle(
          color: Colors.white,
          fontFamily: fontFamily ?? 'Montserrat-SemiBold',
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(16),
          side:
              BorderSide(color: borderColor ?? ColorConstants.cPrimaryBtnColor),
        ),
      ),
      onPressed: () {
        return onTap();
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) icon,
          if (icon != null)
            SizedBox(
              width: 10,
            ),
          if (title != null)
            Text(
              title,
              style: TextStyle(
                color: txtColor,
                fontSize: 16,
                fontFamily: fontFamily ?? 'Montserrat-SemiBold',
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            )
        ],
      ),
    ),
  );
}
