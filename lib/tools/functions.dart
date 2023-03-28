// import 'package:flutter/cupertino.dart';
// import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
// ignore: import_of_legacy_library_into_null_safe
import 'package:intl/intl.dart';
// ignore: depend_on_referenced_packages
import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/scheduler.dart';
// import 'package:flutter_cache_manager/flutter_cache_manager.dart';
// import 'dart:convert';
// // ignore: depend_on_referenced_packages
// import 'package:pretty_json/pretty_json.dart';
// import 'dart:developer' as dev;

double roundDouble(double value, int places) {
  num mod = pow(10.0, places);
  return ((value * mod).round().toDouble() / mod);
}

double getScreenHeight(BuildContext context) {
  return MediaQuery.of(context).size.height;
}

double getScreenWidth(BuildContext context) {
  return MediaQuery.of(context).size.width;
}
Widget buildFloatingButtonProductCalendar(BuildContext context, String title,
    bool isActive, Color textColor, void Function() func,
    {double width = 100}) {
  final buttonStyle = ButtonStyle(
    elevation: MaterialStateProperty.all<double>(5.0),
    shadowColor: MaterialStateProperty.all(
      Colors.transparent,
    ),
    // foregroundColor: MaterialStateProperty.all<Color>(const Color(0xff313036)),
    backgroundColor: MaterialStateProperty.all<Color>(
      isActive ? const Color(0xffFF2323) : const Color(0xffF6F6F6),
    ),
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  );
  final text = Text(
    title,
    style: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 14,
      color: isActive ? const Color(0xffF6F6F6) : const Color(0xff313036),
    ),
    textAlign: TextAlign.center,
  );
  return Stack(
    alignment: Alignment.center,
    children: <Widget>[
      SizedBox(
        width: MediaQuery.of(context).size.width * 0.25,
        height: 42,
        child: ElevatedButton(
          onPressed: func,
          style: buttonStyle,
          child: text,
        ),
      ),
      if (isActive)
        const SizedBox(
          width: 60,
          height: 45,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Divider(
              color: Colors.white,
              thickness: 1.0,
            ),
          ),
          // ),
        ),
    ],
    // ),
  );
  // return Container(
  //   padding: const EdgeInsets.all(1),
  //   width: width,
  //   height: 45,
  //   child: Column(
  //     children: [
  //       ElevatedButton(
  //         onPressed: func,
  //         style: buttonStyle,
  //         child: text,
  //       ),
  //       Divider(color: Colors.black)
  //     ],
  //   ),
  // );
}
Widget buildTextFieldCountryReadOnly(String title, String titleFlag,
    Icon prefixIcon, String prefixFlag, Icon suffixIcon, void Function() func) {
  return TextField(
    onTap: func,
    readOnly: true,
    textAlign: TextAlign.left,
    decoration: InputDecoration(
      filled: true,
      prefixIcon: prefixFlag != ""
          ? Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            prefixFlag,
            style: const TextStyle(fontSize: 18),
          )
        ],
      )
          : prefixIcon,
      suffixIcon: suffixIcon,
      hintText: titleFlag != "" ? titleFlag : title,
      contentPadding: const EdgeInsets.all(15),
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(30),
      ),
    ),
  );
}

Widget returnCheckingIcon(List list) {
  if (list[0] == 1) {
    return const Icon(Icons.error,
        color: Color.fromARGB(255, 255, 35, 35), size: 30);
  } else if (list[1] == 1) {
    return const Icon(Icons.check,
        color: Color.fromARGB(255, 33, 237, 91), size: 30);
  }
  return const Icon(Icons.check, color: Colors.grey, size: 30);
}

Widget buildTextFieldEmailReadOnly(String title, Icon prefixIcon) {
  return TextField(
    keyboardType: TextInputType.emailAddress,
    readOnly: true,
    textAlign: TextAlign.left,
    decoration: InputDecoration(
      filled: true,
      fillColor: const Color.fromARGB(255, 215, 215, 215),
      prefixIcon: prefixIcon,
      hintText: title,
      hintStyle: const TextStyle(color: Colors.grey),
      contentPadding: const EdgeInsets.all(15),
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(30),
      ),
    ),
  );
}

