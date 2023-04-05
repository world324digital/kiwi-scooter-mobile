class TransactionModel {
  String userName = "";
  String stripeId = "";
  String stripeTxId = "";
  String userId = "";
  String txType = "";
  double rideDistance = 0.0;
  double amount = 0.0;
  int rideTime = 0;

  TransactionModel({
    required this.userName,
    required this.stripeId,
    required this.stripeTxId,
    required this.userId,
    required this.txType,
    required this.rideDistance,
    required this.rideTime,
    required this.amount,
  });

  Map<String, dynamic> toMap() {
    Map<String, dynamic> returnedMap = {};
    returnedMap["userId"] = this.userId;
    returnedMap["userName"] = this.userName;
    returnedMap["stripeId"] = this.stripeId;
    returnedMap["stripeTxId"] = this.stripeTxId;
    returnedMap["txType"] = this.txType;
    returnedMap["rideDistance"] = this.rideDistance;
    returnedMap["amount"] = this.amount;
    returnedMap["rideTime"] = this.rideTime;
    return returnedMap;
  }

  TransactionModel.fromMap({required data}) {
    try {
      this.userId = data['userId'] ?? "";
      this.userName = data['userName'] ?? "";
      this.stripeId = data['stripeId'] ?? "";
      this.stripeTxId = data['stripeTxId'] ?? "";
      this.txType = data['txType'] ?? "";
      this.rideTime = data['rideTime'] != null ? data['rideTime'] : 0;
      this.rideDistance = data['rideDistance'] != null ? data['rideDistance'] : 0.0;
      this.amount = data['amount'] != null ? data['amount'] : 0.0;
    } catch (e) {
      print(e);
      throw ("Couldn't get transaction data correctly");
    }
  }
}
