// import 'dart:ffi';

class scooterObject {
  final String scooterID;
  final String imei;
  final String address;
  final String g;
  final double lat;
  final double lng;
  final soc;
  final String status;

  scooterObject({
    this.imei = '',
    this.scooterID = '',
    this.address = '',
    this.g = '',
    this.lat = 0,
    this.lng = 0,
    this.soc = 0,
    this.status = 'available',
  });
}