Widget buildTextFieldEmail(
    String title, Icon prefixIcon, TextEditingController txtController) {
  return TextFormField(
    readOnly: false,
    keyboardType: TextInputType.emailAddress,
    textAlign: TextAlign.left,
    decoration: InputDecoration(
      filled: true,
      fillColor: const Color.fromARGB(255, 235, 235, 235),
      prefixIcon: prefixIcon,
      hintText: title,
      contentPadding: const EdgeInsets.all(15),
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(30),
      ),
    ),
    controller: txtController,
  );
}

bool isAlphaNum(String string) {
  if (string.isEmpty || string.length < 3) return false;
  final alphanumRegex = RegExp(r'^[ a-zA-Z0-9]+$');

  return alphanumRegex.hasMatch(string);
}

bool isPassword(String string) {
  RegExp numReg = RegExp(r".*[0-9].*");
  if (string.isEmpty ||
      string.length < 8 ||
      string.contains(" ") ||
      !numReg.hasMatch(string)) {
    return false;
  } else {
    return true;
  }
}

bool isAlphabetics(String string) {
  if (string.isEmpty || string.length < 3) return false;
  final alphaRegex = RegExp(r'^[- a-zA-Z]+$');

  return alphaRegex.hasMatch(string);
}

SnackBar launchSnackbar(String title, IconData icon, Color iconcolor,
    Color backgroundcolor, Color textcolor) {
  return SnackBar(
    behavior: SnackBarBehavior.floating,
    content: Row(
      children: [
        Icon(
          icon,
          color: iconcolor,
          size: 30,
        ),
        const SizedBox(width: 15),
        Expanded(
            child: Text(
              title,
              style: TextStyle(fontFamily: 'Montserrat-SemiBold',fontSize: 16, color: Colors.black)
            ))
      ],
    ),
    backgroundColor: backgroundcolor,
    duration: const Duration(seconds: 3),
  );
}
bool isNumerics(String string) {
  if (string.isEmpty || string.length < 3) return false;
  final numericRegex = RegExp(r'^[+0-9]+$');

  return numericRegex.hasMatch(string);
}

bool isNumber(String string) {
  final numericRegex = RegExp(r'[+-]?([0-9]*[.])?[0-9]+');

  return numericRegex.hasMatch(string);
}

Color returnColorCalendarCote(String element) {
  int e = isNumber(element) ? int.parse(element) : -999;
  // int e = int.parse(element);
  if (e < -100) {
    return const Color(0xffC4C4C4);
  } else if (e >= -100 && e < 15) {
    return const Color(0xffF55E5E);
  } else if (e >= 15 && e < 25) {
    return const Color(0xffFFC654);
  } else {
    return const Color(0xff21ED5B);
  }
}

void initFilterTabsOne(List<List<List<dynamic>>> defaultTab,
    List<List<List<dynamic>>> filterTab, Color color) {
  for (int x = 0; x < defaultTab.length; x++) {
    for (int y = 0, count = 0; y < defaultTab[x].length; y++) {
      if (returnColorCalendarCote(defaultTab[x][y][2]) == color) {
        if (count == 0) {
          filterTab[x][count] = defaultTab[x][y];
        } else {
          filterTab[x].add(defaultTab[x][y]);
        }
        count++;
      }
    }
  }
}

void initFilterTabsTwo(List<List<List<dynamic>>> defaultTab,
    List<List<List<dynamic>>> filterTab, Color color1, Color color2) {
  for (int x = 0; x < defaultTab.length; x++) {
    for (int y = 0, count = 0; y < defaultTab[x].length; y++) {
      if (returnColorCalendarCote(defaultTab[x][y][2]) == color1 ||
          returnColorCalendarCote(defaultTab[x][y][2]) == color2) {
        if (count == 0) {
          filterTab[x][count] = defaultTab[x][y];
        } else {
          filterTab[x].add(defaultTab[x][y]);
        }
        count++;
      }
    }
  }
}

