import 'package:Move/Helpers/constant.dart';
import 'package:Move/Helpers/helperUtility.dart';
import 'package:Move/Pages/App/app.dart';
import 'package:Move/Pages/App/app_provider.dart';
import 'package:Move/Widgets/menuItem.dart';
import 'package:flutter/material.dart';
import 'package:Move/Pages/PaymentPage/pay_method.dart';
import 'package:provider/provider.dart';
import '../../Routes/routes.dart';
import '../History/ride_history.dart';
import '../../video.dart';
import '../../settings.dart';

class MainMenu extends StatefulWidget {
  final pageIndex;
  MainMenu({
    Key? key,
    this.pageIndex,
  }) : super(key: key);

  State<MainMenu> createState() => _MainMenu();
}

class _MainMenu extends State<MainMenu> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, value, child) {
        return Container(
          width: 286,
          child: Column(
            children: [
              Container(
                height: 212,
                child: Padding(
                  padding: EdgeInsets.only(top: 50.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Container(
                            padding: const EdgeInsets.only(left: 20),
                            child: Row(
                              children: [
                                if (!value.isLogin)
                                  Text(
                                    "Hello, Guest",
                                    style: TextStyle(
                                      fontSize: 24.0,
                                      fontWeight: FontWeight.w500,
                                      color: Color.fromRGBO(52, 204, 52, 1),
                                      fontFamily: 'Montserrat-Medium ',
                                    ),
                                    //textAlign: TextAlign.left,
                                  ),
                                if (value.isLogin)
                                  Text(
                                    value.currentUser.firstName.isEmpty
                                        ? "Hello, ${value.currentUser.email.split("@")[0]}"
                                        : "Hello, ${value.currentUser.firstName}",
                                    style: TextStyle(
                                      fontSize: 24.0,
                                      fontWeight: FontWeight.w500,
                                      color: Color.fromRGBO(52, 204, 52, 1),
                                      fontFamily: 'Montserrat-Bold',
                                    ),
                                    //textAlign: TextAlign.left,
                                  ),
                              ],
                            )),
                      ),
                      Container(
                        width: double.infinity,
                        child: Image.asset(
                          'assets/images/hellonick.png',
                          fit: BoxFit.fill,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              MenuBarItem(
                context: context,
                menu_id: value.index,
                index: 3,
                text: "Ride Now",
                routeName: Routes.RIDE_NOW,
                img:
                    Image.asset(ImageConstants.RIDE_NOW, width: 18, height: 18),
                activeImg: Image.asset(ImageConstants.RIDE_NOW_ACTIVE,
                    width: 18, height: 18),
              ),
              if (value.isLogin)
                MenuBarItem(
                  context: context,
                  menu_id: value.index,
                  index: 1,
                  text: "Ride History",
                  routeName: Routes.RIDE_HISTORY,
                  img: Image.asset(
                    ImageConstants.RIDE_HISTORY,
                    width: 18,
                    height: 18,
                  ),
                  activeImg: Image.asset(
                    ImageConstants.RIDE_HISTORY_ACTIVE,
                    width: 18,
                    height: 18,
                    color: ColorConstants.cPrimaryTitleColor,
                  ),
                ),
              if (value.isLogin)
                MenuBarItem(
                  context: context,
                  menu_id: value.index,
                  index: 2,
                  text: "Payment Methods",
                  routeName: Routes.MANAGE_PAYMETHOD,
                  img: Image.asset(ImageConstants.PAYMENT,
                      width: 18, height: 18),
                  activeImg: Image.asset(ImageConstants.PAYMENT_ACTIVE,
                      width: 18, height: 18),
                ),
              MenuBarItem(
                context: context,
                menu_id: value.index,
                index: 4,
                text: "How to Ride",
                routeName: Routes.HOW_TO_RIDE,
                img: Image.asset(ImageConstants.HOW_TO_RIDE,
                    width: 18, height: 18),
                activeImg: Image.asset(ImageConstants.HOW_TO_RIDE_ACTIVE,
                    width: 18, height: 18),
              ),
              if (value.isLogin)
                MenuBarItem(
                  context: context,
                  menu_id: value.index,
                  index: 5,
                  text: "Terms of Service",
                  routeName: Routes.TERMS_OF_SERVICE,
                  img: Image.asset(ImageConstants.TERMS, width: 18, height: 18),
                  activeImg: Image.asset(ImageConstants.TERMS_ACTIVE,
                      width: 18, height: 18),
                ),
              MenuBarItem(
                context: context,
                menu_id: value.index,
                index: 6,
                text: "Support",
                routeName: Routes.SUPPROT,
                img: Image.asset(ImageConstants.SUPPORT, width: 18, height: 18),
                activeImg: Image.asset(ImageConstants.SUPPORT_ACTIVE,
                    width: 18, height: 18),
              ),
              if (value.isLogin)
                MenuBarItem(
                  context: context,
                  menu_id: value.index,
                  index: 7,
                  text: "Settings",
                  routeName: Routes.SETTINGS,
                  img: Image.asset(ImageConstants.SETTINGS,
                      width: 18, height: 18),
                  activeImg: Image.asset(ImageConstants.SETTINGS_ACTIVE,
                      width: 18, height: 18),
                ),
              if (value.isLogin) Divider(),
              if (value.isLogin)
                MenuBarItem(
                  context: context,
                  menu_id: value.index,
                  index: 0,
                  text: "Sign Out",
                  routeName: Routes.SIGN_OUT,
                  img: Icon(Icons.logout_outlined,
                      color: ColorConstants.cTxtColor2, size: 20),
                  activeImg: Image.asset(ImageConstants.SETTINGS_ACTIVE,
                      width: 18, height: 18),
                ),
            ],
          ),
        );
      },
    );
  }
}
