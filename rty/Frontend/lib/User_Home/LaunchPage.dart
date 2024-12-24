import 'package:flutter/material.dart';
import 'package:tap_on/User_Home/UH_EnterNumber.dart';

const String imagePath = 'assets/images/Launch_Bg.jpeg';

class LaunchPage extends StatelessWidget {
  const LaunchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.green[700],
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.green.withOpacity(0.4),
                BlendMode.darken,
              ),
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(),
                // Increase the size of the logo
                SizedBox(
                  width: screenWidth * 0.95, // Adjust the width as needed
                  height: screenHeight * 0.5, // Adjust the height as needed
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black54.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                      borderRadius:
                          BorderRadius.circular(20), // Rounded corners
                    ),
                    child: Image.asset(
                      'assets/images/Launch_logo.png',
                      width: screenWidth * 0.9, // Adjust the width as needed
                      height:
                          screenHeight * 0.25, // Adjust the height as needed
                    ),
                  ),
                ),
                const SizedBox(
                    height: 50), // Add some space to move the image up
                const SizedBox(
                    height: 20), // Add some space between logo and text
                const Text(
                  'Click here to get started with TapOn',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.green,
                        offset: Offset(8.0, 8.0),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                    height: 20), // Adjust the space to move the button up
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => EnterNumber()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(190, 0, 142, 244),
                    foregroundColor: const Color.fromARGB(255, 244, 189, 8), // Button color
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    textStyle: TextStyle(fontSize: 16, color: Colors.white),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(30), // Rounded corners
                    ),
                    shadowColor: Colors.white54,
                    elevation: 10,
                  ),
                  child: Text('GET STARTED'),
                ),
                const SizedBox(height: 30), // Adjust the space below the button
                const Text(
                  'Discover new interests.',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white60,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.green,
                        offset: Offset(5.0, 5.0),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
