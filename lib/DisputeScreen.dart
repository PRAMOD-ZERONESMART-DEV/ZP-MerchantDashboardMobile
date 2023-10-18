import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:zerone_pay/HomePageScreen.dart';
import 'package:zerone_pay/ui/custom/DisputeFilterScreen.dart';
import 'package:zerone_pay/util/Globals.dart';

import 'package:http/http.dart' as http;

import 'DisputeDetailScreen.dart';
import 'model/DisputeDataModel.dart';

class DisputeScreen extends StatefulWidget {
  const DisputeScreen({super.key});

  @override
  State<StatefulWidget> createState() => DisputeScreenState();
}

class DisputeScreenState extends State<DisputeScreen> {
  bool isFilterScreenVisible = false;
  DateTime selectedStartDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime selectedEndDate = DateTime.now();
  String selectedStatus = 'All';
  String merchantId = '';
  String deadLineDate = '';
  String txtNoData = 'Loading...';
  List<DisputeDataModel> allDispute = [];
  List<DisputeDataModel> filteredDispute = [];

  bool _isLoading = false;

  final ScrollController _scrollController = ScrollController();
  //int currentPage = 1;
  //int itemsPerPage = 10;

  @override
  void initState() {
    super.initState();

    getDisputeData();

    // _scrollController.addListener(() {
    //   if (_scrollController.position.pixels ==
    //       _scrollController.position.maxScrollExtent) {
    //     // User reached the end of the list, load more data
    //     if (!_isLoading) {
    //       getSettlementData();
    //     }
    //   }
    // });
  }

  Future<void> loadDisputes() async {
    final ordersBox = await Hive.openBox(Globals.DISPUTE_BOX);
    setState(() {
      filteredDispute = ordersBox.values.map((dynamic item) {
        if (item is DisputeDataModel) {
          return item;
        }
        // If the item is not an OrderDataModel, handle it accordingly
        // For example, you can return a default value or create a new OrderDataModel.
        return DisputeDataModel(
          id: 'defaultId',
          merchant: 'defaultMerchant',
          amount: 'defaultAmount',
          state: 'defaultState',
          createdAt: 'defaultCreatedAt',
          disputeType: '',
          complainNumber: '',
          deadline: '',
          description: '',
          complainantsName: '',
          complainantsPhone: '',
          complainantsEmail: '',
          complainantsAccountNo: '',
          complainantsIfsc: '',
          transaction: '',
          updatedAt: '',
          amountNum: 0,
        );
      }).toList();

      if (!filteredDispute.isNotEmpty) {
        setState(() {
          txtNoData = 'No Data Found';
        });
      }
    });
  }

