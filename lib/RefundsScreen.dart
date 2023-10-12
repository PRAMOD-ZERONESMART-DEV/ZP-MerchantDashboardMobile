import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zerone_pay/model/RefundDataModel.dart';
import 'package:zerone_pay/ui/custom/FilterScreen.dart';

import 'package:http/http.dart' as http;
import 'package:zerone_pay/util/Globals.dart';

class RefundsScreen extends StatefulWidget {
  const RefundsScreen({super.key});

  @override
  State<StatefulWidget> createState() => RefundsScreenState();
}

class RefundsScreenState extends State<RefundsScreen> {
  bool isFilterScreenVisible = false;
  DateTime selectedStartDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime selectedEndDate = DateTime.now();
  String selectedStatus = 'All';
  String merchantId = "98";
  List<RefundDataModel> allRefunds = [];
  List<RefundDataModel> filteredRefunds = [];
  String txtNoData = 'Loading...';
  bool _isLoading = false;

  final ScrollController _scrollController = ScrollController();
  int currentPage = 1;
  int itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    getRefundsData();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        // User reached the end of the list, load more data
        if (!_isLoading) {
          getRefundsData();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> getRefundsData() async {
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
        txtNoData = 'No Data Found';
      });
    } else {
      // Encode the username and password to Base64
      String token = Globals.AUTH_TOKEN;
      print('token ==>>>>>>> $token');

      try {
        String baseUrl = Globals.BASE_URL;
        if (kDebugMode) {
          print(baseUrl);
        }
        final response = await http.get(
          Uri.parse(
              "$baseUrl/v1/merchant/refund?page=$currentPage&pageLimit=$itemsPerPage"),
          headers: {'Authorization': 'Bearer $token'},
        );

        Map<String, dynamic> responseData = jsonDecode(response.body);
        if (kDebugMode) {
          print('Response: ${response.body}');
        }
        if (response.statusCode == 200) {
          // API call successful, handle the response
          // print('Response: ${response.body}');

          List<dynamic> jsonDataList = responseData['data'];

          setState(() {
            // Append new data to the existing list
            allRefunds.addAll(
              jsonDataList
                  .map((jsonData) => RefundDataModel.fromJson(jsonData)),
            );
            filteredRefunds = allRefunds;

            if (filteredRefunds.isEmpty) {
              txtNoData = 'No Data Found';
            } else {
              txtNoData = '';
            }
          });

          if (kDebugMode) {
            print('orderData: $jsonDataList');
          }

          currentPage++;
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
    DateTime parsedDateTime = DateTime.parse(date);

    // Format the date in "dd/MM/yyyy" format
    String formattedDate = DateFormat('dd/MM/yyyy').format(parsedDateTime);
    return formattedDate;
  }

  void openScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FilterScreen(
          selectedStartDate: selectedStartDate,
          selectedEndDate: selectedEndDate,
          selectedStatus: selectedStatus,
          selectedMerchantId: merchantId,
          // Add a comma here
          onSubmit: (startDate, endDate, transactionId, status) {
            // _applyFilter(startDate, endDate, transactionId, status);
          },
        ),
      ),
    );
  }

  void _applyFilter(
      DateTime startDate, DateTime endDate, String status, String merchantId) {
    setState(() {
      filteredRefunds =
          filterTransactions(startDate, endDate, status, merchantId);
    });
    _closeFilterScreen(); // Close the filter screen after applying filters
  }

  void _openFilterScreen() {
    setState(() {
      isFilterScreenVisible = true;
    });
  }

  List<RefundDataModel> filterTransactions(
      DateTime startDate, DateTime endDate, String status, String merchantId) {
    return allRefunds.where((transaction) {
      final isStatusMatch = status == 'All' || transaction.state == status;
      final isMerchantMatch =
          merchantId.isEmpty || transaction.transaction == merchantId;
      return isStatusMatch && isMerchantMatch;
    }).toList();
  }

  void _closeFilterScreen() {
    setState(() {
      isFilterScreenVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
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
          'All Refunds',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24, // Update this value to change the title size
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: filteredRefunds.isEmpty
                  ? Center(
                      child: Text(
                        txtNoData,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: filteredRefunds.length + (_isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index < filteredRefunds.length) {
                          final transaction = filteredRefunds[index];
                          var textColor = Colors.green; // Default color

                          if (transaction.state == 'REFUNDING') {
                            textColor = Colors.orange;
                          } else if (transaction.state == 'FAIL') {
                            textColor = Colors.red;
                          } else if (transaction.state == 'REFUNDED') {
                            textColor = Colors.green;
                          } else if (transaction.state == 'REJECT') {
                            textColor = Colors.red;
                          } // Add more conditions for other status values

                          return Card(
                            // Wrap ListTile with Card
                            elevation: 2.0,
                            margin: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            child: ListTile(
                              title: Text(
                                'Trans. ID: ${transaction.transaction}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 2.0),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        const TextSpan(
                                          text: 'Amount: ',
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.black,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                        TextSpan(
                                          text: '\u{20B9}${transaction.amount}',
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 2.0),
                                  Row(
                                    children: [
                                      const SizedBox(height: 2.0),
                                      Container(
                                        padding: const EdgeInsets.all(1.0),
                                        child: Text(
                                          'Initiate Date: ${convertDate(transaction.createdAt)}',
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 15,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      // Add a spacer to push the next element to the right
                                      Container(
                                        padding: const EdgeInsets.all(1.0),
                                        child: Text(
                                          transaction.state,
                                          style: TextStyle(
                                            color: textColor,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2.0),
                                  Text(
                                    'Raised By: ${transaction.raisedBy}',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 13,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  const SizedBox(height: 2.0),
                                  Text(
                                    'Refund Reason: ${transaction.refundReason}',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else if (_isLoading) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        } else {
                          return Container();
                        }
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
