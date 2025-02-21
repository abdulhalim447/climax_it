import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:climax_it_user_app/screens/shoping/product.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<Product> _cartItems = [];
  Map<String, int> _quantities = {};

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  Future<void> _loadCartItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> cartJson = prefs.getStringList('cart') ?? [];

    setState(() {
      _cartItems = cartJson.map((jsonStr) => Product.fromJson(json.decode(jsonStr))).toList();
      for (var product in _cartItems) {
        _quantities[product.id] = _quantities[product.id] ?? 1;
      }
    });
  }

  Future<void> _saveCart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Product> updatedCart = [];

    for (var product in _cartItems) {
      if ((_quantities[product.id] ?? 0) > 0) {
        updatedCart.add(product);
      }
    }

    List<String> cartJson = updatedCart.map((product) => json.encode(product.toJson())).toList();
    await prefs.setStringList('cart', cartJson);
  }

  void _updateQuantity(Product product, int change) {
    setState(() {
      int newQuantity = (_quantities[product.id] ?? 1) + change;

      if (newQuantity > 0) {
        _quantities[product.id] = newQuantity;
      } else {
        _cartItems.remove(product);
        _quantities.remove(product.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${product.productName} removed from cart')),
        );
      }
      _saveCart();
    });
  }

  double _calculateTotalPrice() {
    double total = 0;
    for (var product in _cartItems) {
      total += (product.resellerPriceAsDouble ?? 0.0) * (_quantities[product.id] ?? 1);
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shopping Cart')),
      body: _cartItems.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.remove_shopping_cart, size: 80, color: Colors.grey),
            const SizedBox(height: 10),
            const Text('Your cart is empty.', style: TextStyle(fontSize: 18)),
          ],
        ),
      )
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _cartItems.length,
              itemBuilder: (context, index) {
                final product = _cartItems[index];
                return Card(
                  child: ListTile(
                    leading: CachedNetworkImage(
                      imageUrl: product.thumbnail,
                      width: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(product.productName),
                    subtitle: Text('৳${(product.resellerPriceAsDouble ?? 0.0).toStringAsFixed(2)}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () => _updateQuantity(product, -1),
                        ),
                        Text('${_quantities[product.id] ?? 1}'),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => _updateQuantity(product, 1),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text('Total: ৳${_calculateTotalPrice().toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    // Implement checkout functionality
                  },
                  child: const Text('Proceed to Checkout'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
