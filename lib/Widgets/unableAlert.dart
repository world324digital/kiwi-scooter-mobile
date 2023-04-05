import 'package:KiwiCity/Helpers/constant.dart';
import 'package:KiwiCity/Helpers/helperUtility.dart';
import 'package:KiwiCity/Widgets/primaryButton.dart';
import 'package:KiwiCity/services/httpService.dart';
import 'package:flutter/material.dart';

Future<void> unableAlert({
  required BuildContext context,
  String? scooterID,
  required String message,
  String? error,
  String? title = "Unable to reserve",
  String? btnTxt = "Got it",
  Function? onTap,
}) async {
  return showModalBottomSheet(
    backgroundColor: Colors.transparent,
    context: context,
    builder: (BuildContext context) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(10),
      alignment: Alignment.bottomCenter,
      elevation: 0,
      child: Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.only(left: 10.0, right: 10, top: 20, bottom: 20),
        height: 250,
        color: Colors.transparent,

        // width: double.infinity,

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.only(bottom: 20, top: 10),
                    child: MyFont.text(
                      title,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      fontFamily: FontStyles.fSemiBold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: MyFont.text(
                      message,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      lineHeight: 1.43,
                      fontFamily: FontStyles.fMedium,
                    ),
                  ),
                  PrimaryButton(
                      horizontalPadding: 0,
                      context: context,
                      onTap: () {
                        if (error != null &&
                            error != "" &&
                            scooterID != null &&
                            scooterID != "" &&
                            onTap == null) {
                          try {
                            // HttpService().sendReportEmail(
                            //     scooterID: scooterID, content: error);
                          } catch (e) {
                            print(e);
                          }
                          Navigator.pop(context, 'OK');
                        } else {
                          Navigator.pop(context, 'OK');
                          return onTap!();
                        }
                      },
                      title: btnTxt)
                ],
              ),
            )
          ],
        ),
      ),
    ),
  );
}
