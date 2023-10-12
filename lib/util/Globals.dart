import 'dart:math';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Globals {
  //static String BASE_URL = "http://3.7.79.65:3001/zerone-pay"; //dev
  static String BASE_URL = "https://api.zeronepay.com/pg";
  static String AUTH_TOKEN = "";
  static String USER_DATA = "";
  static String CALL_BACK_URL = "";
  static String LOGIN_BOX = 'loginBox';
  static String TRANSACTION_BOX = 'transactionBox';
  static String ORDER_BOX = 'orderBox';
  static String SETTLEMENT_BOX = 'settlementBox';
  static String REFUND_BOX = 'refundBox';
  static String DISPUTE_BOX = 'disputeBox';

  static void showAlert(BuildContext context, String title, String subTitle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(subTitle),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  static void showToast(BuildContext context, String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black54,
      textColor: Colors.white,
    );
  }

  static String generateUniqueTradeNumber() {
    DateTime now = DateTime.now();
    String timestampMicros = now.microsecondsSinceEpoch.toString();
    String randomNumber =
        _generateRandomNumberString(18 - timestampMicros.length);

    String tradeNumber = timestampMicros + randomNumber;
    return tradeNumber;
  }

  static String _generateRandomNumberString(int length) {
    Random random = Random();
    String randomString = "";
    for (int i = 0; i < length; i++) {
      randomString += random.nextInt(10).toString();
    }
    return randomString;
  }

  static Future<bool> isOffline() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult == ConnectivityResult.none;
  }
}
