import 'dart:async';
import 'dart:io';

import 'package:KiwiCity/Helpers/constant.dart';
import 'package:KiwiCity/Helpers/local_storage.dart';
import 'package:KiwiCity/Models/card_model.dart';
import 'dart:convert';
import 'dart:math';

import 'package:KiwiCity/Models/price_model.dart';
import 'package:KiwiCity/Models/review_model.dart';
import 'package:KiwiCity/Models/transaction_model.dart';
import 'package:KiwiCity/Models/scooterObject.dart';
import 'package:KiwiCity/Models/term_model.dart';
import 'package:KiwiCity/Models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:KiwiCity/Models/location_model.dart';
// import 'package:s4s_mobileapp/account/page_account.dart';
// import 'dart:convert';
// import 'dart:developer';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Create a reference to the Firebase Storage bucket
  final storageRef = FirebaseStorage.instance.ref();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      // 'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );

  /***********************************
   * @Auth: world.digital.dev@gmail.com
   * @Date: 2023.04.10
   * @Desc: Initialize Firebase
   */

  Future<FirebaseApp> initializeFirebase() async {
    FirebaseApp firebaseApp = await Firebase.initializeApp();

    return firebaseApp;
  }

  /***********************************************
  * @Auth: world324digital@gmail.com
  * @Date: 2023.04.10
  * @Desc: Google Sigin
  */
  Future<UserCredential?> signInwithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      print(e.message);
      throw e;
    }
  }

  /// Generates a cryptographically secure random nonce, to be included in a
  /// credential request.
  String generateNonce([int length = 32]) {
    final charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /***********************************************
  * @Auth: world324digital@gmail.com
  * @Date: 2023.04.10
  * @Desc: Apple SignIn
  */
  Future<User> signInWithApple() async {
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);

    try {
      // Request credential for the currently signed in Apple account.
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      print(appleCredential);

      // Create an `OAuthCredential` from the credential returned by Apple.
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      // Sign in the user with Firebase. If the nonce we generated earlier does
      // not match the nonce in `appleCredential.identityToken`, sign in will fail.
      final authResult = await _auth.signInWithCredential(oauthCredential);

      // final displayName =
      //     '${appleCredential.givenName} ${appleCredential.familyName}';
      // final userEmail = '${appleCredential.email}';

      final firebaseUser = authResult.user!;
      // print(displayName);
      // await firebaseUser.updateProfile(displayName: displayName);
      // await firebaseUser.updateEmail(userEmail);

      return firebaseUser;
    } catch (exception) {
      print(exception);
      throw exception;
    }
  }

  Future<String> registerWithEmail(params) async {
    try {
      var user = await _auth.createUserWithEmailAndPassword(
          email: params['email'], password: params['password']);
      return user.user!.uid;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'WEAK';
      } else if (e.code == 'email-already-in-use') {
        return 'DUPLICATED';
      }
      return 'FAILED';
    } catch (e) {
      rethrow;
    }
  }

  /******************************
   * @Auth: world.digital.dev@gmail.com
   * @Date: 2023.04.11
   * @Desc: Create User Profile
   */
  Future<bool> createUser(UserModel userModel) async {
    try {
      return await firestore
          .collection('users')
          .doc(userModel.id)
          .set(userModel.toMap())
          .then((value) async {
        return true;
      }).onError((error, stackTrace) {
        print(error);
        return false;
      });
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> updateUser(UserModel userModel) async {
    try {
      return await firestore
          .collection('users')
          .doc(userModel.id)
          .update(userModel.toMap())
          .then((value) async {
        return true;
      }).onError((error, stackTrace) {
        print(error);
        return false;
      });
    } catch (e) {
      print(e);
      return false;
    }
  }

  /******************************
   * @Auth: world.digital.dev@gmail.com
   * @Date: 2023.04.02
   * @Desc: Get UserData
   */
  Future<UserModel?> getUser(String uid) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> querySnapshot =
          await firestore.collection('users').doc(uid).get();
      print(querySnapshot);
      if (querySnapshot.exists) {
        UserModel user = UserModel.fromMap(data: querySnapshot, id: uid);
        return user;
      } else {
        return null;
      }
    } catch (e) {
      print(e);
      throw e;
      // return null;
    }
  }

  emailVerify() async {
    User? user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
      return 'SENT_VERIFY';
    } else {
      return null;
    }
  }

  Future<void> signOut() async {
    // await prefs.setBool('loggedin', false);
    await storeDataToLocal(
        key: AppLocalKeys.IS_LOGIN, value: false, type: StorableDataType.BOOL);
    await storeDataToLocal(
        key: AppLocalKeys.EMAIL, value: "", type: StorableDataType.String);
    await storeDataToLocal(
        key: AppLocalKeys.UID, value: "", type: StorableDataType.String);
    await _auth.signOut();
    // switch (loginType) {
    //   case LoginType.GOOGLE:
    //     await _googleSignIn.signOut();
    //     break;
    //     case LoginType.APPLE:
    //   default:
    // }
  }

  Future<UserCredential> signInWithEmail(
      {required String email, required String password}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      UserCredential _user = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      await _auth.currentUser?.reload();
      // if (_auth.currentUser?.emailVerified == true) {
      //   await prefs.setString('email', email);
      //   await prefs.setBool('loggedin', true);
      //   return 'VERIFIED';
      // } else {
      //   return 'NOT_VERIFIED';
      // }
      return _user;
    } on FirebaseAuthException catch (e) {
      // if (e.code == 'user-not-found') {
      //   return 'USER_NOT_FOUND';
      // } else if (e.code == 'wrong-password') {
      //   return 'WRONG_PASSWORD';
      // } else if (e.code == 'invalid-email') {
      //   return 'INVALID_EMAIL';
      // } else if (e.code == 'user-disabled') {
      //   return 'USER_DISABLED';
      // } else {
      //   return 'FAILED';
      // }
      throw e;
    }
    // return null;
  }

  Future<void> updatePassword({required String newPassword}) async {
    print("jerererere");
    if (_auth.currentUser != null)
      _auth.currentUser!.updatePassword(newPassword);
  }

  Future<String> resetPassword({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email);
    return 'EMAIL_SENT';
  }

  /*******************************
   * @Auth: world.digital.dev@gmail.com
   * @Date: 2023.04.02
   * @Desc: check scooter id is valid
   */
  Future<String> isValidScooterID({required String scooterID}) async {
    var res = await firestore
        .collection('scooters')
        .where('id', isEqualTo: scooterID)
        .get();
    String imei = '';
    res.docs.forEach((doc) {
      imei = doc.id;
    });
    return imei;
  }

  /*******************************
   * @Auth: world.digital.dev@gmail.com
   * @Date: 2023.04.02
   * @Desc: Get Prices
   */
  Future<List<PriceModel>> getPrices() async {
    try {
      QuerySnapshot querySnapshot =
          await firestore.collection('pricings').get();

      List<PriceModel> _prices = [];
      querySnapshot.docs.forEach((doc) {
        print(doc.id);
        _prices.add(PriceModel.fromMap(data: doc.data()));
      });
      return _prices;
    } catch (e) {
      throw e;
    }
  }

  Future<List<ReviewModel>> getReviews(String userId) async {
    try {
      QuerySnapshot querySnapshot = await firestore
          .collection('reviews')
          .where("userId", isEqualTo: userId)
          // .orderBy('endTime', descending: true) // Order by a field
          .get();
      print("================");
      print(querySnapshot.docs);
      List<ReviewModel> _reviews = [];

      querySnapshot.docs.forEach((doc) {
        _reviews.add(ReviewModel.fromMap(data: doc.data()));
      });
      return _reviews;
    } catch (e) {
      throw e;
    }
  }

  Future<List<TermsModel>> getTerms() async {
    try {
      List<TermsModel> lists = [];
      QuerySnapshot querySnapshot = await firestore
          .collection('userAgreement')
          // .orderBy('startTime', descending: true)
          .get();
      print("================");
      print(querySnapshot.docs);

      querySnapshot.docs.forEach((doc) {
        print(doc.data());
        lists.add(TermsModel.fromMap(data: doc.data()));
      });
      return lists;
    } catch (e) {
      throw e;
    }
  }

  Future<List<dynamic>> getPoints(String reviewId) async {
    try {
      List<dynamic> lists = [];
      final review = await firestore.collection('reviews').doc(reviewId).get();
      if (review.exists) {
        Map<String, dynamic>? data = review.data();
        lists = data?['points'];
      }
      return lists;
    } catch (e) {
      throw e;
    }
  }

  Future<String> getVideo() async {
    try {
      String url = "";
      QuerySnapshot querySnapshot = await firestore
          .collection('howToRide')
          // .orderBy('startTime', descending: true)
          .get();

      final data = querySnapshot.docs[0].data() as Map<String, dynamic>;
      url = data["url"].toString();

      return url;
    } catch (e) {
      throw e;
    }
  }

  /***********************
   * @Auth: world.digital.dev@gmail.com
   * @Date: 2023.04.04
   * @Desc: Update User Card
   */
  Future<bool> updateCard(UserModel user) async {
    try {
      await firestore.collection('users').doc(user.id).set(user.toMap());
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> updateInUseStatus(
      {required String imei, required String useStatus}) async {
    try {
      final data = {"status": useStatus};
      await firestore
          .collection('scooters')
          .doc(imei)
          .set(data, SetOptions(merge: true));
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  /********************************
   * @Auth: world324digital
   * @Date: 2023.04.16
   * @Desc: Upload Image
   */
  Future<String> uploadImage(
      {required File file, required String fileName}) async {
    try {
      //Upload to Firebase
      var snapshot = await storageRef.child('images/${fileName}').putFile(file);

      var downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print(e);
      throw e;
    }
  }

  /****************************Review Part ***************/
  Future<String> createReview() async {
    try {
      // await firestore.collection('reviews').doc().set(review.toMap());
      DocumentReference docRef = firestore
          .collection('reviews')
          .doc(); // Create a new document reference with a unique ID
      String docId = docRef.id;
      await docRef.set({"id": docId});
      return docId;
      // await docRef.set(review.toJson());
      // await docRef.set({points: points});
    } catch (e) {
      print(e);
      throw e;
    }
  }

  /****************************Review Part ***************/
  Future<void> updateReview(ReviewModel review) async {
    try {
      await firestore
          .collection('reviews')
          .doc(review.id)
          .update(review.toMap());
    } catch (e) {
      print(e);
      throw e;
    }
  }

  /****************************Review Part ***************/
  Future<void> saveRidePoints(
      String docId, List<Map<String, dynamic>> points) async {
    try {
      await firestore
          .collection('reviews')
          .doc(docId)
          .set({"points": points}, SetOptions(merge: true));
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<void> createTransaction(TransactionModel transaction) async {
    try {
      await firestore.collection('transactions').doc().set(transaction.toMap());
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<List<TransactionModel>> getTransactions(String userId) async {
    try {
      QuerySnapshot querySnapshot = await firestore
          .collection('transactions')
          .where("userId", isEqualTo: userId)
          // .orderBy('startTime', descending: true)
          .get();
      print("================");
      print(querySnapshot.docs);
      List<TransactionModel> _transactions = [];

      querySnapshot.docs.forEach((doc) {
        print(doc.data());
        _transactions.add(TransactionModel.fromMap(data: doc.data()));
      });
      return _transactions;
    } catch (e) {
      throw e;
    }
  }

  // /*******************
  //  * Get Scooter Stream by ID
  //  */
  // final Stream<DocumentSnapshot<Map<String, dynamic>>> getScooterByID(
  //     String scooterID) {
  //   return firestore.collection("scooters").doc(scooterID).snapshots();
  // }

// Future<String> checkVerify() async {
//   await _auth.currentUser?.reload();
//   if (_auth.currentUser?.emailVerified == true) {
//     return 'VERIFIED';
//   } else {
//     return 'NOT_VERIFIED';
//   }
// }
//
// checkUser() async {
//   try {p
//     await _auth.currentUser?.reload();
//     return _auth.currentUser;
//   } on FirebaseAuthException catch (e) {
//     if (e.code == 'user-not-found') {
//       return 'USER_NOT_FOUND';
//     } else if (e.code == 'wrong-password') {
//       return 'WRONG_PASSWORD';
//     } else if (e.code == 'invalid-email') {
//       return 'INVALID_EMAIL';
//     } else if (e.code == 'user-disabled') {
//       return 'USER_DISABLED';
//     }
//   }
// }
}
