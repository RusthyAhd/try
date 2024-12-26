import 'package:flutter/material.dart'; // Importing Flutter material package for UI components
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Importing flutter_dotenv for environment variables
import 'package:http/http.dart' as http; // Importing http package for making HTTP requests
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tap_on/Home%20page.dart';
import 'package:tap_on/Tool_Provider/TP_Login.dart';
import 'package:tap_on/User_Home/UH_Profile.dart';
import 'package:tap_on/constants.dart'; // Importing constants

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
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.green,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
          Stack(
            children: [
              Image.asset(
                'assets/images/enternu.jpg',
                height: height * 0.50,
                width: width,
                fit: BoxFit.cover,
              ),
              Container(
                height: height * 0.50,
                width: width,
                decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.green,
              ],
            ),
                ),
              ),
            ],
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
            appName,
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
                ),
                const Text(
            slogan,
            style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 20),
                Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50.0),
            child: Form(
              key: _formKey,
              child: TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.phone),
                  labelText: "Enter your Number",
                ),
                keyboardType: TextInputType.phone,
                validator: validatePhoneNumber,
              ),
            ),
                ),
                const SizedBox(height: 25),
                _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton.icon(
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
              backgroundColor:
                  const Color.fromARGB(255, 6, 85, 10),
              padding: const EdgeInsets.symmetric(
                horizontal: 40,
                vertical: 15,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
           
            label: const Text(
              'Login',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
                ),
                const SizedBox(height: 25),
              ],
            ),
          ),
              ],
            ),
          ),
          // Login icon at the top-right corner
          Positioned(
            top: 70,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.login, color: Colors.white, size: 30),
              onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TP_Login()),
          );
              },
            ),
          ),
        ],
      ),
    );
  }
}