void loadMorefilterTabsOne(List<List<dynamic>> dayTab,
    List<List<List<dynamic>>> filterTab, Color color) {
  for (int y = 0; y < dayTab.length; y++) {
    if (returnColorCalendarCote(dayTab[y][2]) == color) {
      filterTab.add(dayTab);
    } else {
      filterTab.add([
        ["", "", "", "", "", ""]
      ]);
    }
  }
}

void loadMorefilterTabsTwo(List<List<dynamic>> dayTab,
    List<List<List<dynamic>>> filterTab, Color color1, Color color2) {
  for (int y = 0; y < dayTab.length; y++) {
    if (returnColorCalendarCote(dayTab[y][2]) == color1 ||
        returnColorCalendarCote(dayTab[y][2]) == color2) {
      filterTab.add(dayTab);
    } else {
      filterTab.add([
        ["", "", "", "", "", ""]
      ]);
    }
  }
}

List<List<List<dynamic>>> goodListCalendar(
    bool low,
    bool medium,
    bool high,
    List<List<List<dynamic>>> tabLow,
    List<List<List<dynamic>>> tabMedium,
    List<List<List<dynamic>>> tabHigh,
    List<List<List<dynamic>>> tabLowMedium,
    List<List<List<dynamic>>> tabLowHigh,
    List<List<List<dynamic>>> tabMediumHigh,
    List<List<List<dynamic>>> tabDefault) {
  if (low && !medium && !high) {
    return tabLow;
  } else if (low && medium && !high) {
    return tabLowMedium;
  } else if (low && medium && high) {
    return tabDefault;
  } else if (!low && medium && !high) {
    return tabMedium;
  } else if (!low && medium && high) {
    return tabMediumHigh;
  } else if (!low && !medium && high) {
    return tabHigh;
  } else if (low && !medium && high) {
    return tabLowHigh;
  } else {
    return tabDefault;
  }
}

String getCurrentDayLetterUpcoming(int n) {
  var dayLetter =
  DateFormat("EEEE").format(DateTime.now().add(Duration(days: n)));
  return dayLetter.toString();
}

String getCurrentDayNbUpcoming(int n) {
  var dayNb = DateFormat("d").format(DateTime.now().add(Duration(days: n)));
  return dayNb.toString();
}

String getCurrentMonthUpcoming(int n) {
  var month = DateFormat("MMMM").format(DateTime.now().add(Duration(days: n)));
  return month.toString();
}

String getCurrentYearUpcoming(int n) {
  var year = DateFormat("yyyy").format(DateTime.now().add(Duration(days: n)));
  return year.toString();
}

String getCurrentMonthNbUpcoming(int n) {
  var month = DateFormat("M").format(DateTime.now().add(Duration(days: n)));
  return month.toString();
}

String createCalendarAPICallDateFormatUpcoming(int n) {
  String month = getCurrentMonthNbUpcoming(n);
  String day = getCurrentDayNbUpcoming(n);

  if (int.parse(month) < 10) month = "0$month";
  if (int.parse(day) < 10) day = "0$day";
  String format = "${getCurrentYearUpcoming(n)}-$month-$day";
  return format;
}

String getCurrentDayLetterPast(int n) {
  var dayLetter =
  DateFormat("EEEE").format(DateTime.now().subtract(Duration(days: n)));
  return dayLetter.toString();
}

String getCurrentDayNbPast(int n) {
  var dayNb =
  DateFormat("d").format(DateTime.now().subtract(Duration(days: n)));
  return dayNb.toString();
}

String getCurrentMonthPast(int n) {
  var month =
  DateFormat("MMMM").format(DateTime.now().subtract(Duration(days: n)));
  return month.toString();
}

String getCurrentYearPast(int n) {
  var year =
  DateFormat("yyyy").format(DateTime.now().subtract(Duration(days: n)));
  return year.toString();
}

String getCurrentMonthNbPast(int n) {
  var month =
  DateFormat("M").format(DateTime.now().subtract(Duration(days: n)));
  return month.toString();
}

