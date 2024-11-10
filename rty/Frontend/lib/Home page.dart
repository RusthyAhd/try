import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tap_on/Tool_Provider/TP_Dashboard.dart';
import 'package:tap_on/Tool_Provider/TP_Login.dart';
import 'package:tap_on/User_Home/AddToCart.dart';


import 'package:tap_on/User_Home/LaunchPage.dart';

import 'package:tap_on/User_Home/UH_EnterNumber.dart';

import 'package:tap_on/User_Home/UH_Notification.dart';
import 'package:tap_on/User_Home/UH_Profile.dart';
import 'package:tap_on/User_Tools/UT_Location.dart';
import 'dart:async';
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();
  late Timer _timer;
  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }
 void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      int nextPage = _pageController.page!.toInt() + 1;
      if (nextPage >= 2) {
        nextPage = 0;
      }
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Colors.green[50],
      appBar: AppBar(
       title: const Text('TapOn', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green[700],
        elevation: 4,
        leading: IconButton(
         icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const EnterNumber()));
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const UH_Notification()));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          ListTile(
            leading: GestureDetector(
              onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => UH_Profile()));
              },
              child: CircleAvatar(
                backgroundColor: Colors.green[700],
                child: const Icon(Icons.person, color: Colors.white),
              ),
            ),

            title: const Text(
              "Profile",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
             trailing: IconButton(
              icon: const Icon(Icons.support_agent, color: Colors.green),

              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => addtocart()),
                );
              },
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Text(
              'Shop for Today',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Colors.green,),
            ),
          ),
          const SizedBox(height: 10),

          // Main Tool Grid
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  ServiceCard(
                    imagePath: 'assets/images/grossery.jpg',
                    label: 'Groceries and Essentials',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                UT_Location(tool: 'Plumbing Tools')),
                      );
                    },
                  ),
                  ServiceCard(
                    imagePath: 'assets/images/home.jpg',
                    label: 'Home and Kitchen',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                UT_Location(tool: 'Electrical Tools')),
                      );
                    },
                  ),
                  ServiceCard(
                    imagePath: 'assets/images/health.jpg',
                    label: 'Health and Care',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                UT_Location(tool: 'Carpenting Tools')),
                      );
                    },
                  ),
                  ServiceCard(
                    imagePath: 'assets/images/cloth.jpg',
                    label: 'Fashion and Clothing',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                UT_Location(tool: 'Painting Tools')),
                      );
                    },
                  ),
                  ServiceCard(
                    imagePath: 'assets/images/elec.jpg',
                    label: 'Electronics and Gadgets',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                UT_Location(tool: 'Gardening Tools')),
                      );
                    },
                  ),
                  ServiceCard(
                    imagePath: 'assets/images/baby.jpg',
                    label: 'Baby and Kids',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                UT_Location(tool: 'Repairing Tools')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Advertisement Card with Gradient
    
               Expanded(
            child: PageView(
              controller: _pageController,
              scrollDirection: Axis.horizontal,
              children: [
                AdvertisementCard(
                  backgroundColor: Colors.green[300]!,
                  icon: Icons.local_offer,
                  title: "Special Offer!",
                  description: "Up to 50% off on daily essentials. Grab it now!",
                   imagePath: 'assets/images/offer.jpg',
                ),
                AdvertisementCard(
                  backgroundColor: Colors.green[200]!,
                  icon: Icons.delivery_dining,
                  title: "Free Delivery",
                  description: "Free delivery on orders above \$50!",
                   imagePath: 'assets/images/sale.jpg',
                ),
              ],
            ),
          ),
          
        ],
      ),
 
  
    bottomNavigationBar: BottomAppBar(
      shape: const CircularNotchedRectangle(),
      color: Colors.green[700],
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('rishaf', style: TextStyle(color: Colors.white)),
        Text(
          'Your one-stop shop for everything!',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        ],
      ),
      ),
    ),
    );
  }
}
class ServiceCard extends StatelessWidget {
  final String label;
  final String? imagePath;
  final VoidCallback onTap;

  const ServiceCard({super.key, 
    required this.label,
    required this.onTap,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: DecorationImage(
              image: AssetImage(imagePath!),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withOpacity(0.6), Colors.transparent],
              ),
            ),
            alignment: Alignment.bottomCenter,
            padding: const EdgeInsets.all(10),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
class AdvertisementCard extends StatelessWidget {
  final Color backgroundColor;
  final IconData icon;
  final String title;
  final String description;
  final String imagePath;

  const AdvertisementCard({super.key, 
    required this.backgroundColor,
    required this.icon,
    required this.title,
    required this.description,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 12.0),
      child: Stack(
        children: [
          // Background image with transparency
          Container(
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
          ),
          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [backgroundColor.withOpacity(0.1), backgroundColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Content (icon, title, description)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 50, color: Colors.white),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withOpacity(0.9)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
