import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:zerone_pay/util/Globals.dart';

import 'model/Items.dart';
import 'model/TransactionData.dart';

import 'package:http/http.dart' as http;

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HomePageScreen> createState() => HomePageState();
}

class HomePageState extends State<HomePageScreen> {
  String name = '';
  String email = '';
  String currentBalance = '';
  String withdrawableBalance = '';
  late List<Items> items = [];

  setUserData() async {
    final box = await Hive.openBox(Globals.LOGIN_BOX);
    String userName = box.get('userName', defaultValue: '');
    String token = box.get('token', defaultValue: '');
    setState(() {
      Globals.USER_DATA = userName;
      Globals.AUTH_TOKEN = token;
    });
    box.close();

    getApiRequest('detail');
    getApiRequest('balance');
  }

  @override
  void initState() {
    super.initState();
    setUserData();
  }

  setDataStatic() {
    setState(() {
      items = [
        Items('Unsettled Balance', currentBalance, '+0.01%',
            'assets/images/t_transaction.png', 'assets/images/market_up.png'),
        Items('Total Transactions', '5432', '+1.6%',
            'assets/images/t_transaction.png', 'assets/images/market_up.png'),
        Items('Order', '432', '+0.3%', 'assets/images/order.png',
            'assets/images/market_down.png'),
        Items('Dispute', '234 L', '+1.6%', 'assets/images/incomes.png',
            'assets/images/market_down.png'),
        Items('Settlements', '2094 L', '+7.6%', 'assets/images/settlement.png',
            'assets/images/market_up.png'),
        Items('Refunds', '3234 L', '+6.6%', 'assets/images/refunds.png',
            'assets/images/market_up.png'),
      ];
    });
  }

  final List<TransactionData> transactionList = [
    TransactionData(tranDate: '10/07', amount: 400.0),
    TransactionData(tranDate: '11/07', amount: 200.0),
    TransactionData(tranDate: '12/07', amount: 450.0),
    TransactionData(tranDate: '13/04', amount: 950.0),
    TransactionData(tranDate: '14/04', amount: 600.0),
    TransactionData(tranDate: '15/04', amount: 300.0),
    TransactionData(tranDate: '16/04', amount: 800.0),
    // TransactionData(tranDate: '17/04', amount:  '700.0'),
    // TransactionData(tranDate: '18/04', amount:  '950.0'),
    // TransactionData(tranDate: '19/04', amount:  '300.0'),
    // TransactionData(tranDate: '20/04/2023', amount:  '300.0'),
    // TransactionData(tranDate: '25/04/2023', amount:  '5000.0'),
  ];

