import 'package:flutter/material.dart';
import 'package:tap_on/Home%20page.dart';
import 'package:tap_on/User_Home/UH_EnterNumber.dart';
const String imagePath = 'assets/images/background.jpg';

class LaunchPage extends StatelessWidget {
  const LaunchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.green[700],
        body: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.3),
                BlendMode.darken,
              ),
            ),
          ),
          child: Center(
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Directly use the Image.asset widget to display the logo
                  Image.asset(
                    'assets/images/logo.png',
                    width: 500, // Adjust the width as needed
                    height: 500, // Adjust the height as needed
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 40), 
                  const Text(
                    'Discover new interests.',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Empower your team with our application',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => EnterNumber()));
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green, // Button color
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        textStyle: TextStyle(fontSize: 16, color: Colors. white)),
                    child: Text('GET STARTED'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
