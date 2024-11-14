import 'dart:convert'; // Importing the dart:convert library for JSON encoding and decoding

import 'package:flutter/material.dart'; // Importing Flutter material package for UI components
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Importing flutter_dotenv for environment variables
// Importing the Verification screen
import 'package:http/http.dart'
    as http; // Importing http package for making HTTP requests
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tap_on/Home%20page.dart';
import 'package:tap_on/Tool_Provider/TP_Login.dart';
import 'package:tap_on/User_Home/UH_Profile.dart';
import 'package:tap_on/constants.dart'; // Importing constants
// Importing quickalert for showing alerts
// Importing Loading widget for showing loading dialogs

class EnterNumber extends StatefulWidget {
  const EnterNumber({super.key}); // Constructor for EnterNumber widget

  @override
  _EnterNumberState createState() =>
      _EnterNumberState(); // Creating state for EnterNumber widget
}

class _EnterNumberState extends State<EnterNumber> {
  final _formKey = GlobalKey<FormState>(); // Key for the form
  final _phoneController =
      TextEditingController(); // Controller for the phone number input
  bool _isLoading = false; // Loading state

  @override
  void dispose() {
    _phoneController
        .dispose(); // Dispose the controller when the widget is disposed
    super.dispose();
  }

  String? validatePhoneNumber(String? value) {
    // Function to validate the phone number
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number'; // Return error if the input is empty
    } else if (!RegExp(r'^0\d{9}$').hasMatch(value)) {
      return 'Please enter a valid Sri Lankan phone number'; // Return error if the input is not a valid phone number
    }

    return null; // Return null if the input is valid
  }

  @override
  Widget build(BuildContext context) {
    // Build method to create the UI
    double height =
        MediaQuery.of(context).size.height; // Get the height of the screen
    double width =
        MediaQuery.of(context).size.width; // Get the width of the screen

    return Scaffold(
      backgroundColor: Colors.green, // Set the background color of the scaffold
      body: SingleChildScrollView(
        // SingleChildScrollView to make the screen scrollable
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Align children to the start
          children: [
            Stack(
              // Stack to overlay widgets
              children: [
                Image.asset(
                  'assets/images/enternu.jpg', // Display an image
                  height: height * 0.50, // Set the height of the image
                  width: width, // Set the width of the image
                  fit: BoxFit.cover, // Cover the entire area
                ),
                Container(
                  height: height * 0.50, // Set the height of the container
                  width: width, // Set the width of the container
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.green
                      ], // Gradient overlay
                    ),
                  ),
                ),
              ],
            ),
            Center(
              // Center the children
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Center the children vertically
                crossAxisAlignment: CrossAxisAlignment
                    .center, // Center the children horizontally
                children: [
                  const Text(
                    appName, // Display the app name
                    style: TextStyle(
                      fontSize: 40, // Set the font size
                      fontWeight: FontWeight.bold, // Set the font weight
                    ),
                  ),
                  const Text(
                    slogan, // Display the slogan
                    style: TextStyle(color: Colors.blueGrey), // Set the text color
                  ),
                  SizedBox(
                    height: 20, // Add some space
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50.0), // Add horizontal padding
                    child: Form(
                      key: _formKey, // Set the form key
                      child: TextFormField(
                        controller: _phoneController, // Set the controller
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.phone), // Add a phone icon
                          labelText: "Enter your Number", // Set the label text
                        ),
                        keyboardType:
                            TextInputType.phone, // Set the keyboard type
                        validator: validatePhoneNumber, // Set the validator
                      ),
                    ),
                  ),
                  const SizedBox(height: 25), // Add some space
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                          setState(() => _isLoading = true);

                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setString(
                              'phoneNumber', _phoneController.text);

                          final baseURL = dotenv.env['BASE_URL'];
                          final response = await http.get(
                            Uri.parse(
                                '$baseURL/profile/${_phoneController.text}'),
                          );

                          final data = jsonDecode(response.body);
                          setState(() => _isLoading = false);

                          if (!mounted) return;

                          if (response.statusCode == 200) {
                            await Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const HomePage()),
                              (route) => false,
                            );
                          } else {
                            await Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const UH_Profile()),
                              (route) => false,
                            );
                          }
                        } catch (e) {
                          setState(() => _isLoading = false);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: ${e.toString()}')),
                            );
                          }
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(
                          255, 6, 85, 10), // Set the button color
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40, // Set horizontal padding
                        vertical: 15, // Set vertical padding
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10), // Set the border radius
                      ),
                    ),
                    child: const Text(
                      'Send', // Set the button text
                      style: TextStyle(
                        fontSize: 16, // Set the font size
                        color: Colors.white38, // Set the text color
                        fontWeight: FontWeight.bold, // Set the font weight
                      ),
                    ),
                  ),
                  const SizedBox(height: 25), // Add some space
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => TP_Login()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(
                          255, 10, 80, 5), // Set the button color
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40, // Set horizontal padding
                        vertical: 20, // Set vertical padding
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10), // Set the border radius
                      ),
                    ),
                    child: const Text(
                      'Provider Login', // Set the button text
                      style: TextStyle(
                        fontSize: 16, // Set the font size
                        color: Colors.orange, // Set the text color
                        fontWeight: FontWeight.bold, // Set the font weight
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