  Future<void> _showLogoutConfirmationDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout Confirmation'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Logout'),
              onPressed: () {
                // Perform the logout action here
                // For example, you can clear user data, log the user out, etc.
                Navigator.of(context).pop(); // Close the dialog
                logout();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> getApiRequest(String requestType) async {
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
      Response response;
      if (requestType == 'detail') {
        response = await http.get(
          Uri.parse("$baseUrl/v1/merchant/detail"),
          headers: {'Authorization': 'Bearer $token'},
        );
      } else if (requestType == 'balance') {
        response = await http.get(
          Uri.parse("$baseUrl/v1/merchant/transaction/balance"),
          headers: {'Authorization': 'Bearer $token'},
        );
      } else {
        response = await http.get(
          Uri.parse("$baseUrl/v1/merchant/detail"),
          headers: {'Authorization': 'Bearer $token'},
        );
      }

      Map<String, dynamic> responseData = jsonDecode(response.body);
      if (kDebugMode) {
        print('Response: ${response.body}');
      }
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonDataList = responseData['data'];

        if (requestType == 'detail') {
          setState(() {
            // Append new data to the existing list
            email = jsonDataList['email'];
            name = jsonDataList['alias'];
          });
        } else if (requestType == 'balance') {
          setState(() {
            // Append new data to the existing list
            currentBalance = jsonDataList['currentBalance'];
            withdrawableBalance = jsonDataList['withdrawableBalance'];
          });

          setDataStatic();
        } else {}

        if (kDebugMode) {
          print('homepage data =>>> $requestType =   : $jsonDataList');
        }
      } else if (response.statusCode == 401) {
        String message = responseData['message'];
        Globals.showToast(context, message);
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        String message = responseData['message'];
        Globals.showToast(context, message);
      }
    } catch (e) {
      // Handle other exceptions
      print('Error: $e');
    } finally {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(widget.title),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        iconTheme: const IconThemeData(color: Colors.white), // Add this line
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(

              accountName: Text(
                name.toUpperCase(),
                style: const TextStyle(
                  fontSize: 19.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              accountEmail: Text(email,
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.normal,
                  )),
              currentAccountPictureSize: const Size(70, 70),
              currentAccountPicture: const CircleAvatar(
                radius: 1.0,
                backgroundImage: AssetImage('assets/images/user.png'),
              ),
              decoration: const BoxDecoration(
                color: Colors.red,
              ),
            ),

            ListTile(
              leading: Image.asset('assets/icons/ico_transaction.png',
                  width: 24, height: 24),
              title: const Text('Total Transactions'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/transaction_flow',
                    arguments: transactionList);
              },
            ),
            ListTile(
              leading: Image.asset('assets/icons/ico_order.png',
                  width: 24, height: 24),
              title: const Text('Orders'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/orders');
              },
            ),
            ListTile(
              leading: Image.asset('assets/icons/ico_settlements.png',
                  width: 24, height: 24),
              title: const Text('Settlements'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settlements');
              },
            ),
            ListTile(
              leading: Image.asset('assets/icons/ico_merchants.png',
                  width: 24, height: 24),
              title: const Text('Dispute'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/dispute');
              },
            ),

            ListTile(
              leading: Image.asset('assets/icons/ico_refunds.png',
                  width: 24, height: 24),
              title: const Text('Refunds'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/refund');
              },
            ),

            ListTile(
              leading: const Icon(Icons.shopping_basket),
              title: const Text('Billing'),
              onTap: () {
                Globals.showToast(context, 'coming soon..');
              },
            ),

            const SizedBox(height: 30.0),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                _showLogoutConfirmationDialog(context);
                //logout();
              },
            ),
            // Add more ListTile items for other screens
          ],
        ),
      ),
      body: Container(
        color: Colors.white70,
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.2,
          ),
          itemCount: items.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () {
                clickedItem(items[index].title);
              },
              child: GridItem(
                title: items[index].title,
                productivityPercentage: items[index].productPercentage,
                productPrice: items[index].productPrize,
                imageAsset: items[index].imageAssets,
                ratioImage: items[index].ratioImage,
                index: index,
              ),
            );
          },
        ),
      ),
    );
  }

  void clickedItem(String title) {
    if (title == 'Total Transactions') {
      //Globals.showToast(context, title);
      Navigator.pushNamed(context, '/transactions');
      // Navigator.pushNamed(context, '/transaction_flow',
      //   arguments: transactionList);
    } else if (title == 'Order') {
      // Globals.showToast(context, title);
      Navigator.pushNamed(context, '/orders');
    } else if (title == 'Settlements') {
      // Globals.showToast(context, title);
      Navigator.pushNamed(context, '/settlements');
    } else if (title == 'Refunds') {
      //Globals.showToast(context, title);
      Navigator.pushNamed(context, '/refund');
    } else if (title == 'Dispute') {
      //Globals.showToast(context, title);
      Navigator.pushNamed(context, '/dispute');
    } else {
      // Globals.showToast(context, 'coming soon..');
    }
  }

  Future<void> logout() async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.setBool('isLoggedIn', false);

    try {
      List<String> boxNamesToDelete = [
        Globals.LOGIN_BOX,
        Globals.TRANSACTION_BOX,
        Globals.ORDER_BOX,
        Globals.SETTLEMENT_BOX,
        Globals.REFUND_BOX,
        Globals.DISPUTE_BOX
      ];

// Iterate through the list of box names and delete each box
      for (var boxName in boxNamesToDelete) {
        await Hive.deleteBoxFromDisk(boxName);
      }
      await Hive.close(); // Close the box after clearing the data
    } catch (e) {
      // Handle any errors that may occur during the process
      if (kDebugMode) {
        print('Error while logging out: $e');
      }
    }

    Navigator.pushReplacementNamed(context, '/login');
  }
}

class GridItem extends StatelessWidget {
  final String title;
  final String productPrice;
  final String productivityPercentage;
  final String imageAsset;
  final String ratioImage;
  final int index;

  const GridItem(
      {super.key,
      required this.title,
      required this.productPrice,
      required this.productivityPercentage,
      required this.imageAsset,
      required this.ratioImage,
      required this.index});

  @override
  Widget build(BuildContext context) {
    bool isFirstItem = false;
    return Card(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              style: TextStyle(
                  color: isFirstItem ? Colors.grey : Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  ratioImage,
                  width: 14,
                  height: 14,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(1.0),
                child: Text(
                  productivityPercentage,
                  style: TextStyle(
                      color: isFirstItem ? Colors.grey : Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.normal),
                ),
              ),
              const Spacer(),
              // Add a spacer to push the next element to the right
              Container(
                padding: const EdgeInsets.all(10.0),
                child: Image.asset(
                  imageAsset,
                  width: 35,
                  height: 35,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
            child: Text(
              '\u{20B9} $productPrice',
              style: TextStyle(
                  color: isFirstItem ? Colors.grey : Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
