class TermsModel {
  String id = "";
  String enTitle = "";
  String enDescription = "";
  String elTitle = "";
  String elDescription = "";
  String lvTitle = "";
  String lvDescription = "";
  String img = "";

  TermsModel({
    required this.id,
    required this.enTitle,
    required this.enDescription,
    required this.elTitle,
    required this.elDescription,
    required this.lvTitle,
    required this.lvDescription,
    required this.img,
  });

  Map<String, dynamic> toMap() {
    Map<String, dynamic> returnedMap = {};
    returnedMap["id"] = this.id;
    returnedMap["enTitle"] = this.enTitle;
    returnedMap["enDescription"] = this.enDescription;
    returnedMap["elTitle"] = this.elTitle;
    returnedMap["elDescription"] = this.elDescription;
    returnedMap["lvTitle"] = this.lvTitle;
    returnedMap["lvDescription"] = this.lvDescription;
    returnedMap["img"] = this.img;

    return returnedMap;
  }

  TermsModel.fromMap({required data}) {
    try {
      this.id = data['id'] ?? "";
      this.enTitle = data['enTitle'] ?? "";
      this.enDescription =
          data['enDescription'] != null ? data['enDescription'].toString() : "";
      this.elTitle = data['elTitle'] ?? "";
      this.elDescription =
          data['elDescription'] != null ? data['elDescription'].toString() : "";
      this.lvTitle = data['lvTitle'] ?? "";
      this.lvDescription =
          data['lvDescription'] != null ? data['lvDescription'].toString() : "";
      this.img = data['img'] != null ? data['img'].toString() : "";
    } catch (e) {
      print(e);
      throw ("Couldn't get review  data correctly");
    }
  }
}
