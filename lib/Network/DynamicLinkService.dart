// import 'package:flutter_app/Resources/RouteConstant.dart';
// import 'package:flutter_app/Routers/Locator.dart';
// import 'package:flutter_app/Routers/NavigationService.dart';
// import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

// class DynamicLinkService {
//   final NavigationService _navigationService = locator<NavigationService>();

//   String tempLink = '';

//   Future handleDynamicLinks() async {
//     // 1. Get the initial dynamic link if the app is opened with a dynamic link
//     final PendingDynamicLinkData data =
//         await FirebaseDynamicLinks.instance.getInitialLink();
//     // 2. handle link that has been retrieved
//     _handleDeepLink(data);

//     // 3. Register a link callback to fire if the app is opened up from the background
//     // using a dynamic link.

//     FirebaseDynamicLinks.instance.onLink(
//         onSuccess: (PendingDynamicLinkData dynamicLink) async {
//           // 3a. handle link that has been retrieved
//           _handleDeepLink(dynamicLink);
//         },
//         onError: (OnLinkErrorException e) async {});
//   }

//   Future<void> _handleDeepLink(PendingDynamicLinkData linkData) async {
//     final Uri deepLink = linkData?.link;
//     if (deepLink != null) {
//       String tokenId = deepLink.queryParameters["token"];
//       if (tokenId != null && tokenId != "") {
//         Map<String, dynamic> data = {
//           "data": {"tokenId": tokenId}
//         };
//         _navigationService.navigateTo(RouteConst.routeResetPinScreen, data);
//       }
//     }
//   }
// }
