import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:climax_it_user_app/screens/shoping/product.dart';

import 'checkout_screen.dart';


class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<Product> _cartItems = [];
  Map<String, int> _quantities = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  Future<void> _loadCartItems() async {
    setState(() => _isLoading = true);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> cartJson = prefs.getStringList('cart') ?? [];
      setState(() {
        _cartItems = cartJson
            .map((jsonStr) => Product.fromJson(json.decode(jsonStr)))
            .toList();
        for (var product in _cartItems) {
          _quantities[product.id] = _quantities[product.id] ?? 1;
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading cart: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveCart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Product> updatedCart = [];

    for (var product in _cartItems) {
      if ((_quantities[product.id] ?? 0) > 0) {
        updatedCart.add(product);
      }
    }

    List<String> cartJson =
        updatedCart.map((product) => json.encode(product.toJson())).toList();
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
      total +=
          double.parse(product.adminPrice) * (_quantities[product.id] ?? 1);
    }
    return total;
  }

  void _clearCart() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('কার্ট খালি করুন'),
        content: const Text('আপনি কি নিশ্চিত যে আপনি কার্ট খালি করতে চান?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('না'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() {
                _cartItems.clear();
                _quantities.clear();
              });
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setStringList('cart', []);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('কার্ট খালি করা হয়েছে')),
              );
            },
            child: const Text('হ্যাঁ'),
          ),
        ],
      ),
    );
  }

  void _removeFromCart(Product product) async {
    setState(() {
      _cartItems.remove(product);
      _quantities.remove(product.id);
    });
    await _saveCart();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product.productName} কার্ট থেকে সরানো হয়েছে')),
    );
  }

  void _proceedToCheckout() {
    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('কার্ট খালি!')),
      );
      return;
    }

    // Create a list of products with their quantities
    List<Map<String, dynamic>> checkoutItems = _cartItems.map((product) {
      return {
        'product': product,
        'quantity': _quantities[product.id] ?? 1,
      };
    }).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(
          product: _cartItems.first, // Send first product for now
          initialQuantity: _quantities[_cartItems.first.id] ?? 1,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('শপিং কার্ট'),
        actions: [
          if (_cartItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _clearCart,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _cartItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.remove_shopping_cart,
                          size: 80, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('আপনার কার্ট খালি',
                          style: TextStyle(fontSize: 18)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('শপিং করুন'),
                      ),
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
                          return Dismissible(
                            key: Key(product.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              color: Colors.red,
                              child:
                                  const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (direction) =>
                                _removeFromCart(product),
                            child: Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: CachedNetworkImage(
                                        imageUrl: product.thumbnail,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product.productName,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'মূল্য: ৳${product.adminPrice}',
                                            style: const TextStyle(
                                                color: Colors.green),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove),
                                          onPressed: () =>
                                              _updateQuantity(product, -1),
                                        ),
                                        Text(
                                          '${_quantities[product.id] ?? 1}',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.add),
                                          onPressed: () =>
                                              _updateQuantity(product, 1),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Card(
                      margin: const EdgeInsets.all(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('মোট পণ্য:'),
                                Text('${_cartItems.length}টি'),
                              ],
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'মোট মূল্য:',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '৳${_calculateTotalPrice().toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _proceedToCheckout,
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: const Text('অর্ডার করুন'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
