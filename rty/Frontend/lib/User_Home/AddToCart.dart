import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tap_on/Home%20page.dart';

class Cart {
  static List<CartItem> cartItems = [];

  static void addToCart(CartItem item) {
    cartItems.add(item);
  }
}

class addtocart extends StatelessWidget {
  const addtocart({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ReviewCartPage(),
    );
  }
}

class ReviewCartPage extends StatefulWidget {
  const ReviewCartPage({super.key});

  @override
  _ReviewCartPageState createState() => _ReviewCartPageState();
}

class _ReviewCartPageState extends State<ReviewCartPage> {
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
        imageUrl: productMap['image'],
        tag: productMap['tag'],
        quantity: int.parse(productMap['quantity']), shopEmail: '', product: null,
      ));
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.push(context,
               MaterialPageRoute(builder: (context) => HomePage()));
            },
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              setState(() {
                Cart.cartItems.clear();
              });
            },
            child: const Text("Clear", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
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
                : const Center(
                    child: Text("Your cart is empty"),
                  ),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: MediaQuery.of(context).size.width * 0.05),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 4)],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Rs.${Cart.cartItems.fold<double>(0.0, (sum, item) => sum + item.price * item.quantity).toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text("Checkout"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CartItem {
  final String name;
  final String category;
  final double price;
  final String imageUrl;
  final String tag;
  int quantity;

  CartItem({
    required this.name,
    required this.category,
    required this.price,
    required this.imageUrl,
    required this.tag,
    this.quantity = 1, required String shopEmail, required product,
  });
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
              Image.network(
                item.imageUrl,
                height: screenWidth * 0.2,
                width: screenWidth * 0.2,
                fit: BoxFit.cover,
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
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                color: Colors.red,
                child: Text(
                  item.tag,
                  style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.03),
                ),
              ),
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
                    icon: Icon(Icons.add, color: Colors.red, size: screenWidth * 0.06),
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