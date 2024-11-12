import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tap_on/User_Tools/UT_ProviderOrderStatus.dart';
import 'package:http/http.dart' as http;

class UT_ToolRequest extends StatefulWidget {
  final Map<String, dynamic> product;
  final String shopEmail;

  const UT_ToolRequest({
    super.key,
    required this.product,
    required this.shopEmail,
  });

  @override
  State<UT_ToolRequest> createState() => _UT_ToolRequestState();
}

class _UT_ToolRequestState extends State<UT_ToolRequest> {
  int quantity = 0;
  final _qytController = TextEditingController(text: '0');
  String? _userId;
  String? _userName;
  String? _userPhone;
  String? _userAddress;
  String? _userLocation;
  bool _isLoading = false;
  final _addressController = TextEditingController();
  final _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('userId') ?? '';
      _userName = prefs.getString('userName') ?? '';
      _userPhone = prefs.getString('userPhone') ?? '';
      _userAddress = prefs.getString('userAddress') ?? '';
      _userLocation = prefs.getString('userLocation') ?? '';
    });
  }

  Future<void> _submitOrder(double totalAmount) async {
    try {
      setState(() => _isLoading = true);
      final baseURL = dotenv.env['BASE_URL'];

      if (baseURL == null) {
        throw Exception('BASE_URL not found in environment');
      }

      // Update orderData with correct fields from product
      final orderData = {
        'order_id': 'TO-${DateTime.now().millisecondsSinceEpoch}',
        'tool_id': widget.product['id'] ?? '',
        'shop_id': widget.product['shop_id'] ?? '', // Ensure shop_id is passed from UT_ToolMenu
        'customer_id': 'GUEST-${DateTime.now().millisecondsSinceEpoch}',
        'customer_name': _addressController.text,
        'customer_address': _addressController.text,
        'customer_location': _locationController.text,
        'customer_number': widget.shopEmail,
        'title': widget.product['title'] ?? '',
        'qty': quantity,
        'days': 1,
        'total_price': totalAmount,
        'status': 'pending',
        'date': DateTime.now().toIso8601String(),
      };

      print('Submitting order data: $orderData'); // Debug log

      final response = await http.post(
        Uri.parse('$baseURL/tool-order/new'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(orderData),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        if (!mounted) return;
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => UT_ProviderOrderStatus(
              provider: widget.product,
              status: 'pending',
              order: orderData,
            ),
          ),
        );
      } else {
        throw Exception('Failed to place order: ${response.body}');
      }
    } catch (e) {
      print('Error submitting order: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Update showConfirmDialog to include form validation
  void _showConfirmDialog() {
    if (_addressController.text.isEmpty || _locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    double originalPrice = double.parse(widget.product['price'].toString());
    double discount = double.parse(widget.product['discount'] ?? '0');
    double discountedPrice = originalPrice - (originalPrice * discount / 100);
    double totalAmount = discountedPrice * quantity;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quantity: $quantity'),
            Text('Price per item: LKR ${discountedPrice.toStringAsFixed(2)}'),
            Text('Total Amount: LKR ${totalAmount.toStringAsFixed(2)}'),
            Text('Delivery Address: ${_addressController.text}'),
            Text('Location: ${_locationController.text}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _submitOrder(totalAmount);
            },
            child: Text('Confirm'),
          ),
        ],
      ),
    );
  }

  bool isBase64(String str) {
    try {
      base64Decode(str);
      return true;
    } catch (_) {
      return false;
    }
  }

  double calculateTotal() {
    double originalPrice = double.parse(widget.product['price']);
    double discount = double.parse(widget.product['discount'] ?? '0');
    double discountedPrice = originalPrice - (originalPrice * discount / 100);
    return discountedPrice * quantity;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Request Products', style: TextStyle(color: Colors.black, fontSize: screenWidth * 0.05)),
        centerTitle: true,
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator())
        : Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color.fromARGB(255, 109, 236, 113), Colors.green[500]!,const Color.fromARGB(255, 57, 146, 60)!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 75.0),
          child: SingleChildScrollView(
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: screenHeight * 0.05),
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: widget.product['image'] != null && widget.product['image'].isNotEmpty && isBase64(widget.product['image'])
                            ? Image.memory(
                                base64Decode(widget.product['image']),
                                height: screenWidth * 0.4,
                                width: screenWidth * 0.4,
                                fit: BoxFit.cover,
                              )
                            : Icon(Icons.image, size: screenWidth * 0.4, color: Colors.grey[400]),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    _buildInfoRow("Product", widget.product['title']),
                    _buildInfoRow("Availability", widget.product['availability']),
                    _buildInfoRow("Amount", "LKR ${widget.product['price']} per product"),
                    _buildInfoRow("Available Quantity", widget.product['quantity']),
                    SizedBox(height: screenHeight * 0.02),
                    Text("Enter Quantity", style: TextStyle(fontSize: screenWidth * 0.05, fontWeight: FontWeight.bold)),
                    SizedBox(height: screenHeight * 0.01),
                    Row(
                      children: [
                        

                        
                       IconButton(
  icon: Icon(Icons.remove_circle, color: Colors.redAccent),
  iconSize: 30.0, // Increase the size of the icon
  padding: EdgeInsets.all(8.0), // Adjust padding
  constraints: BoxConstraints(minWidth: 48, minHeight: 48), // Increase clickable area
  onPressed: quantity > 0
      ? () => setState(() {
          quantity--;
          _qytController.text = quantity.toString();
        })
      : null,
),


                        SizedBox(
                          width: 50,
                          child: TextField(
                            controller: _qytController,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(border: InputBorder.none),
                            onChanged: (value) {
                              setState(() {
                                quantity = int.tryParse(value) ?? 1;
                              });
                            },
                          ),
                        ),
                       IconButton(
  icon: Icon(Icons.add_circle, color: Colors.blueAccent),
  iconSize: 30.0, // Increase the size of the icon
  padding: EdgeInsets.all(8.0), // Adjust padding for a larger tap area
  constraints: BoxConstraints(minWidth: 48, minHeight: 48), // Increase clickable area
  onPressed: quantity < int.parse(widget.product['quantity'] ?? '1')
      ? () => setState(() {
          quantity++;
          _qytController.text = quantity.toString();
        })
      : null,
),


                      ],
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    TextField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: 'Delivery Address*',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        labelText: 'Location*',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.04),
                    Center(
                      child: ElevatedButton(
                        onPressed: quantity > 0 ? _showConfirmDialog : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.2, vertical: 15),
                        ),
                        child: Text('Request Now', style: TextStyle(fontSize: screenWidth * 0.045)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("$title:", style: TextStyle(fontWeight: FontWeight.bold)),
          Text(value ?? 'N/A', style: TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }
}