String createCalendarAPICallDateFormatPast(int n) {
  String month = getCurrentMonthNbPast(n);
  String day = getCurrentDayNbPast(n);

  if (int.parse(month) < 10) month = "0$month";
  if (int.parse(day) < 10) day = "0$day";
  String format = "${getCurrentYearPast(n)}-$month-$day";
  return format;
}

String returnCalendarIcon(String day) {
  if (int.parse(day) == 1) {
    return ("assets/etc/calendar_1.png");
  } else if (int.parse(day) == 2) {
    return ("assets/etc/calendar_2.png");
  } else if (int.parse(day) == 3) {
    return ("assets/etc/calendar_3.png");
  } else if (int.parse(day) == 4) {
    return ("assets/etc/calendar_4.png");
  } else if (int.parse(day) == 5) {
    return ("assets/etc/calendar_5.png");
  } else if (int.parse(day) == 6) {
    return ("assets/etc/calendar_6.png");
  } else if (int.parse(day) == 7) {
    return ("assets/etc/calendar_7.png");
  } else if (int.parse(day) == 8) {
    return ("assets/etc/calendar_8.png");
  } else if (int.parse(day) == 9) {
    return ("assets/etc/calendar_9.png");
  } else if (int.parse(day) == 10) {
    return ("assets/etc/calendar_10.png");
  } else if (int.parse(day) == 11) {
    return ("assets/etc/calendar_11.png");
  } else if (int.parse(day) == 12) {
    return ("assets/etc/calendar_12.png");
  } else if (int.parse(day) == 13) {
    return ("assets/etc/calendar_13.png");
  } else if (int.parse(day) == 14) {
    return ("assets/etc/calendar_14.png");
  } else if (int.parse(day) == 15) {
    return ("assets/etc/calendar_15.png");
  } else if (int.parse(day) == 16) {
    return ("assets/etc/calendar_16.png");
  } else if (int.parse(day) == 17) {
    return ("assets/etc/calendar_17.png");
  } else if (int.parse(day) == 18) {
    return ("assets/etc/calendar_18.png");
  } else if (int.parse(day) == 19) {
    return ("assets/etc/calendar_19.png");
  } else if (int.parse(day) == 20) {
    return ("assets/etc/calendar_20.png");
  } else if (int.parse(day) == 21) {
    return ("assets/etc/calendar_21.png");
  } else if (int.parse(day) == 22) {
    return ("assets/etc/calendar_22.png");
  } else if (int.parse(day) == 23) {
    return ("assets/etc/calendar_23.png");
  } else if (int.parse(day) == 24) {
    return ("assets/etc/calendar_24.png");
  } else if (int.parse(day) == 25) {
    return ("assets/etc/calendar_25.png");
  } else if (int.parse(day) == 26) {
    return ("assets/etc/calendar_26.png");
  } else if (int.parse(day) == 27) {
    return ("assets/etc/calendar_27.png");
  } else if (int.parse(day) == 28) {
    return ("assets/etc/calendar_28.png");
  } else if (int.parse(day) == 29) {
    return ("assets/etc/calendar_29.png");
  } else if (int.parse(day) == 30) {
    return ("assets/etc/calendar_30.png");
  } else {
    return ("assets/etc/calendar_31.png");
  }
}

String returnRestockDate(String completeDate) {
  // var tab = completeDate.split('-');

  final notifTime = DateTime.parse(completeDate);
  final nowTime = DateTime.now();
  final difference = nowTime.difference(notifTime).inMinutes;
  if (difference == 0) {
    return "Now";
  } else if (difference > 0 && difference < 60) {
    return "$difference min(s) ago";
  } else if (difference >= 60 && difference < 1440) {
    final diffHour = nowTime.difference(notifTime).inHours;
    return "$diffHour hour(s) ago";
  } else {
    return "Yesterday";
  }
}

AlignmentGeometry returnAlignment(double nb) {
  if (nb >= 51) {
    return const Alignment(-0.5, 0);
  } else if (nb < 50) {
    return const Alignment(0.5, 0);
  } else {
    return Alignment.center;
  }
}