  saveInLocaleDb(List<DisputeDataModel> data) async {
    final ordersBox = await Hive.openBox(Globals.DISPUTE_BOX);
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

  Future<void> getDisputeData() async {
    if (_isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    if (await Globals.isOffline()) {
      Globals.showToast(context, 'Check internet connectivity.');
      loadDisputes();
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
          Uri.parse("$baseUrl/v1/merchant/dispute"),
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
            allDispute.addAll(
              jsonDataList
                  .map((jsonData) => DisputeDataModel.fromJson(jsonData)),
            );
            filteredDispute = allDispute;
            if (filteredDispute.isEmpty) {
              txtNoData = 'No Data Found';
            } else {
              txtNoData = '';
            }
          });
          //save in localdb
          saveInLocaleDb(filteredDispute);

          if (kDebugMode) {
            print('orderData: $jsonDataList');
          }

          //currentPage++;
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
        builder: (context) => DisputeFilterScreen(
          selectedStartDate: selectedStartDate,
          selectedEndDate: selectedEndDate,
          selectedStatus: selectedStatus,
          selectedDisputeId: merchantId,
          selectedDeadlineDate: deadLineDate,
          // Add a comma here
          onSubmit: (startDate, endDate, status, transactionId, deadlineDate) {
            print(
                '======>  startDate :  $startDate  ===> endDate  :  $endDate   ====>  status : $status    ======>  transactionId : $transactionId '
                '======>  deadlineDate : $deadlineDate');
            _applyFilter(
                startDate, endDate, status, transactionId, deadlineDate);
          },
        ),
      ),
    );
  }

  void _applyFilter(String startDate, String endDate, String status,
      String merchantId, String deadlineDate) {
    setState(() {
      filteredDispute = filterTransactions(
          startDate, endDate, status, merchantId, deadlineDate);

      print(filteredDispute.length);
      if (filteredDispute.isEmpty) {
        setState(() {
          txtNoData = 'No Data Found';
        });
      }
    });
    _closeFilterScreen(); // Close the filter screen after applying filters
  }

  void _openFilterScreen() {
    setState(() {
      isFilterScreenVisible = true;
    });
  }

  List<DisputeDataModel> filterTransactions(String startDate, String endDate,
      String status, String merchantId, String deadlineDate) {
    return allDispute.where((transaction) {
      //  DateTime transactionDate =
      //   DateFormat('dd-MM-yyyy').parse(transaction.createdAt);

      DateTime dateTime = DateTime.parse(transaction.createdAt);

      print('dateTime Date: $dateTime');

      if (startDate.isNotEmpty && endDate.isNotEmpty) {
        merchantId = '';
        var isDateInRange = false;

        print('transactionDate Date: $dateTime');

        // if (startDate.isNotEmpty && endDate.isNotEmpty) {
        DateTime sDate = DateFormat('dd-MM-yyyy').parse(startDate);
        DateTime eDate = DateFormat('dd-MM-yyyy').parse(endDate);

        // print('Start Date: $sDate, End Date: $eDate');

        isDateInRange = dateTime.isBefore(eDate.add(const Duration(days: 1))) &&
            dateTime.isAfter(sDate.subtract(const Duration(days: 1)));
        // print('isDateInRange: $isDateInRange');
        // }

        final isStatusMatch = status == 'All' || transaction.state == status;

        final isMerchantMatch = transaction.id == merchantId;

        final isDeadLineMatch = transaction.deadline == deadlineDate;

        return (isDateInRange || isMerchantMatch || isDeadLineMatch) &&
            isStatusMatch;
      } else if (merchantId.isNotEmpty) {
        final isStatusMatch = status == 'All' || transaction.state == status;

        final isMerchantMatch = transaction.id == merchantId;
        return (isMerchantMatch) && isStatusMatch;
      } else if (deadlineDate.isNotEmpty) {
        final isStatusMatch = status == 'All' || transaction.state == status;

        DateTime deadline = DateTime.parse(transaction.deadline);
        String formattedDeadline = DateFormat('dd-MM-yyyy').format(deadline);

        print(
            'deadline date ===>>>    $formattedDeadline'); // This will print "22-09-2023"

        final isDeadLineMatch = formattedDeadline == deadlineDate;
        return (isDeadLineMatch) && isStatusMatch;
      } else {
        final isStatusMatch = status == 'All' || transaction.state == status;
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
          'Dispute',
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
              child: filteredDispute.isEmpty
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
                      itemCount: filteredDispute.length + (_isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index < filteredDispute.length) {
                          final transaction = filteredDispute[index];
                          var textColor = Colors.green; // Default color

                          if (transaction.state == 'OPEN') {
                            textColor = Colors.red;
                          } else if (transaction.state == 'CLOSED') {
                            textColor = Colors.green;
                          } else if (transaction.state == 'LOST') {
                            textColor = Colors.red;
                          }
                          else if (transaction.state == 'PROCESS_EXPIRED') {
                            textColor = Colors.red;
                          }else if (transaction.state == 'WON') {
                            textColor = Colors.green;
                          } else {
                            textColor = Colors.orange;
                          } // Add more conditions for other status values

                          return GestureDetector(
                            onTap: () {
                              // Navigate to a new screen when the item is tapped
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DisputeDetailScreen(
                                      disputeID: transaction.id),
                                ),
                              );
                            },
                            child: Card(
                              // Wrap ListTile with Card
                              elevation: 2.0,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 10.0),
                              child: ListTile(
                                title: Text(
                                  'Dispute ID: ${transaction.id}',
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
                                    const SizedBox(height: 2.0),
                                    Text(
                                      'Dispute Type: ${transaction.disputeType.replaceAll('_', ' ')}',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                    const SizedBox(height: 3.0),
                                    Row(
                                      children: [
                                        const SizedBox(height: 2.0),
                                        Container(
                                          padding: const EdgeInsets.all(1.0),
                                          child: Text(
                                            'Deadline: ${convertDate(transaction.deadline)}',
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
                                            transaction.state
                                                    ?.toString()
                                                    ?.replaceAll('_', ' ') ??
                                                'Nil',
                                            style: TextStyle(
                                              color: textColor,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2.0),
                                    Text(
                                      'Complaint Name: ${transaction.complainantsName}',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                    const SizedBox(height: 2.0),
                                    Text(
                                      'Complaint Phone: ${transaction.complainantsPhone}',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                    const SizedBox(height: 2.0),
                                    Text(
                                      'Description: ${transaction.description}',
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
      floatingActionButton: isFilterScreenVisible
          ? null
          : FloatingActionButton(
              onPressed: openScreen,
              child: const Icon(Icons.filter_list),
            ),
    );
  }
}
