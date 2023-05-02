import 'package:KiwiCity/Pages/AllowPermissionPage/allow_permission_page.dart';
import 'package:KiwiCity/Pages/AuthPages/SignUp.dart';

import 'package:KiwiCity/Pages/AuthPages/forget_password.dart';

import 'package:KiwiCity/Pages/AuthPages/login.dart';
import 'package:KiwiCity/Pages/AuthPages/login_input_page.dart';
import 'package:KiwiCity/Pages/History/ride_detail.dart';
import 'package:KiwiCity/Pages/History/ride_history.dart';
import 'package:KiwiCity/Pages/HomePage/home_page.dart';
import 'package:KiwiCity/Pages/PaymentPage/mangae_paymethod.dart';
import 'package:KiwiCity/Pages/PaymentPage/wallet.dart';
import 'package:KiwiCity/Pages/QRScanPage/allow_camera.dart';
import 'package:KiwiCity/Pages/QRScanPage/enter_code.dart';
import 'package:KiwiCity/Pages/QRScanPage/qr_scan_page.dart';
import 'package:KiwiCity/Pages/SplashPage/splash_page.dart';
import 'package:KiwiCity/Pages/StartRidingPage/start_riding_page.dart';
import 'package:KiwiCity/Pages/TermsSectionPage/index.dart';
import 'package:KiwiCity/Pages/UnlockPage/unlock.dart';
import 'package:KiwiCity/Pages/PaymentPage/pay_method.dart';
import 'package:KiwiCity/Pages/RideNowPage/ride_now.dart';
import 'package:KiwiCity/Routes/routes.dart';
import 'package:KiwiCity/how_ride.dart';
// import 'package:KiwiCity/photo_scooter_old.dart';
import 'package:KiwiCity/photo_scooter.dart';
import 'package:KiwiCity/settings.dart';
import 'package:KiwiCity/language.dart';
import 'package:KiwiCity/video.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:url_launcher/url_launcher.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    final transitionType = PageTransitionType.fade;
    switch (settings.name) {
      case Routes.SPLASH:
        return PageTransition(
            child: SplashPage(), type: PageTransitionType.scale);

      case Routes.HOME:
        return PageTransition(child: HomePage(), type: transitionType);

      case Routes.ALLOW_PERMISSION:
        // return MaterialPageRoute(
        //   builder: (_) => AllowPermissionPage(
        //     data: args,
        //   ),
        // );
        return PageTransition(
          child: AllowPermissionPage(data: args),
          type: PageTransitionType.scale,
          alignment: Alignment.bottomCenter,
          settings: settings,
        );

// Menubar routes
      case Routes.RIDE_HISTORY:
        return PageTransition(child: RideHistory(), type: transitionType);
      case Routes.RIDE_DETAIL:
        return MaterialPageRoute(
          builder: (_) => RideDetail(
            data: args,
          ),
        );
      case Routes.PAYMENT_METHODS:
        return PageTransition(
          child: PayMethod(
            data: args,
          ),
          type: transitionType,
        );

      case Routes.MANAGE_PAYMETHOD:
        return PageTransition(child: ManagePayMethod(), type: transitionType);

      case Routes.WALLET:
        return PageTransition(child: WalletPage(), type: transitionType);
      case Routes.LANGUAGE:
        return PageTransition(child: LanguageSetting(), type: transitionType);
      // case Routes.SUPPROT:
      case Routes.RIDE_NOW:
        return MaterialPageRoute(
          builder: (_) => RideNow(
            data: args,
          ),
        );

      case Routes.HOW_TO_RIDE:
        return PageTransition(child: Video(), type: transitionType);
      case Routes.TERMS_OF_SERVICE:
        // return PageTransition(child: TermsSectionPage(), type: transitionType);
        return MaterialPageRoute(
          builder: (_) => TermsSectionPage(
            data: args,
          ),
        );

      case Routes.SETTINGS:
        return PageTransition(child: Settings(), type: transitionType);
      case Routes.ENTERCODE:
        return PageTransition(child: EnterCode(), type: transitionType);
      case Routes.QR_SCAN:
        return MaterialPageRoute(
          builder: (_) => QRScanPage(),
        );
      case Routes.ALLOW_CAMERA:
        return PageTransition(child: AllowCamera(), type: transitionType);

      // Auth Page
      case Routes.LOGIN:
        return PageTransition(child: Login(), type: transitionType);
      case Routes.LOGIN_INPUT:
        return PageTransition(child: LoginInputPage(), type: transitionType);
      case Routes.SIGN_UP:
        return PageTransition(child: SignUpPage(), type: transitionType);
      case Routes.FORGET_PASSWORD:
        return PageTransition(
            child: ForgetPasswordPage(), type: transitionType);

      case Routes.SIGN_UP:
        return MaterialPageRoute(builder: (_) => SignUpPage());
      case Routes.START_RIDING:
        return PageTransition(
            child: StartRiding(
              data: args!,
            ),
            type: transitionType);
      case Routes.UNLOCK:
        return PageTransition(
            child: UnLock(
              isMore: args as bool,
            ),
            type: transitionType);
      case Routes.RIDE_HOME:
        return PageTransition(child: RideNow(), type: transitionType);
      case Routes.PHOTO_SCOTTER:
        return MaterialPageRoute(builder: (_) => PhotoScooter(data: args));
      // case Routes.PHOTO_SCOTTER:
      //   return MaterialPageRoute(builder: (_) => PhotoScooter());
      case Routes.HOWRIDE:
        return PageTransition(
            child: HowRide(
              data: args,
            ),
            type: transitionType);
// Terms Section
      // case Routes.TERMSSERVICE:
      //   return MaterialPageRoute(builder: (_) => TermsService());
      // case Routes.DRINK:
      //   return MaterialPageRoute(
      //       builder: (_) => Drink(
      //             onNext: () {},
      //           ));
      // case Routes.HELMET:
      //   return MaterialPageRoute(builder: (_) => Helmet());
      // case Routes.PROHIBIT:
      //   return MaterialPageRoute(builder: (_) => Prohibit());

      default:
        // If there is no such named route in the switch statement, e.g. /third
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Error'),
        ),
        body: Center(
          child: Text('ERROR'),
        ),
      );
    });
  }
}
