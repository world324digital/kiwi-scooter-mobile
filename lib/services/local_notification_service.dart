/************************************************************************************
 * @Auth: world324digital@gmail.com
 * @Date: 2023.04.15
 * @DESC: Flutter Local Notification Service Utiliy
 */
/////////////////////////////////////////////////////////////////////////////////////
/// FLUTTER SDK: 3.3.9
/// flutter_local_notifications: ^12.0.4
/////////////////////////////////////////////////////////////////////////////////////

import 'dart:io';
import 'dart:ui';

import 'package:KiwiCity/Helpers/download-until.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:rxdart/subjects.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService({
    String? icon = "@mipmap/ic_launcher", // Should be Drawable Bitmap
    String? largeIcon = "@mipmap/ic_launcher", // Should be Drawable Bitmap
    String? imgUrl = null,
    Color iconBackgroundColor = const Color.fromARGB(155, 67, 118, 226),
  }) {
    this.imgUrl = imgUrl;
    this.icon = icon;
    this.largeIcon = largeIcon;
    this.iconBackgroundColor = iconBackgroundColor;
  }
  String? imgUrl;
  String? icon;
  String? largeIcon;
  Color? iconBackgroundColor;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  final BehaviorSubject<NotificationResponse> behaviorSubject =
      BehaviorSubject();

  /***********************************************************
   * Background notification handler when tap the notification
   */
  @pragma('vm:entry-point')
  static void notificationTapBackground(
      NotificationResponse notificationResponse) {
    // ignore: avoid_print
    print('notification(${notificationResponse.id}) action tapped: '
        '${notificationResponse.actionId} with'
        ' payload: ${notificationResponse.payload}');
    if (notificationResponse.input?.isNotEmpty ?? false) {
      // ignore: avoid_print
      print(
          'notification action tapped with input: ${notificationResponse.input}');
    }
  }

  /***************************************
   * Initialize Local Notification for each platform
   */
  Future<void> initSetUp() async {
    // Android Notification Icon, you can change it later , @mipmap/ic_launcher should be  Drawable
    AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(icon ?? '@mipmap/ic_launcher');

    // IOS Notification Initialize, you can change permissions later
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
            requestSoundPermission: true,
            requestBadgePermission: true,
            requestAlertPermission: true,
            onDidReceiveLocalNotification: onDidReceiveLocalNotification);

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      onDidReceiveNotificationResponse: selectNotification,
    );

    // Initialize Local Timezone for Schedule Notification
    tz.initializeTimeZones();
    tz.setLocalLocation(
      tz.getLocation(
        await FlutterNativeTimezone.getLocalTimezone(),
      ),
    );
  }

  /**************************************
   * Receive Notification Handler For IOS
   */
  void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) {
    print('id $id');
  }

  /****************************************
   * Tap Notification Handler
   */
  void selectNotification(NotificationResponse? payload) {
    if (payload != null) {
      behaviorSubject.add(payload);
    }
  }

  /*******************************************
   * Notification Details ( Styles )
   */
  Future<NotificationDetails> _notificationDetails() async {
    final String? bigPicture = imgUrl != null
        ? await DownloadUtil.saveFromAsset(imgUrl!, "notificationIcon")
        : null;
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'channel id',
      'channel name',
      groupKey: 'com.example.flutter_push_notifications',
      channelDescription: 'channel description',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      ticker: 'ticker',
      largeIcon:
          DrawableResourceAndroidBitmap(largeIcon ?? '@mipmap/launcher_icon'),
      styleInformation: bigPicture != null
          ? BigPictureStyleInformation(
              FilePathAndroidBitmap(bigPicture),
              hideExpandedLargeIcon: false,
            )
          : null,
      color: iconBackgroundColor ?? Color.fromARGB(155, 67, 118, 226),
    );

    DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
      threadIdentifier: "thread1",
      attachments: bigPicture != null
          ? <DarwinNotificationAttachment>[
              DarwinNotificationAttachment(bigPicture)
            ]
          : null,
    );

    final details = await _localNotifications.getNotificationAppLaunchDetails();
    if (details != null && details.didNotificationLaunchApp) {
      behaviorSubject.add(details.notificationResponse!);
    }
    NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics, iOS: iosNotificationDetails);

    return platformChannelSpecifics;
  }

  /*************************************
   * Show Notification SOON!
   */
  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    required String payload,
  }) async {
    final platformChannelSpecifics = await _notificationDetails();
    await _localNotifications.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  /**********************************
   * Show Notification Scheduled
   */
  Future<void> showScheduledLocalNotification({
    required int id,
    required String title,
    required String body,
    required String payload,
    required int seconds,
  }) async {
    final platformChannelSpecifics = await _notificationDetails();
    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.now(tz.local).add(Duration(seconds: seconds)),
      platformChannelSpecifics,
      payload: payload,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
    );
  }

  /************************************
   * Show Periodic Notification
   */
  Future<void> showPeriodicLocalNotification({
    required int id,
    required String title,
    required String body,
    required String payload,
  }) async {
    final platformChannelSpecifics = await _notificationDetails();
    await _localNotifications.periodicallyShow(
      id,
      title,
      body,
      RepeatInterval.everyMinute,
      platformChannelSpecifics,
      payload: payload,
      androidAllowWhileIdle: true,
    );
  }

  /********************************
   * Cancel Notification with ID
   */
  Future<void> cancelNotification(int ID) async {
    await _localNotifications.cancel(ID);
  }

  /***************************
   * Cancel All Notification
   */
  Future<void> cancelAllNotification() async {
    await _localNotifications.cancelAll();
  }
}


/******************** Donwload Utility Code *****************
//// IF YOU DON'T HAVE THIS FUNCTION, PLEASE USE THIS CODE 
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class DownloadUtil {
  static Future<String> downloadAndSaveFile(String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName.png';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  
  static Future<String> saveFromAsset(String path, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/${fileName}.png';
    final byteData = await rootBundle.load('$path');

    final File file = File(filePath);

    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    return filePath;
  }
}
*/

/**************************** USAGE **************************

  late final NotificationService notificationService;

  @override
  void initState() {
    super.initState();

    notificationService = NotificationService();
    notificationService.initSetUp();
    listenToNotificationStream();
  }

  void listenToNotificationStream() =>
      notificationService.behaviorSubject.listen((payload) {
        print("============Notification Payload ============\r\n");
        print(payload);
      });
 */