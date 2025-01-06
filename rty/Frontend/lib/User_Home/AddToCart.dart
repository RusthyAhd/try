// ignore_for_file: unused_element

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tap_on/Home%20page.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:quickalert/quickalert.dart';
import 'package:tap_on/User_Tools/UT_ProviderOrderStatus.dart';
import 'package:tap_on/widgets/Loading.dart';

class CartItem {
  final String name;
  final String category;
  final double price;
  final String imageUrl;
  final String tag;
  final String shopEmail;
  final dynamic product;
  int quantity;

  CartItem({
    required this.name,
    required this.category,
    required this.price,
    required this.imageUrl,
    required this.tag,
    required this.shopEmail,
    required this.product,
    this.quantity = 1,
  });
}

class Cart {
  static List<CartItem> cartItems = [];

  static void addToCart(CartItem item) {
    cartItems.add(item);
  }
}

class AddToCart extends StatelessWidget {
  const AddToCart({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ReviewCartPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ReviewCartPage extends StatefulWidget {
  const ReviewCartPage({super.key});

  @override
  _ReviewCartPageState createState() => _ReviewCartPageState();
}

class CartItemWidget extends StatelessWidget {
  final CartItem item;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const CartItemWidget({
    super.key,
    required this.item,
    required this.onAdd,
    required this.onRemove,
  });

  bool isBase64(String str) {
    try {
      base64Decode(str);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: 8.0),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
                Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.transparent, width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image(
                  image: isBase64(item.imageUrl)
                  ? MemoryImage(base64Decode(item.imageUrl))
                  : NetworkImage(item.imageUrl) as ImageProvider,
                  height: screenWidth * 0.2,
                  width: screenWidth * 0.2,
                  fit: BoxFit.cover,
                  ),
                ),
                ),
              const SizedBox(height: 8),
              Text(
                item.name,
                style: TextStyle(fontSize: screenWidth * 0.04, fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(item.category, style: TextStyle(fontSize: screenWidth * 0.035, color: Colors.grey)),
              const SizedBox(height: 4),
              Text("Rs.${item.price.toStringAsFixed(2)}", style: TextStyle(fontSize: screenWidth * 0.04)),
              Text("(inclusive of all taxes)", style: TextStyle(fontSize: screenWidth * 0.03, color: Colors.grey)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: onRemove,
                    icon: Icon(Icons.remove, color: Colors.red, size: screenWidth * 0.06),
                  ),
                  Text(
                    item.quantity.toString(),
                    style: TextStyle(fontSize: screenWidth * 0.04, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: onAdd,
                    icon: Icon(Icons.add, color: Colors.blue, size: screenWidth * 0.06),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewCartPageState extends State<ReviewCartPage> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProductFromPreferences();
  }

  Future<void> _loadProductFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? productString = prefs.getString('selectedProduct');

    if (productString != null) {
      Map<String, dynamic> productMap = jsonDecode(productString);
      Cart.addToCart(CartItem(
        name: productMap['title'],
        category: productMap['category'],
        price: double.parse(productMap['price']),
        imageUrl: productMap['pic'],
        tag: productMap['tag'],
        quantity: int.parse(productMap['quantity']),
        shopEmail: productMap['shopEmail'],
        product: productMap,
      ));
      setState(() {});
    }
  }

  void _showErrorAlert() {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: 'Oops...',
      text: 'Sorry, something went wrong',
      backgroundColor: Colors.black,
      titleColor: Colors.white,
      textColor: Colors.white,
    );
  }

  Future<void> _checkout() async {
    LoadingDialog.show(context);

    try {
      final baseURL = dotenv.env['BASE_URL'];
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      for (var item in Cart.cartItems) {
        final bodyData = {
          "tool_id": item.name,
          "shop_id": item.shopEmail,
          "title": item.name,
          "qty": item.quantity,
          "days": 1,
          "status": "pending",
          "date": DateTime.now().toString(),
        };

        final response = await http.post(
          Uri.parse('$baseURL/to/new'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': '$token',
          },
          body: jsonEncode(bodyData),
        );

        final data = jsonDecode(response.body);

        if (data['status'] != 200) {
          LoadingDialog.hide(context);
          _showErrorAlert();
          return;
        }
      }

      LoadingDialog.hide(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ),
      );
    } catch (e) {
      LoadingDialog.hide(context);
      debugPrint('Something went wrong $e');
      _showErrorAlert();
    }
  }

  void _showCheckoutConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        double totalPrice = Cart.cartItems.fold(0, (sum, item) => sum + item.price * item.quantity);

        return AlertDialog(
          title: const Text('Confirm Checkout'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...Cart.cartItems.map((item) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tool: ${item.name}'),
                  Text('Amount: LKR ${item.price} x ${item.quantity}'),
                  Text('Total: LKR ${item.price * item.quantity}'),
                  SizedBox(height: 10),
                ],
              )),
              Text('Total Amount: LKR ${totalPrice.toStringAsFixed(2)}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _submitOrder(totalPrice);
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitOrder(double totalAmount) async {
    try {
      setState(() => _isLoading = true);
      final baseURL = dotenv.env['BASE_URL'];
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      for (var item in Cart.cartItems) {
        final bodyData = {
          "order_id": DateTime.now().millisecondsSinceEpoch.toString(),
          "tool_id": item.name,
          "shop_id": item.shopEmail,
          "customer_id": prefs.getString('userPhone') ?? '',
          "title": item.name,
          "qty": item.quantity,
          "days": 1,
          "total_price": totalAmount,
          "status": "pending",
          "date": DateTime.now().toString(),
        };

        final response = await http.post(
          Uri.parse('$baseURL/tool-order/new'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': '$token',
          },
          body: jsonEncode(bodyData),
        );

        final data = jsonDecode(response.body);

        if (data['status'] != 200) {
          _showErrorAlert();
          return;
        }

        // Navigate to UT_ProviderOrderStatus page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UT_ProviderOrderStatus(
              provider: {}, // Pass the provider details if needed
              status: 'Order Placed Successfully!',
              order: data['data'], // Pass the order details
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Something went wrong $e');
      _showErrorAlert();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalPrice = Cart.cartItems.fold(0, (sum, item) => sum + item.price * item.quantity);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
            },
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              setState(() {
                Cart.cartItems.clear();
              });
            },
            child: const Text("Clear", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Expanded(
            child: Cart.cartItems.isNotEmpty
              ? ListView.builder(
                  itemCount: Cart.cartItems.length,
                  itemBuilder: (context, index) {
                    return CartItemWidget(
                      item: Cart.cartItems[index],
                      onAdd: () {
                        setState(() {
                          Cart.cartItems[index].quantity++;
                        });
                      },
                      onRemove: () {
                        setState(() {
                          if (Cart.cartItems[index].quantity > 1) {
                            Cart.cartItems[index].quantity--;
                          } else {
                            Cart.cartItems.removeAt(index);
                          }
                        });
                      },
                    );
                  },
                )
              : const Center(child: Text('No items in the cart')),
          ),
          SizedBox(height: 20), // Add some space above the button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                'Total: Rs.${totalPrice.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: _showCheckoutConfirmation,
                child: const Text('CheckOut'),
              ),
            ],
          ),
          SizedBox(height: 20), // Add some space below the button
        ],
      ),
    );
  }
}
