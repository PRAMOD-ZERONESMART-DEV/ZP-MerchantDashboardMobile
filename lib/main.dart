import 'package:flutter/material.dart';
import 'package:zerone_pay/DisputeScreen.dart';
import 'package:zerone_pay/HomePageScreen.dart';
import 'package:zerone_pay/LoginScreen.dart';
import 'package:zerone_pay/model/OrderDataModel.dart';
import 'package:zerone_pay/model/RefundDataModel.dart';
import 'package:zerone_pay/model/SettlementDataModel.dart';
import 'package:zerone_pay/model/Transaction.dart';
import 'package:zerone_pay/util/Globals.dart';
import 'OrdersScreen.dart';
import 'SettlementsScreen.dart';
import 'RefundsScreen.dart';
import 'TransactionFlowChart.dart';
import 'TransactionsScreen.dart';
import 'model/DisputeDataModel.dart';
import 'model/TransactionData.dart';

import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);

  // Register the ModelAdapter with the correct type argument
  Hive.registerAdapter<Transaction>(TransactionAdapter());
  Hive.registerAdapter<OrderDataModel>(OrderDataModelAdapter());
  Hive.registerAdapter<SettlementDataModel>(SettlementDataModelAdapter());
  Hive.registerAdapter<RefundDataModel>(RefundDataModelAdapter());
  Hive.registerAdapter<DisputeDataModel>(DisputeDataAdapter());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> isUserLoggedIn() async {
    final box = await Hive.openBox(Globals.LOGIN_BOX);
    return box.get('isLogin', defaultValue: false);
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zerone Pay',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      initialRoute: '/',
      onGenerateRoute: (RouteSettings settings) {
        if (settings.name == '/') {
          return MaterialPageRoute(builder: (context) {
            return FutureBuilder<bool>(
              future: isUserLoggedIn(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else {
                  if (snapshot.data == true) {
                    // setUserData();
                    // User is logged in, show dashboard
                    return const HomePageScreen(title: 'Dashboard');
                  } else {
                    // User is not logged in, show login
                    return const LoginScreen();
                    // return const LoginScreen();
                  }
                }
              },
            );
          });
        }
        return null; // Return null for any unknown routes
      },
      routes: {
        '/dashboard': (context) => const HomePageScreen(title: 'Dashboard'),
        '/transactions': (context) => const TransactionsScreen(),
        '/orders': (context) => const OrdersScreen(),
        '/settlements': (context) => const SettlementsScreen(),
        '/income': (context) => const RefundsScreen(),
        '/refund': (context) => const RefundsScreen(),
        '/billing': (context) => const SettlementsScreen(),
        '/login': (context) => const LoginScreen(),
        '/dispute': (context) => const DisputeScreen(),
        '/transaction_flow': (context) {
          final List<TransactionData> transactions = ModalRoute.of(context)
              ?.settings
              .arguments as List<TransactionData>;
          return TransactionFlowChart(transactions: transactions);
          // Define routes for other screens here
        },
      },
    );
  }
}
