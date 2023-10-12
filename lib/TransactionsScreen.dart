import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:zerone_pay/ui/custom/FilterScreen.dart';
import 'package:zerone_pay/util/Globals.dart';

import 'model/OrderDataModel.dart';

import 'package:http/http.dart' as http;

import 'model/Transaction.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<StatefulWidget> createState() => TransactionsScreenState();
}

class TransactionsScreenState extends State<TransactionsScreen> {
  bool isTransactionScreenVisible = false;
  DateTime selectedStartDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime selectedEndDate = DateTime.now();
  String selectedStatus = 'All';
  String merchantId = "";
  String txtNoData = 'Loading...';

  List<Transaction> allTransactions = [];
  List<Transaction> filteredTransactions = [];

  bool _isLoading = false;
  bool fromTransaction = false;

  final ScrollController _scrollController = ScrollController();
  int currentPage = 1;
  int itemsPerPage = 10;

  @override
  void initState() {
    super.initState();

    getTransactionData();

    _scrollController.addListener(() {
      if (!fromTransaction) {
        if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
          // User reached the end of the list, load more data
          if (!_isLoading) {
            getTransactionData();
          }
        }
      }
    });
  }

  Future<void> loadOrders() async {
    final ordersBox = await Hive.openBox(Globals.TRANSACTION_BOX);
    setState(() {
      filteredTransactions = ordersBox.values.map((dynamic item) {
        if (item is Transaction) {
          return item;
        }
        // If the item is not an OrderDataModel, handle it accordingly
        // For example, you can return a default value or create a new OrderDataModel.
        return Transaction(
          id: 'defaultId',
          merchant: 'defaultMerchant',
          amount: 'defaultAmount',
          state: 'defaultState',
          createdAt: 'defaultCreatedAt',
          order: 'order',
          paymentMode: 'paymentMode',
          payerName: 'payerName',
          payerVPA: 'payerVPA',
        );
      }).toList();
      if (!filteredTransactions.isNotEmpty) {
        setState(() {
          txtNoData = 'No Data Found';
        });
      }
    });
  }

  saveInLocaleDb(List<OrderDataModel> data) async {
    final ordersBox = await Hive.openBox(Globals.ORDER_BOX);
    // Clear the existing data in the box
    await ordersBox.clear();

    for (final order in data) {
      await ordersBox.add(order);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> getTransactionData() async {
    if (_isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    if (await Globals.isOffline()) {
      Globals.showToast(context, 'Check internet connectivity.');
      loadOrders();
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
          Uri.parse(
              "$baseUrl/v1/merchant/transaction?page=$currentPage&pageLimit=$itemsPerPage"),
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
            allTransactions.addAll(
              jsonDataList.map((jsonData) => Transaction.fromJson(jsonData)),
            );
            filteredTransactions = allTransactions;

            if (filteredTransactions.isEmpty) {
              txtNoData = 'No Data Found';
            } else {
              txtNoData = '';
            }
          });

          //save in localdb
          //saveInLocaleDb(filteredOrders);

          if (kDebugMode) {
            print('orderData: $jsonDataList');
          }

          currentPage++;
        } else if (response.statusCode == 401) {
          String message = responseData['message'];
          Globals.showToast(context, message);
          Navigator.pushReplacementNamed(context, '/login');
        } else {
          setState(() {
            txtNoData = 'No Data Found';
          });

          String message = responseData['message'];
          Globals.showToast(context, message);
        }
      } catch (e) {
        // Handle other exceptions
        print('Error: $e');
        setState(() {
          txtNoData = 'No Data Found';
        });
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
          onSubmit: (startDate, endDate, status, transactionId) {
            // print('======>  startDate :  $startDate  ===> endDate  :  $endDate   ====>  status : $status    ======>  transactionId : $transactionId');
            _applyFilter(startDate, endDate, status, transactionId);
          },
        ),
      ),
    );
  }

  void _applyFilter(
      String startDate, String endDate, String status, String merchantId) {
    setState(() {
      filteredTransactions =
          filterTransactions(startDate, endDate, status, merchantId);
      if (kDebugMode) {
        print(filteredTransactions.length);
      }
      if (filteredTransactions.isNotEmpty) {
        setState(() {
          fromTransaction = true;
        });
      }
    });
    _closeFilterScreen(); // Close the filter screen after applying filters
  }

  void _openFilterScreen() {
    setState(() {
      isTransactionScreenVisible = true;
    });
  }

  List<Transaction> filterTransactions(
      String startDate, String endDate, String status, String merchantId) {
    return allTransactions.where((transaction) {
      DateTime dateTime = DateTime.parse(transaction.createdAt);

      if (startDate.isNotEmpty && endDate.isNotEmpty) {
        merchantId = '';
        var isDateInRange = false;

        if (startDate.isNotEmpty && endDate.isNotEmpty) {
          DateTime sDate = DateFormat('dd-MM-yyyy').parse(startDate);
          DateTime eDate = DateFormat('dd-MM-yyyy').parse(endDate);

          // print('Start Date: $sDate, End Date: $eDate');

          isDateInRange =
              dateTime.isBefore(eDate.add(const Duration(days: 1))) &&
                  dateTime.isAfter(sDate.subtract(const Duration(days: 1)));
          //print('isDateInRange: $isDateInRange');
        }

        final isStatusMatch = status == 'All' || transaction.state == status;

        final isMerchantMatch = transaction.merchant == merchantId;

        return (isDateInRange || isMerchantMatch) && isStatusMatch;
      } else if (merchantId.isNotEmpty) {
        final isStatusMatch = status == 'All' || transaction.state == status;

        final isMerchantMatch = transaction.merchant == merchantId;
        return (isMerchantMatch) && isStatusMatch;
      } else {
        final isStatusMatch = status == 'All' || transaction.state == status;
        return (isStatusMatch);
      }
    }).toList();
  }

  void _closeFilterScreen() {
    setState(() {
      isTransactionScreenVisible = false;
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
          'Total Transactions',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24, // Update this value to change the title size
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: filteredTransactions.isEmpty
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
                      itemCount: filteredTransactions.length + (_isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index < filteredTransactions.length) {
                          final transaction = filteredTransactions[index];
                          var textColor = Colors.green; // Default color

                          if (transaction.state == 'PENDING') {
                            textColor = Colors.orange;
                          } else if (transaction.state == 'FAIL') {
                            textColor = Colors.red;
                          } else if (transaction.state == 'SUCCESS') {
                            textColor = Colors.green;
                          } else if (transaction.state == 'REFUNDING') {
                            textColor = Colors.grey;
                          } // Add more conditions for other status values

                          return Card(
                            // Wrap ListTile with Card
                            elevation: 2.0,
                            margin: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            child: ListTile(
                              title: Text(
                                'Transaction ID: ${transaction.id}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(2.0),
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          const TextSpan(
                                            text: 'Amount:  ',
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.black,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                                '\u{20B9} ${transaction.amount}',
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 15,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 5.0),
                                  Text(
                                    'Paid At: ${convertDate(transaction.createdAt)}',
                                    // Format the date here
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(2.0),
                                        child: Text(
                                          'Payment Mode : ${transaction.paymentMode}',
                                          // Format the date here
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
                                        padding: const EdgeInsets.all(2.0),
                                        child: Text(
                                          transaction.state,
                                          style: TextStyle(
                                            color: textColor,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5.0),
                                  Text(
                                    'Payer Name : ${transaction.payerName}',
                                    // Format the date here
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  const SizedBox(height: 5.0),
                                  Text(
                                    'Payer VPA : ${transaction.payerVPA}',
                                    // Format the date here
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
      floatingActionButton: isTransactionScreenVisible
          ? null
          : FloatingActionButton(
              onPressed: openScreen,
              child: const Icon(Icons.filter_list),
            ),
    );
  }
}