double returnByBrands1(int x, bool jordan, bool nike, bool nb) {
  if (x == 0) {
    return jordan ? 1 : 0;
  } else if (x == 1) {
    return nike ? 1 : 0;
  } else {
    return nb ? 1 : 0;
  }
}

double returnByBrands2(int x, bool adidas, bool yeezy) {
  if (x == 0) {
    return adidas ? 1 : 0;
  } else {
    return yeezy ? 1 : 0;
  }
}

int checkRestockFilterConditions(bool jordan, bool nike, bool nb, bool adidas,
    bool yeezy, List<List<dynamic>> list, int position) {
  if (!jordan && !nike && !nb && !adidas && !yeezy) {
    return 1;
  } else {
    if (list[position][6] == "Jordan" && jordan) {
      return 1;
    } else if (list[position][6] == "Nike" && nike) {
      return 1;
    } else if (list[position][6] == "NewBalance" && nb) {
      return 1;
    } else if (list[position][6] == "Adidas" && adidas) {
      return 1;
    } else if (list[position][6] == "Yeezy" && yeezy) {
      return 1;
    } else {
      return 0;
    }
  }
}

FloatingActionButtonLocation? returnFloatingButtonLocationCalendar(
    int calendarPage, bool is360) {
  if (calendarPage == 0 || calendarPage == 1) {
    return FloatingActionButtonLocation.miniCenterFloat;
  } else {
    if (is360) {
      return FloatingActionButtonLocation.endTop;
    } else {
      return null;
    }
  }
}

int returnFloatingButtonCalendar(int calendarPage, bool is360) {
  if (calendarPage == 0 || calendarPage == 1) {
    return 0;
  } else {
    if (is360) {
      return 1;
    } else {
      return 2;
    }
  }
}

void showMessage(context, String s,
    {title = 'ERROR', action = const Text('')}) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(s),
          actions: [
            action,
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Ok'),
            ),
          ],
        );
      });
}

showConfirmDialog(BuildContext context, String title, String content,
    Function() confirmAction) {
  // set up the buttons
  Widget cancelButton = TextButton(
    child: const Text("Cancel"),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );
  Widget continueButton = TextButton(
    child: const Text("Confirm"),
    onPressed: () {
      confirmAction();
    },
  );
  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(title),
    content: Text(content),
    actions: [
      cancelButton,
      continueButton,
    ],
  );
  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

Future getData(String url) async {
  try {
    var response = await http.get(
      Uri.parse(url),
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load data');
    }
  } catch (e) {
    rethrow;
  }
}

Future postData(String url) async {}

double extractNumberFromPrice(String string) {
  final numericRegex = RegExp(r'[+-]?([0-9]*[.])?[0-9]+');
  return numericRegex.firstMatch(string) != null
      ? double.parse(numericRegex.firstMatch(string)![0].toString())
      : 0.0;
}

String extractUnitFromPrice(String string) {
  final numericRegex = RegExp(r'[+-]?([0-9]*[.])?[0-9]+');
  return string.replaceAll(numericRegex.firstMatch(string)![0].toString(), '');
}

getListHeats() async {
  List<Map> listHeats = [];

  var result = await getData('http://194.163.152.120:3000/heats');
  listHeats = jsonDecode(result)['data']['heats']
      .map((e) {
    return {
      "ProductSKU": e['ProductSKU'],
      "ProductName": e['ProductName'],
      "MonthDay": e['MonthDay'],
      "ResellValuePourcent": e['ResellValuePourcent'],
      "ProductImage": e['ProductImage'],
    };
  })
      .toList()
      .cast<Map>();
  // var temp = jsonDecode(result)['data']['heats'];
  // for (int i = 0; i < temp.length; i++) {
  //   var fetchedFile;
  //   try {
  //     fetchedFile =
  //         await DefaultCacheManager().downloadFile(temp[i]['ProductImage']);
  //   } catch (e) {
  //     fetchedFile = null;
  //   }

  //   listHeats.add({
  //     "ProductSKU": temp[i]['ProductSKU'],
  //     "ProductName": temp[i]['ProductName'],
  //     "MonthDay": temp[i]['MonthDay'],
  //     "ResellValuePourcent": temp[i]['ResellValuePourcent'],
  //     "ProductImage": fetchedFile?.file,
  //   });
  // }

  // if (!mounted) return;'
  return listHeats;
}

