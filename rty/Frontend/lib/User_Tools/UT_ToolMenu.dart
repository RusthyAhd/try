import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tap_on/User_Home/AddToCart.dart';
import 'package:tap_on/User_Tools/UT_NearbyShops.dart';
import 'package:tap_on/User_Tools/UT_ToolDetails.dart';
import 'package:http/http.dart' as http;

class UT_ToolMenu extends StatefulWidget {
  final String shopName; // Shop name to display relevant tools
  final String shopId;
  final String shopEmail;
  final String shopPhone;

  const UT_ToolMenu({
    super.key,
    required this.shopName,
    required this.shopId,
    required this.shopEmail,
    required this.shopPhone, required String product,
  });

  @override
  State<UT_ToolMenu> createState() => _UT_ToolMenuState();
}

class _UT_ToolMenuState extends State<UT_ToolMenu> {
  bool _isLoading = true;
  bool _noToolsFound = false;
  final List<Map<String, dynamic>> products = [];

  @override
  void initState() {
    super.initState();
    _initAsync();
  }

  void _initAsync() async {
    await getAllTools();
  }

  Future<void> getAllTools() async {
    try {
      final baseURL = dotenv.env['BASE_URL'];

      if (baseURL == null) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Configuration Error',
          text: 'Please check your configuration and try again.',
        );
        return;
      }

      final response = await http.get(
        Uri.parse('$baseURL/tool/get/all/${widget.shopId}'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      if (data['status'] == 200) {
        final tools = data['data'];
        if (tools.length > 0) {
          List<Map<String, dynamic>> fetchedTools = [];

          for (var tool in tools) {
            fetchedTools.add({
              'id': tool['tool_id'] ?? 'N/A',
              'title': tool['title'] ?? 'Service Name',
              'price': tool['item_price'].toString(),
              'discount': tool['discount']?.toString() ?? '0',
              'quantity': tool['qty'].toString(),
              'image': tool['pic'] ?? '',
              'description': tool['description'] ?? tool['title'],
              'availability': tool['availability'] ?? 'N/A',
              'available_days': tool['available_days'] ?? [],
              'available_hours': tool['available_hours'] ?? 'N/A',
            });
          }

          setState(() {
            products.clear();
            products.addAll(fetchedTools);
            _isLoading = false;
            _noToolsFound = false;
          });
        } else {
          setState(() {
            _isLoading = false;
            _noToolsFound = true;
          });
        }
      } else {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Error',
          text: 'Failed to load tools. Please try again.',
        );
      }
    } catch (e) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Oops...',
        text: 'An error occurred. Please try again.',
      );
      setState(() {
        _isLoading = false;
        _noToolsFound = true;
      });
    }
  }

  Future<void> saveProductToPreferences(Map<String, dynamic> product) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedProduct', jsonEncode(product));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.shopName} Products',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        
        backgroundColor: Colors.green,
         elevation: 4,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => UT_NearbyShops(
                  userLocation: 'your_user_location', // Replace with actual user location
                  tool: 'your_tool', // Replace with actual tool
                )));
          },
        ),
        actions: [
         IconButton(
              icon: const Icon(Icons.shopping_cart_checkout_outlined, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddToCart()),
                );
              },
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 47, 221, 105),
              Color.fromARGB(255, 17, 202, 79),
              Color.fromARGB(255, 45, 251, 114),
              const Color.fromARGB(255, 45, 251, 182)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      image: DecorationImage(
                        image: AssetImage('assets/images/b.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    bottom: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Our New Products",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Show loading indicator or no tools found message
              if (_isLoading)
                Center(child: CircularProgressIndicator(color: Colors.white))
              else if (_noToolsFound)
                Padding(
                  padding: const EdgeInsets.only(top: 50.0),
                  child: Center(
                    child: Text(
                      'No products exist for this shop',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return productTile(
                        context,
                        product['title']!,
                        product['price']!,
                        product['image']!,
                        product['description']!,
                        widget.shopEmail,
                        product,
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget productTile(
      BuildContext context,
      String title,
      String price,
      String image,
      String description,
      String shopEmail,
      Map<String, dynamic> product) {
    // Ensure the base64 string length is a multiple of 4
    String formattedImage = image;
    if (formattedImage.length % 4 != 0) {
      formattedImage += '=' * (4 - (formattedImage.length % 4));
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        contentPadding: EdgeInsets.all(12),
        leading: Hero(
          tag: title,
          child: Image(
            image: MemoryImage(
              base64Decode(formattedImage),
            ),
            height: 60,
            width: 60,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          price,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.green,
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.black),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ToolDetails(
                title: title,
                price: price,
                image: image,
                description: description,
                shopEmail: shopEmail,
                shopPhone: widget.shopPhone,
                product: {
                  ...product,
                  'shop_id': widget.shopId, // Add shop_id here
                },
              ),
            ),
          );
        },
      ),
    );
  }
}