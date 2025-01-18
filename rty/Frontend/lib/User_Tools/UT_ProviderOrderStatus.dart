import 'package:flutter/material.dart';
import 'package:tap_on/Home%20page.dart';
import 'package:url_launcher/url_launcher.dart';

class UT_ProviderOrderStatus extends StatelessWidget {
  final Map<String, dynamic> provider;
  final String status;
  final Map<String, dynamic> order;

  const UT_ProviderOrderStatus({
    super.key, 
    required this.provider,
    required this.status,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Order Confirmation', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 20),
              Text(
                'Order Placed Successfully!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Icon(Icons.check_circle, color: Colors.green, size: 100),
              SizedBox(height: 20),
              Text(
                'Order ID: ${order['order_id']}',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              var shopPhone;
                              launchUrl(Uri.parse('tel:$shopPhone'));
                            },
                            icon: Icon(Icons.phone, color: Colors.black),
                            label: Text('Call',
                                style: TextStyle(color: Colors.black)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[700],
                              side: BorderSide(color: Colors.black),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              var shopPhone;
                              launchUrl(Uri.parse('sms:$shopPhone'));
                            },
                            icon: Icon(Icons.message, color: Colors.black),
                            label: Text('Message',
                                style: TextStyle(color: Colors.black)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[700],
                              side: BorderSide(color: Colors.black),
                              
                            ),

                            
                          ),
                      
                        ),
                      ],
                    ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                    (Route<dynamic> route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.yellow,
                ),
                child: Text('Back to Home'),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