getListRecently() async {
  List<Map> listRecently = [];

  var result = await getData('http://194.163.152.120:3000/recent');
  listRecently = jsonDecode(result)['data']['recentlyDropped']
      .map((e) {
    return {
      "ProductSKU": e['ProductSKU'],
      "ProductName": e['ProductName'],
      "xxShops": e['xxShops'],
      "ProductMarketValue": e['ProductMarketValue'],
      "ResellValuePourcent": e['ResellValuePourcent'],
      "ProductResellArrow": e['ProductResellArrow'],
      "ProductImage": e['ProductImage'],
    };
  })
      .toList()
      .cast<Map>();
  // if (!mounted) return;
  // var temp = jsonDecode(result)['data']['recentlyDropped'];
  // for (int i = 0; i < temp.length; i++) {
  //   var fetchedFile;
  //   try {
  //     fetchedFile =
  //         await DefaultCacheManager().downloadFile(temp[i]['ProductImage']);
  //   } catch (e) {
  //     fetchedFile = null;
  //   }
  //   listRecently.add({
  //     "ProductSKU": temp[i]['ProductSKU'],
  //     "ProductName": temp[i]['ProductName'],
  //     "xxShops": temp[i]['xxShops'],
  //     "ProductMarketValue": temp[i]['ProductMarketValue'],
  //     "ResellValuePourcent": temp[i]['ResellValuePourcent'],
  //     "ProductResellArrow": temp[i]['ProductResellArrow'],
  //     "ProductImage": fetchedFile?.file,
  //   });
  // }
  return listRecently;
}

getListNews() async {
  List<String> listNews = [];

  var result = await getData('http://194.163.152.120:3000/s4snews');
  listNews = jsonDecode(result)['data']['s4sNews']
      .map((e) {
    return e.toString();
  })
      .toList()
      .cast<String>();
  // var temp = jsonDecode(result)['data']['s4sNews'];
  // for (int i = 0; i < temp.length; i++) {
  // var fetchedFile = await DefaultCacheManager().getSingleFile(temp[i]);
  //   listNews.add(fetchedFile);
  // }
  return listNews;
}

getListTops() async {
  List<Map> listTops = [];
  var result = await getData('http://194.163.152.120:3000/top');
  listTops = jsonDecode(result)['data']['topClicked']
      .map((e) {
    return {
      'ProductSKU': e['ProductSKU'],
      'ProductImage': e['ProductImage'],
      'ProductName': e['ProductName'],
      'product_change_arrow': e['product_change_arrow'],
      'xxShops': e['xxShops'],
      'ProductMarketValue': e['ProductMarketValue'],
      'ProductResellArrow': e['ProductResellArrow'],
    };
  })
      .toList()
      .cast<Map>();
  // if (!mounted) return;
  // var temp = jsonDecode(result)['data']['topClicked'];
  // for (int i = 0; i < temp.length; i++) {
  //   var fetchedFile =
  //       await DefaultCacheManager().getSingleFile(temp[i]['ProductImage']);
  //   listTops.add({
  //     'ProductSKU': temp[i]['ProductSKU'],
  //     'ProductName': temp[i]['ProductName'],
  //     'product_change_arrow': temp[i]['product_change_arrow'],
  //     'xxShops': temp[i]['xxShops'],
  //     'ProductMarketValue': temp[i]['ProductMarketValue'],
  //     'ProductResellArrow': temp[i]['ProductResellArrow'],
  //     "ProductImage": fetchedFile,
  //   });
  // }
  return listTops;
}

