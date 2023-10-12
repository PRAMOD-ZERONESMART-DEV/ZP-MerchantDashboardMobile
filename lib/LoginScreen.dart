import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grecaptcha/grecaptcha.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:lottie/lottie.dart';

import 'util/Globals.dart';
import 'dart:io' show Platform;

//const String siteKey = "6Ldf5rEnAAAAAFFkaDc92anznhC80fLEu9XC38dz";
const String siteKey = "6LejlHUoAAAAAM_n1YEK98747uAEeSE7BDfnx-GD";

String encryptedText = "";
//const String siteKey = "6LeIxAcTAAAAAGG-vFI1TnRWxMZNFuojJ4WifJWe";

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<StatefulWidget> createState() => LoginState();
}

class LoginState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _token = '';
  String userdata = '';
  bool showPasteText = false; //
  bool _isPasswordVisible = false;
  late final Box box;

  @override
  void initState() {
    super.initState();
    _usernameController.text = 'tech@zpi.cash';
    _passwordController.text = '93Hf394hf93hf934hf3f@';
  }

  void _startVerification(String name, String password) {
    Grecaptcha().verifyWithRecaptcha(siteKey).then((result) {
      if (kDebugMode) {
        print('result is ===>>>>  $result');
      }

      Map<String, dynamic> rawBody = {
        "email": _usernameController.text,
        "password": _passwordController.text,
        "humanToken": result,
        "clientType": "ANDROID"
      };

      // Encode the raw data to JSON
      String rawBodyJson = jsonEncode(rawBody);

      makeLoginRequest(rawBodyJson);
      //visibleUIData(result);
      // showPasteText = true;
      // setState(() {
      //   _token = result;
      // });
      //
      // Globals.AUTH_TOKEN = _token;
    }, onError: (e, s) {
      if (kDebugMode) {
        Globals.showToast(context, 'Could not verify try again');
        print("Could not verify:\n$e at $s");
      }
    });
  }

  void _submitButton(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      String userName = _usernameController.text;
      String password = _passwordController.text;

      if (Platform.isAndroid) {
        _startVerification(userName, password);
      } else if (Platform.isIOS) {
        Map<String, dynamic> rawBody = {
          "email": userName,
          "password": password,
          "humanToken": 'jkgfgfjksafgajkfgakjf'
        };
      }

      // Encode the raw data to JSON
      //String rawBodyJson = jsonEncode(rawBody);

      //makeLoginRequest(rawBodyJson);
    }

    // _startVerification(userName, password);

    // Map<String, dynamic> rawBody = {
    //   "email": _usernameController.text,
    //   "password": _passwordController.text,
    //   "humanToken": 'jkgfgfjksafgajkfgakjf',
    //   "clientType": 'ANDROID'
    // };
    // //
    // // // Encode the raw data to JSON
    // String rawBodyJson = jsonEncode(rawBody);
    // //
    // makeLoginRequest(rawBodyJson);
    //}
  }

  void _forgotPassword() {
    Globals.showToast(context, 'forgot password');
    // Implement the logic for the "Forgot Password" functionality here
    // For example, show a dialog to reset password, navigate to a password reset screen, etc.
  }

  void _copyToClipboard() {
    // This function copies the token to the clipboard
    Clipboard.setData(ClipboardData(text: _token));
    Globals.showToast(context, 'Token copied to clipboard');

    // // Cryptom cryptom = Cryptom();
    //  String plaintext = "Hello, world!";
    //  String encryptedText = cryptom.text(plaintext);
    //  print("Encrypted Text: $encryptedText");
  }

  // void encryptData(String text) {
  //   final publicKey = encrypt.RSAKeyParser().parse(publicKeyPEM);
  //   final encrypter = encrypt.Encrypter(encrypt.RSA(
  //     publicKey: publicKey,
  //     encoding: encrypt.RSAEncoding.PKCS1,
  //   ));
  //
  //   final encrypted = encrypter.encrypt(text);
  //   setState(() {
  //     encryptedText = encrypted.base64;
  //   });
  // }

  Future<void> makeLoginRequest(String rawData) async {
    if (await Globals.isOffline()) {
      Globals.showToast(context, 'Check internet connectivity.');
    } else {
      String baseUrl = Globals.BASE_URL;
      // API endpoint URL
      String endpointUrl = '$baseUrl/v1/merchant/login';
      // Set up the headers with the authorization token
      Map<String, String> headers = {
        "Content-Type": "application/json",
      };

      try {
        // Make the POST request
        Response response = await post(
          Uri.parse(endpointUrl),
          headers: headers,
          body: rawData,
        );

        // Check the response status code
        if (response.statusCode == 201) {
          // Request was successful
          print("Request was successful!");
          print("Response:");
          print(response.body);
          handleResponse(response.body);
        } else if (response.statusCode == 409) {
          // Conflict: Merchant Trade Number already exists
          handleResponse(response.body);
        } else {
          // Request failed
          print("Request failed with status code: ${response.statusCode}");
          print("Response:");
          // print(response.body);
          handleResponse(response.body);
        }
      } catch (e) {
        // An error occurred
        print("An error occurred: $e");
      }
    }
  }

  Future<void> handleResponse(String responseBody) async {
    // Parse the JSON response
    Map<String, dynamic> jsonResponse = json.decode(responseBody);
    print('response --->>>   $jsonResponse');

    // Access the status code, message, and error fields
    int statusCode = jsonResponse['statusCode'];

    // Check the status code
    if (statusCode == 201) {
      // Successful response
      String loginToken = jsonResponse['data']['token'];
      String name = jsonResponse['data']['name'];
      print("Login successful!");
      Globals.showToast(context, "Login successful!");
      visibleUIData(loginToken, name);
    } else if (statusCode == 409) {
      // Conflict: Merchant Trade Number already exists
      String message = jsonResponse['message'];
      print("Conflict: $message");
      Globals.showToast(context, message);
    } else if (statusCode == 400) {
      String message = jsonResponse['message'];
      print("Bad Request: $message");
      Globals.showToast(context, message);
    } else {
      // Handle other status codes here if necessary
      print("Status Code: $statusCode");
      String message = jsonResponse['message'];
      Globals.showToast(context, message);
    }
  }

  void visibleUIData(String response, String data) async {
    showPasteText = true;
    setState(() {
      _token = response;
    });

    Globals.AUTH_TOKEN = _token;
    Globals.USER_DATA = data;

    final box = await Hive.openBox(Globals.LOGIN_BOX);
    box.put('isLogin', true);
    box.put('userName', data);
    box.put('token', _token);

    if (kDebugMode) {
      print(box);
    }
    // Navigate to the dashboard
    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false; // Prevent back button navigation
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: const Center(
            // Center the title using the Center widget
            child: Text(
              'Login',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24, // Update this value to change the title size
              ),
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Container(
          padding: const EdgeInsets.all(20.0),
          child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Lottie.asset(
                      'assets/lottie/login_lottie.json',
                      // Replace with your animation file path
                      height: 150,
                      width: 200,
                      fit: BoxFit.contain,
                    ),
                  ),

                  SizedBox(height: 30.0),
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.white, // Set the background color to white
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(
                          color: Colors.grey), // Set the border color to grey
                    ),
                    child: TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'User Name',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter user name';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.white, // Set the background color to white
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(
                          color: Colors.grey), // Set the border color to grey
                    ),
                    child: TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16.0),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                          child: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                        ),
                      ),
                      obscureText: !_isPasswordVisible,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter password.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 5.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(),
                      // Empty container to create space on the left side
                      GestureDetector(
                        onTap: _forgotPassword,
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  // Container(
                  //   padding: const EdgeInsets.all(8.0),
                  //   height: 80.0,
                  //   child: const Captchav2(),
                  // ),
                  const SizedBox(height: 16.0),
                  Container(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        height: 40.00,
                        child: ElevatedButton(
                          onPressed: () => _submitButton(context),
                          //onPressed: () => _startVerification(),
                          child: const Text('SUBMIT'),
                        ),
                      )),
                  const SizedBox(height: 16.0),
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    child: showPasteText
                        ? const Text(
                            'Your Token (Click on text to copy to clipboard)',
                            style: TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.bold,
                                fontSize: 17),
                          )
                        : const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 2.0),
                  Container(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () => _copyToClipboard(),
                        child: showPasteText
                            ? Text(
                                _token,
                                style: const TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14),
                              )
                            : const SizedBox.shrink(),
                      )),
                ],
              )),
        ),
      ),
    );
  }
}
