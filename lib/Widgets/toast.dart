import 'package:flutter_dropdown_alert/alert_controller.dart';
import 'package:flutter_dropdown_alert/model/data_alert.dart';

class Alert {
  static showMessage(
      {required TypeAlert type,
      required String title,
      required String message,
      int? duaration}) {
    AlertController.show(
      title,
      message,
      type,
    );
    Future.delayed(Duration(milliseconds: duaration ?? 3000), () {
      AlertController.hide();
    });
  }
}