getRaffles(String sku) async {
  List<Map> raffle = [];
  var result = await getData('http://194.163.152.120:3000/raffles/$sku');
  raffle = jsonDecode(result)['data']['raffles']
      .map((e) {
    return {
      'ProductSKU': e['ProductSKU'] ?? '',
      'ProductImage': e['ProductImage'],
      'ProductName': e['ProductName'],
      'ShopLocation': e['ShopLocation'],
      'ShopLogo': e['ShopLogo'],
      'ShopShipping': e['ShopShipping'],
      'ShopCloseTime': e['ShopCloseTime'],
      'ShopRaffleLink': e['ShopRaffleLink'],
      'RetailPrice': e['RetailPrice'],
      'ReleaseDate': e['ReleaseDate'],
      'ColorWay': e['ColorWay'],
      'ProductImage360': e['ProductImage360'],
    };
  })
      .toList()
      .cast<Map>();
  // dev.log(prettyJson(jsonDecode(jsonEncode(upcomings))));
  // if (!mounted) return;
  return raffle[0];
}

getRetails(String sku) async {
  List<Map> retail = [];
  var result = await getData('http://194.163.152.120:3000/retail/$sku');
  retail = jsonDecode(result)['data']['retail']
      .map((e) {
    return {
      'ProductSKU': e['ProductSKU'],
      'ProductImage': e['ProductImage'],
      'ProductName': e['ProductName'],
      'ProductImage360': e['ProductImage360'],
      'Shops': e['Shops'],
    };
  })
      .toList()
      .cast<Map>();
  // dev.log(prettyJson(jsonDecode(jsonEncode(upcomings))));
  // if (!mounted) return;
  return retail[0];
}

getResells(String sku) async {
  List<Map> resell = [];
  var result = await getData('http://194.163.152.120:3000/resell/$sku');
  resell = jsonDecode(result)['data']['resell']
      .map((e) {
    return {
      'ProductSKU': e['ProductSKU'],
      'ProductName': e['ProductName'],
      'ProductSize': e['ProductSize'],
      'ProductSizeBest': e['ProductSizeBest'],
    };
  })
      .toList()
      .cast<Map>();
  // dev.log(prettyJson(jsonDecode(jsonEncode(upcomings))));
  // if (!mounted) return;
  return resell[0];
}

getUpcomings() async {
  List upcomings = [];
  var result = await getData('http://194.163.152.120:3000/upcoming');
  List temp = [];
  jsonDecode(result)['data']['upcomings'].forEach((key, value) {
    // print(value);
    temp.add({key: value});
  });
  upcomings = temp;
  // dev.log(prettyJson(jsonDecode(jsonEncode(upcomings))));
  // if (!mounted) return;
  return upcomings;
}

getPasts() async {
  List pasts = [];
  var result = await getData('http://194.163.152.120:3000/past');
  List temp = [];
  jsonDecode(result)['data']['pastProducts'].forEach((key, value) {
    // print(value);
    temp.add({key: value});
  });
  pasts = temp;
  // dev.log(prettyJson(jsonDecode(jsonEncode(upcomings))));
  return pasts;
}

getRestock() async {
  List<Map> restock = [];
  var result = await getData('http://194.163.152.120:3000/restock');
  restock = jsonDecode(result)['data']['restock']
      .map((e) {
    return {
      'DateTime': e['DateTime'],
      'ProductSKU': e['ProductSKU'],
      'ProductName': e['ProductName'],
      'ShopName': e['ShopName'],
      'ProductImage': e['ProductImage'],
      'Url_Link': e['Url_Link'],
    };
  })
      .toList()
      .cast<Map>();
  return restock;
}

