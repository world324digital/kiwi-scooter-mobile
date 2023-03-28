class TermsModel {
  String id = "";
  String title = "";
  String description = "";
  String img = "";

  TermsModel({
    required this.id,
    required this.title,
    required this.description,
    required this.img,
  });

  Map<String, dynamic> toMap() {
    Map<String, dynamic> returnedMap = {};
    returnedMap["id"] = this.id;
    returnedMap["title"] = this.title;
    returnedMap["description"] = this.description;
    returnedMap["img"] = this.img;

    return returnedMap;
  }

  TermsModel.fromMap({required data}) {
    try {
      this.id = data['id'] ?? "";
      this.title = data['title'] ?? "";
      this.description =
          data['description'] != null ? data['description'].toString() : "";
      this.img = data['img'] != null ? data['img'].toString() : "";
    } catch (e) {
      print(e);
      throw ("Couldn't get review  data correctly");
    }
  }
}
