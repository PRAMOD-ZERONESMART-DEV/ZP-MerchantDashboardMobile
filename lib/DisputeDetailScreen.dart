import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:zerone_pay/HomePageScreen.dart';
import 'package:zerone_pay/ui/custom/DisputeFilterScreen.dart';
import 'package:zerone_pay/util/Globals.dart';

import 'package:http/http.dart' as http;

import 'model/DisputeDataModel.dart';

class DisputeDetailScreen extends StatefulWidget {
  DisputeDetailScreen({Key? key, required this.disputeID}) : super(key: key);
  String disputeID = '';

  @override
  State<StatefulWidget> createState() => DisputeDetailScreenState();
}

class DisputeDetailScreenState extends State<DisputeDetailScreen> {
  bool isFilterScreenVisible = false;
  DateTime selectedStartDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime selectedEndDate = DateTime.now();
  String selectedStatus = 'All';
  String merchantId = '';
  String deadLineDate = '';
  Map<String, dynamic> responseData = {};
  Map<String, dynamic> transactionData = {};

  List<DisputeDataModel> allDispute = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    getDisputeData(widget.disputeID);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getDisputeData(String disputeId) async {
    if (_isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    if (await Globals.isOffline()) {
      Globals.showToast(context, 'Check internet connectivity.');
      setState(() {
        _isLoading = false;
      });
    } else {
      // Encode the username and password to Base64
      String token = Globals.AUTH_TOKEN;
      if (kDebugMode) {
        print('token ==>>>>>>> $token');
      }

      try {
        String baseUrl = Globals.BASE_URL;
        if (kDebugMode) {
          print(baseUrl);
        }
        final response = await http.get(
          Uri.parse("$baseUrl/v1/merchant/dispute/$disputeId"),
          headers: {'Authorization': 'Bearer $token'},
        );

        Map<String, dynamic> responseData = jsonDecode(response.body);
        if (kDebugMode) {
          print('Response: ${response.body}');
        }
        if (response.statusCode == 200) {
          // print('Response: ${response.body}');

          Map<String, dynamic> jsonData = responseData['data'];
          updateUI(jsonData);
          if (kDebugMode) {
            //print('dispute data  == >>   : $jsonData');
          }
        } else if (response.statusCode == 401) {
          String message = responseData['message'];
          Globals.showToast(context, '$message');
          Navigator.pushReplacementNamed(context, '/login');
        } else {
          String message = responseData['message'];
          Globals.showToast(context, '$message');
        }
      } catch (e) {
        // Handle other exceptions
        print('Error: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String convertDate(String date) {
    if (date != null) {
      try {
        DateTime parsedDateTime = DateTime.parse(date);
        return DateFormat('dd/MM/yyyy').format(parsedDateTime);
      } catch (e) {
        print('Error parsing date: $e');
        return ''; // Return an empty string when parsing fails
      }
    } else {
      return ''; // Return an empty string when input date is null
    }
  }

  void updateUI(Map<String, dynamic> jsonData) {
    setState(() {
      responseData = jsonData;
      transactionData = jsonData['transactionDetail'];
    });
  }

  @override
  Widget build(BuildContext context) {
    String deadlineDate = '';
    String createdAt = '';

    if (responseData['deadline'] != null) {
      deadlineDate = convertDate(responseData['deadline']);
    } else {
      deadlineDate = '';
    }

    if (responseData['createdAt'] != null) {
      createdAt = convertDate(responseData['createdAt']);
    } else {
      createdAt = '';
    }

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(
                  context); // This will navigate back to the previous screen
            },
          ),
          title: const Text(
            'Dispute Details',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24, // Update this value to change the title size
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(2.0),
                  child: const Text(
                    'Dispute Information :',
                    // Format the date here
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2.0),
                      child: const Text(
                        'Dispute ID:',
                        // Format the date here
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Add a spacer to push the next element to the right
                    Container(
                      decoration: BoxDecoration(
                        //border: Border.all(color: Colors.grey),
                        // Background color of the rectangular box
                        borderRadius: BorderRadius.circular(
                            5), // Border radius for rounded corners
                      ),
                      padding: EdgeInsets.all(10), // Padding inside the box
                      child: Text(
                        '${responseData['_id']}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10), // Add some space between the texts
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2.0),
                      child: const Text(
                        'Transaction ID:',
                        // Format the date here
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Add a spacer to push the next element to the right
                    Container(
                      decoration: BoxDecoration(
                        //border: Border.all(color: Colors.grey),
                        // Background color of the rectangular box
                        borderRadius: BorderRadius.circular(
                            5), // Border radius for rounded corners
                      ),
                      padding: EdgeInsets.all(10), // Padding inside the box
                      child: Text(
                        '${responseData['merchant'] ?? 'Nil'}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5.0),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2.0),
                      child: const Text(
                        'Amount:',
                        // Format the date here
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Add a spacer to push the next element to the right
                    Container(
                      decoration: BoxDecoration(
                        //border: Border.all(color: Colors.grey),
                        // Background color of the rectangular box
                        borderRadius: BorderRadius.circular(
                            5), // Border radius for rounded corners
                      ),
                      padding: EdgeInsets.all(10), // Padding inside the box
                      child: Text(
                        '${responseData['amount'] ?? 'Nil'}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5.0),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2.0),
                      child: const Text(
                        'Dispute Type:',
                        // Format the date here
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Add a spacer to push the next element to the right
                    Container(
                      decoration: BoxDecoration(
                        // border: Border.all(color: Colors.grey),
                        // Background color of the rectangular box
                        borderRadius: BorderRadius.circular(
                            5), // Border radius for rounded corners
                      ),
                      padding: EdgeInsets.all(10), // Padding inside the box
                      child: Text(
                        '${responseData['disputeType'] ?? 'Nil'.toString().replaceAll('_', ' ')}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5.0),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2.0),
                      child: const Text(
                        'Deadline:',
                        // Format the date here
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Add a spacer to push the next element to the right
                    Container(
                      decoration: BoxDecoration(
                        // border: Border.all(color: Colors.grey),
                        // Background color of the rectangular box
                        borderRadius: BorderRadius.circular(
                            5), // Border radius for rounded corners
                      ),
                      padding: EdgeInsets.all(10), // Padding inside the box
                      child: Text(
                        deadlineDate ?? 'Nil',
                        style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5.0),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2.0),
                      child: const Text(
                        'Description:',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Expanded(
                      // Use Expanded widget to allow multiline text
                      child: Container(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          responseData['description'] ?? 'Nil',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5.0),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2.0),
                      child: const Text(
                        'Complaints Name:',
                        // Format the date here
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Add a spacer to push the next element to the right
                    Container(
                      decoration: BoxDecoration(
                        // border: Border.all(color: Colors.grey),
                        // Background color of the rectangular box
                        borderRadius: BorderRadius.circular(
                            5), // Border radius for rounded corners
                      ),
                      padding: const EdgeInsets.all(10),
                      // Padding inside the box
                      child: Text(
                        '${responseData['complainantsName'] ?? 'Nil'}'
                            .toString()
                            .toUpperCase(),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5.0),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2.0),
                      child: const Text(
                        'Complaints Phone:',
                        // Format the date here
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Add a spacer to push the next element to the right
                    Container(
                      decoration: BoxDecoration(
                        // border: Border.all(color: Colors.grey),

                        // Background color of the rectangular box
                        borderRadius: BorderRadius.circular(
                            5), // Border radius for rounded corners
                      ),
                      padding: const EdgeInsets.all(10),
                      // Padding inside the box
                      child: Text(
                        '${responseData['complainantsPhone'] ?? 'Nil'}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5.0),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2.0),
                      child: const Text(
                        'Complaints Email:',
                        // Format the date here
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Add a spacer to push the next element to the right
                    Container(
                      decoration: BoxDecoration(
                        // border: Border.all(color: Colors.grey),

                        // Background color of the rectangular box
                        borderRadius: BorderRadius.circular(
                            5), // Border radius for rounded corners
                      ),
                      padding: const EdgeInsets.all(10),
                      // Padding inside the box
                      child: Text(
                        '${responseData['complainantsEmail'] ?? 'Nil'}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5.0),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2.0),
                      child: const Text(
                        'Complaints Status:',
                        // Format the date here
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Add a spacer to push the next element to the right
                    Container(
                      decoration: BoxDecoration(
                        // border: Border.all(color: Colors.grey),

                        // Background color of the rectangular box
                        borderRadius: BorderRadius.circular(
                            5), // Border radius for rounded corners
                      ),
                      padding: EdgeInsets.all(10), // Padding inside the box
                      child: Text(
                        '${responseData['state'] ?? 'Nil'}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5.0),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2.0),
                      child: const Text(
                        'AccountNo:',
                        // Format the date here
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Add a spacer to push the next element to the right
                    Container(
                      decoration: BoxDecoration(
                        // border: Border.all(color: Colors.grey),

                        // Background color of the rectangular box
                        borderRadius: BorderRadius.circular(
                            5), // Border radius for rounded corners
                      ),
                      padding: EdgeInsets.all(10), // Padding inside the box
                      child: Text(
                        '${responseData['complainantsAccountNo'] ?? 'Nil'}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5.0),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2.0),
                      child: const Text(
                        'Complaints Ifsc:',
                        // Format the date here
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Add a spacer to push the next element to the right
                    Container(
                      decoration: BoxDecoration(
                        // border: Border.all(color: Colors.grey),

                        // Background color of the rectangular box
                        borderRadius: BorderRadius.circular(
                            5), // Border radius for rounded corners
                      ),
                      padding: EdgeInsets.all(10), // Padding inside the box
                      child: Text(
                        '${responseData['complainantsIfsc'] ?? 'Nil'}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 5.0),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2.0),
                      child: const Text(
                        'Bank Code:',
                        // Format the date here
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Add a spacer to push the next element to the right
                    Container(
                      decoration: BoxDecoration(
                        // border: Border.all(color: Colors.grey),

                        // Background color of the rectangular box
                        borderRadius: BorderRadius.circular(
                            5), // Border radius for rounded corners
                      ),
                      padding: EdgeInsets.all(10), // Padding inside the box
                      child: Text(
                        '${responseData['bankReasonCode'] ?? 'Nil'}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5.0),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2.0),
                      child: const Text(
                        'Dispute Create Date:',
                        // Format the date here
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Add a spacer to push the next element to the right
                    Container(
                      decoration: BoxDecoration(
                        //border: Border.all(color: Colors.grey),

                        // Background color of the rectangular box
                        borderRadius: BorderRadius.circular(
                            5), // Border radius for rounded corners
                      ),
                      padding: EdgeInsets.all(10), // Padding inside the box
                      child: Text(
                        createdAt ?? 'nil',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20.0),
                Container(
                  padding: const EdgeInsets.all(2.0),
                  child: const Text(
                    'Transaction Information :',
                    // Format the date here
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2.0),
                      child: const Text(
                        'Order ID:',
                        // Format the date here
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Add a spacer to push the next element to the right
                    Container(
                      decoration: BoxDecoration(
                        //border: Border.all(color: Colors.grey),
                        // Background color of the rectangular box
                        borderRadius: BorderRadius.circular(
                            5), // Border radius for rounded corners
                      ),
                      padding: EdgeInsets.all(10), // Padding inside the box
                      child: Text(
                        '${transactionData['order'] ?? 'Nil'}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10), // Add some space between the texts
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2.0),
                      child: const Text(
                        'M. Trade No:',
                        // Format the date here
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Add a spacer to push the next element to the right
                    Container(
                      decoration: BoxDecoration(
                        //border: Border.all(color: Colors.grey),
                        // Background color of the rectangular box
                        borderRadius: BorderRadius.circular(
                            5), // Border radius for rounded corners
                      ),
                      padding: EdgeInsets.all(10), // Padding inside the box
                      child: Text(
                        '${transactionData['merchantTradeNo'] ?? 'Nil'}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10), // Add some space between the texts
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2.0),
                      child: const Text(
                        'Dispute Status:',
                        // Format the date here
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Add a spacer to push the next element to the right
                    Container(
                      decoration: BoxDecoration(
                        //border: Border.all(color: Colors.grey),
                        // Background color of the rectangular box
                        borderRadius: BorderRadius.circular(
                            5), // Border radius for rounded corners
                      ),
                      padding: EdgeInsets.all(10), // Padding inside the box
                      child: Text(
                        '${transactionData['state'] ?? 'Nil'}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10), // Add some space between the texts
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2.0),
                      child: const Text(
                        'Amount:',
                        // Format the date here
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Add a spacer to push the next element to the right
                    Container(
                      decoration: BoxDecoration(
                        //border: Border.all(color: Colors.grey),
                        // Background color of the rectangular box
                        borderRadius: BorderRadius.circular(
                            5), // Border radius for rounded corners
                      ),
                      padding: EdgeInsets.all(10), // Padding inside the box
                      child: Text(
                        '${transactionData['amount'] ?? 'Nil'}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10), // Add some space between the texts
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2.0),
                      child: const Text(
                        'Gateway Status:',
                        // Format the date here
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Add a spacer to push the next element to the right
                    Container(
                      decoration: BoxDecoration(
                        //border: Border.all(color: Colors.grey),
                        // Background color of the rectangular box
                        borderRadius: BorderRadius.circular(
                            5), // Border radius for rounded corners
                      ),
                      padding: EdgeInsets.all(10), // Padding inside the box
                      child: Text(
                        '${transactionData['gatewayTxnStatus'] ?? 'Nil'}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10), // Add some space between the texts
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2.0),
                      child: const Text(
                        'Payment Channel:',
                        // Format the date here
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Add a spacer to push the next element to the right
                    Container(
                      decoration: BoxDecoration(
                        //border: Border.all(color: Colors.grey),
                        // Background color of the rectangular box
                        borderRadius: BorderRadius.circular(
                            5), // Border radius for rounded corners
                      ),
                      padding: EdgeInsets.all(10), // Padding inside the box
                      child: Text(
                        '${transactionData['paymentChannel'] ?? 'Nil'}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10), // Add some space between the texts
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2.0),
                      child: const Text(
                        'Settlement Status:',
                        // Format the date here
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Add a spacer to push the next element to the right
                    Container(
                      decoration: BoxDecoration(
                        //border: Border.all(color: Colors.grey),
                        // Background color of the rectangular box
                        borderRadius: BorderRadius.circular(
                            5), // Border radius for rounded corners
                      ),
                      padding: EdgeInsets.all(10), // Padding inside the box
                      child: Text(
                        '${transactionData['settlementStatus'] ?? 'Nil'}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10), // Add some space between the texts
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2.0),
                      child: const Text(
                        'Gateway TransID:',
                        // Format the date here
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Add a spacer to push the next element to the right
                    Expanded(
                      // Use Expanded widget to allow multiline text
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                        child: Text(
                          '${transactionData['gatewayTransactionId'] ?? 'Nil'}',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                          ),
                          maxLines: null,
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10), // Add some space between the texts
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2.0),
                      child: const Text(
                        'Merchant ReqID:',
                        // Format the date here
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Add a spacer to push the next element to the right
                    Container(
                      decoration: BoxDecoration(
                        //border: Border.all(color: Colors.grey),
                        // Background color of the rectangular box
                        borderRadius: BorderRadius.circular(
                            5), // Border radius for rounded corners
                      ),
                      padding: EdgeInsets.all(10), // Padding inside the box
                      child: Text(
                        '${transactionData['merchantRequestId'] ?? 'Nil'}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10), // Add some space between the texts
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2.0),
                      child: const Text(
                        'Payer Name:',
                        // Format the date here
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Add a spacer to push the next element to the right
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10.0),
                        // Padding inside the box
                        child: Text(
                          '${transactionData['payerName'] ?? 'Nil'}',
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10), // Add some space between the texts
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2.0),
                      child: const Text(
                        'Payee VPA:',
                        // Format the date here
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Add a spacer to push the next element to the right
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10.0),
                        // Padding inside the box
                        child: Text(
                          '${transactionData['payeeVPA'] ?? 'Nil'}',
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10), // Add some space between the texts
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2.0),
                      child: const Text(
                        'Payer VPA:',
                        // Format the date here
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Add a spacer to push the next element to the right
                    Container(
                      decoration: BoxDecoration(
                        //border: Border.all(color: Colors.grey),
                        // Background color of the rectangular box
                        borderRadius: BorderRadius.circular(
                            5), // Border radius for rounded corners
                      ),
                      padding: const EdgeInsets.all(2.0),
                      // Padding inside the box
                      child: Text(
                        '${transactionData['payerVPA'] ?? 'Nil'}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
                // Add more Text widgets as needed
              ],
            ),
          ),
        ));
  }
}
