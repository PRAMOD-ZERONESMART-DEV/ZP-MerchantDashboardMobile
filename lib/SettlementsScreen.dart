import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zerone_pay/model/SettlementDataModel.dart';
import 'package:zerone_pay/ui/custom/FilterScreen.dart';
import 'package:zerone_pay/util/Globals.dart';

import 'package:http/http.dart' as http;

class SettlementsScreen extends StatefulWidget {
  const SettlementsScreen({super.key});

  @override
  State<StatefulWidget> createState() => SettlementsScreenState();
}

class SettlementsScreenState extends State<SettlementsScreen> {
  bool isFilterScreenVisible = false;
  DateTime selectedStartDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime selectedEndDate = DateTime.now();
  String selectedStatus = 'All';
  String merchantId = "";
  String txtNoData = 'Loading...';
  List<SettlementDataModel> allSettlements = [];
  List<SettlementDataModel> filteredSettlements = [];

  bool _isLoading = false;

  final ScrollController _scrollController = ScrollController();
  int currentPage = 1;
  int itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    getSettlementData();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        // User reached the end of the list, load more data
        if (!_isLoading) {
          getSettlementData();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> getSettlementData() async {
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
              "$baseUrl/v1/merchant/settlements?page=$currentPage&pageLimit=$itemsPerPage"),
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
            allSettlements.addAll(
              jsonDataList
                  .map((jsonData) => SettlementDataModel.fromJson(jsonData)),
            );
            filteredSettlements = allSettlements;

            if(allSettlements.isEmpty){
              txtNoData =  'No Data Found';
            }else{
              txtNoData =  '';
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
          setState(() {
            txtNoData = 'No Data Found';
          });
          String message = responseData['message'];
          Globals.showToast(context, '$message');
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
      filteredSettlements =
          filterTransactions(startDate, endDate, status, merchantId);
    });
    _closeFilterScreen(); // Close the filter screen after applying filters
  }

  void _openFilterScreen() {
    setState(() {
      isFilterScreenVisible = true;
    });
  }

  List<SettlementDataModel> filterTransactions(
      String startDate, String endDate, String status, String merchantId) {
    return allSettlements.where((transaction) {
      DateTime transactionDate =
          DateFormat('dd-MM-yyyy').parse(transaction.initiationDate);

      if (startDate.isNotEmpty && endDate.isNotEmpty) {
        merchantId = '';
        var isDateInRange = false;

        if (startDate.isNotEmpty && endDate.isNotEmpty) {
          DateTime sDate = DateFormat('dd-MM-yyyy').parse(startDate);
          DateTime eDate = DateFormat('dd-MM-yyyy').parse(endDate);

          // print('Start Date: $sDate, End Date: $eDate');

          isDateInRange = transactionDate
                  .isBefore(eDate.add(const Duration(days: 1))) &&
              transactionDate.isAfter(sDate.subtract(const Duration(days: 1)));
          //print('isDateInRange: $isDateInRange');
        }

        final isStatusMatch =
            status == 'All' || transaction.txnStatus == status;

        final isMerchantMatch = transaction.id == merchantId;

        return (isDateInRange || isMerchantMatch) && isStatusMatch;
      } else if (merchantId.isNotEmpty) {
        final isStatusMatch =
            status == 'All' || transaction.txnStatus == status;

        final isMerchantMatch = transaction.merchant == merchantId;
        return (isMerchantMatch) && isStatusMatch;
      } else {
        final isStatusMatch =
            status == 'All' || transaction.txnStatus == status;
        return (isStatusMatch);
      }
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
          'Settlements',
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
              child: filteredSettlements.isEmpty
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
                      itemCount:
                          filteredSettlements.length + (_isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index < filteredSettlements.length) {
                          final transaction = filteredSettlements[index];
                          var textColor = Colors.green; // Default color

                          if (transaction.txnStatus == 'PENDING') {
                            textColor = Colors.orange;
                          } else if (transaction.txnStatus == 'FAIL') {
                            textColor = Colors.red;
                          } else if (transaction.txnStatus == 'SUCCESS') {
                            textColor = Colors.green;
                          } else if (transaction.txnStatus == 'REJECT') {
                            textColor = Colors.red;
                          } // Add more conditions for other status values

                          return Card(
                            // Wrap ListTile with Card
                            elevation: 2.0,
                            margin: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            child: ListTile(
                              title: Text(
                                'Merchant ID: ${transaction.id}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        const TextSpan(
                                          text: 'Amount:  ',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 15,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                        TextSpan(
                                          text:
                                              '\u{20B9} ${transaction.amount}',
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const SizedBox(height: 2.0),
                                      Container(
                                        padding: const EdgeInsets.all(1.0),
                                        child: Text(
                                          'Mode: ${transaction.Mode}',
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
                                          transaction.txnStatus,
                                          style: TextStyle(
                                            color: textColor,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    'Initiate Date: ${convertDate(transaction.initiationDate)}',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  const SizedBox(height: 2.0),
                                  Text(
                                    'UTR: ${transaction.utr}',
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
      // floatingActionButton: isFilterScreenVisible
      //     ? null
      //     : FloatingActionButton(
      //         onPressed: openScreen,
      //         child: const Icon(Icons.filter_list),
      //       ),
    );
  }
}
