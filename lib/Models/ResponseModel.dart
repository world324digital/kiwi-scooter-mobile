// import 'dart:ffi';

class ResponseModel {
  final bool result;
  final String message;
  final data;
  ResponseModel({
    this.result = false,
    this.message = "",
    this.data,
  });
  ResponseModel.fromJson(Map<String, dynamic> json)
      : result = json['result'],
        message = json['message'],
        data = json['data'];

  Map<String, dynamic> toJson() => {
        'name': result,
        'email': message,
        'data': data,
      };
}
