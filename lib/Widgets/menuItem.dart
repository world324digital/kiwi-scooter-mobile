import 'package:Move/Helpers/constant.dart';
import 'package:Move/Routes/routes.dart';
import 'package:Move/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Helpers/helperUtility.dart';
import '../Pages/App/app_provider.dart';

Widget MenuBarItem({
  required BuildContext context,
  required int menu_id,
  required int index,
  required img,
  required activeImg,
  required String text,
  required String routeName,
}) {
  var appContext = AppProvider.of(context);
  return (menu_id == index)
      ? Container(
          height: 50,
          margin: const EdgeInsets.only(left: 16, right: 16),
          padding: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Color(0xFFE5F9E0),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Color.fromRGBO(229, 249, 224, 1),
            ),
          ),
          child: ListTile(
            onTap: () async {
              switch (routeName) {
                case Routes.RIDE_NOW:
                  appContext.setIndex(index);
                  bool progress = appContext.isProgress;
                  progress
                      ? Navigator.of(context).pop()
                      : HelperUtility.goPage(
                          context: context,
                          routeName: Routes.HOME,
                          arg: {"viaPayment": false});
                  break;
                case Routes.SIGN_OUT:
                  FirebaseService service = FirebaseService();
                  try {
                    await service.signOut();
                  } catch (e) {
                    print(e);
                  }
                  AppProvider.of(context).setLogined(false);
                  AppProvider.of(context).setLoginType(LoginType.NONE);

                  HelperUtility.goPageAllClear(
                      context: context, routeName: Routes.HOME);
                  break;
                case Routes.SUPPROT:
                  print("SSSSSSSSSSSSSSS");
                  appContext.setIndex(index);
                  await launchUrl(Uri.parse(URLS.SUPPORTT_URL));
                  break;
                case Routes.TERMS_OF_SERVICE:
                  appContext.setIndex(index);
                  HelperUtility.goPage(
                      context: context,
                      routeName: Routes.TERMS_OF_SERVICE,
                      arg: {"viaPayment": false});
                  break;

                default:
                  appContext.setIndex(index);
                  HelperUtility.goPage(context: context, routeName: routeName);
                  break;
              }
            },
            leading:
                Container(padding: EdgeInsets.only(left: 10), child: activeImg),
            title: Text(
              text,
              style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Montserrat-SemiBold',
                  color: Colors.black),
            ),
          ),
        )
      : Container(
          height: 50,
          margin: const EdgeInsets.only(left: 16, right: 16),
          padding: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            onTap: () async {
              switch (routeName) {
                case Routes.RIDE_NOW:
                  appContext.setIndex(index);
                  bool progress = appContext.isProgress;

                  progress
                      ? Navigator.of(context).pop()
                      : HelperUtility.goPage(
                          context: context,
                          routeName: Routes.HOME,
                          arg: {"viaPayment": false});
                  break;

                case Routes.SIGN_OUT:
                  FirebaseService service = FirebaseService();
                  try {
                    await service.signOut();
                  } catch (e) {
                    print(e);
                  }
                  AppProvider.of(context).setLogined(false);
                  AppProvider.of(context).setLoginType(LoginType.NONE);
                  Navigator.of(context).pop();

                  // HelperUtility.goPageAllClear(
                  //     context: context, routeName: Routes.HOME);
                  break;
                case Routes.SUPPROT:
                  appContext.setIndex(index);
                  await launchUrl(Uri.parse(URLS.SUPPORTT_URL));
                  break;
                case Routes.TERMS_OF_SERVICE:
                  appContext.setIndex(index);
                  HelperUtility.goPage(
                      context: context,
                      routeName: Routes.TERMS_OF_SERVICE,
                      arg: {"viaPayment": false});
                  break;

                default:
                  appContext.setIndex(index);
                  HelperUtility.goPage(context: context, routeName: routeName);
                  break;
              }
            },
            leading: Container(
              padding: EdgeInsets.only(left: 10),
              child: img,
            ),
            title: Container(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Montserrat-SemiBold',
                  color: Color.fromRGBO(102, 102, 102, 1),
                ),
              ),
            ),
          ),
        );
}