List<Map> sizes = [
  {
    '3.5': [3, 35.5]
  },
  {
    '4': [3.5, 36]
  },
  {
    '4.5': [4, 36.5]
  },
  {
    '5': [4.5, 37.5]
  },
  {
    '5.5': [5, 38]
  },
  {
    '6': [5.5, 38.5]
  },
  {
    '6.5': [6, 39]
  },
  {
    '7': [6, 40]
  },
  {
    '7.5': [6.5, 40.5]
  },
  {
    '8': [7, 41]
  },
  {
    '8.5': [7.5, 42]
  },
  {
    '9': [8, 42.5]
  },
  {
    '9.5': [8.5, 43]
  },
  {
    '10': [9, 44]
  },
  {
    '10.5': [9.5, 44.5]
  },
  {
    '11': [10, 45]
  },
  {
    '11.5': [10.5, 45.5]
  },
  {
    '12': [11, 46]
  },
  {
    '12.5': [11.5, 47]
  },
  {
    '13': [12, 47.5]
  },
  {
    '13.5': [12.5, 48]
  },
  {
    '14': [13, 48.5]
  },
  {
    '14.5': [13.5, 49]
  },
  {
    '15': [14, 49.5]
  },
  {
    '15.5': [14.5, 50]
  },
  {
    '16': [15, 50.5]
  },
  {
    '16.5': [15.5, 51]
  },
  {
    '17': [16, 51.5]
  },
  {
    '17.5': [16.5, 52]
  },
  {
    '18': [17, 52.5]
  },
  {
    '18.5': [17.5, 53]
  },
  {
    '19': [18, 53.5]
  },
  {
    '19.5': [18.5, 54]
  },
  {
    '20': [19, 54.5]
  },
  {
    '20.5': [19.5, 55]
  },
  {
    '21': [20, 55.5]
  },
  {
    '21.5': [20.5, 56]
  },
  {
    '22': [21, 56.5]
  },
];

String searchSize(String type, String key) => type == 'UK'
    ? sizes
    .firstWhere((element) => element.keys.first == key)
    .values
    .first[0]
    .toString()
    : sizes
    .firstWhere((element) => element.keys.first == key)
    .values
    .first[1]
    .toString();

List getMainSizeData(List data) => cleanList(data
    .map((e) => e.isNotEmpty && e['Size'] != null ? e["Size"] : "")
    .toList());

List getUKSize(List data) => data.map((e) => searchSize('UK', e)).toList();

List getEUSize(List data) => data.map((e) => searchSize('EU', e)).toList();

List cleanList(List data) {
  List temp = [];
  for (var element in data) {
    if (element == '' || element == null || element == {} || element == []) {
      continue;
    } else {
      temp.add(element);
    }
  }
  return temp;
}

String getPricePerSize(String size, List data) {
  String result = '';
  for (var element in data) {
    if (element['Size'] == size) {
      result = element['Product']['Price'].toString();
    }
  }
  return result;
}

List getProductsPerSize(String size, List productSizes) {
  List result = [];
  for (var element in productSizes) {
    if (element['Size'] == size) {
      result = element['Products'];
      break;
    } else {
      continue;
    }
  }
  return result;
}

getProductDetail(String sku) async {
  List<Map> productDetail = [];
  var result = await getData('http://194.163.152.120:3000/productpage/$sku');
  productDetail = jsonDecode(result)['data']['products']
      .map((e) {
    return {
      'ProductSKU': e['ProductSKU'],
      'ProductName': e['ProductName'],
      'ProductImage': e['ProductImage'],
      'ProductBrand': e['ProductBrand'],
      'ProductCat': e['ProductCat'],
      'ProductRetailPrice': e['ProductRetailPrice'],
      'ProductReleaseDate': e['ProductReleaseDate'],
      'ProductColorWay': e['ProductColorWay'],
      'ProductImageOOTD': e['ProductImageOOTD'],
      'ProductSize': e['ProductSize'],
      'ProductSizeBest': e['ProductSizeBest'],
    };
  })
      .toList()
      .cast<Map>();
  // dev.log(prettyJson(jsonDecode(jsonEncode(upcomings))));
  // if (!mounted) return;
  return productDetail.isNotEmpty ? productDetail[0] : {};
}

void scrollDown(ScrollController controller, double position) {
  // controller.animateTo(position,
  //     duration: const Duration(milliseconds: 10), curve: Curves.ease);
  SchedulerBinding.instance.addPostFrameCallback((_) {
    controller.jumpTo(position);
  });
}

double calendarOffset = 0.0;
