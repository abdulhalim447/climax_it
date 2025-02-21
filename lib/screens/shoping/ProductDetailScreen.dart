import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:climax_it_user_app/screens/shoping/CartScreen.dart';
import 'package:climax_it_user_app/screens/shoping/product.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _isFavorite = false;

  // Track if the product is added to favorites
  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favoritesJson = prefs.getStringList('favorites') ?? [];
    List<Product> favorites = favoritesJson
        .map((jsonStr) => Product.fromJson(json.decode(jsonStr)))
        .toList();

    setState(() {
      _isFavorite = favorites.any(
          (favProduct) => favProduct.productCode == widget.product.productCode);
    });
  }



  Future<void> _addToFavorites(Product product) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favoritesJson = prefs.getStringList('favorites') ?? [];
    List<Product> favorites = favoritesJson
        .map((jsonStr) => Product.fromJson(json.decode(jsonStr)))
        .toList();

    if (!favorites
        .any((favProduct) => favProduct.productCode == product.productCode)) {
      favorites.add(product); // Add the Product object directly
      favoritesJson = favorites
          .map((product) => json.encode(product.toJson()))
          .toList(); // Convert back to JSON strings
      await prefs.setStringList('favorites', favoritesJson);
      setState(() {
        _isFavorite = true;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Added to Favorites!")));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Already in Favorites!")));
    }
  }

  Future<void> _removeFromFavorites(Product product) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favoritesJson = prefs.getStringList('favorites') ?? [];
    List<Product> favorites = favoritesJson
        .map((jsonStr) => Product.fromJson(json.decode(jsonStr)))
        .toList();

    favorites.removeWhere(
        (favProduct) => favProduct.productCode == product.productCode);
    favoritesJson =
        favorites.map((product) => json.encode(product.toJson())).toList();
    await prefs.setStringList('favorites', favoritesJson);
    setState(() {
      _isFavorite = false;
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Removed from Favorites!")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => CartScreen()));
              },
              icon: const Icon(Icons.shopping_cart)),
          // this is add to  cart  button
          IconButton(onPressed: () {}, icon: const Icon(Icons.download)),
        ],
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Product Details",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            // Import the services package

            Row(
              children: [
                Text("Product Code: ${widget.product.productCode}",
                    style:
                        const TextStyle(fontSize: 13, color: Colors.white70)),
                IconButton(
                  onPressed: () {
                    // Copy product code to clipboard
                    Clipboard.setData(
                            ClipboardData(text: widget.product.productCode))
                        .then((_) {
                      // You can show a snackbar or a confirmation message
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Product Code Copied!")),
                      );
                    });
                  },
                  icon: const Icon(Icons.copy, size: 18), // Copy button
                ),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CachedNetworkImage(
                imageUrl: widget.product.thumbnail,
                height: 300,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.product.images.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: CachedNetworkImage(
                        imageUrl: widget.product.images[index],
                        height: 60,
                        width: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.product.productName,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                      onPressed: () {
                        Clipboard.setData(
                                ClipboardData(text: widget.product.productName))
                            .then((_) {
                          // You can show a snackbar or a confirmation message
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Copied!")),
                          );
                        });
                      },
                      icon: const Icon(Icons.copy, size: 18)),
                  // এই বাটনে ক্লিক করলে product.productName কপি হবে
                  IconButton(
                    onPressed: () {
                      if (_isFavorite) {
                        _removeFromFavorites(
                            widget.product); // Remove from favorites
                      } else {
                        _addToFavorites(widget.product); // Add to favorites
                      }
                    },
                    icon: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_outline,
                      size: 18,
                      color: _isFavorite ? Colors.red : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text("Stock: ${widget.product.stock}",
                  style: const TextStyle(fontSize: 16, color: Colors.green)),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "Admin Price: ৳${widget.product.adminPrice}",
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "Reseller Price: ৳${widget.product.resellerPrice}",
                  style: const TextStyle(fontSize: 18, color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.maxFinite,
                child: ElevatedButton(
                  onPressed: () {
                    _addToCart(widget.product);
                  },
                  child: const Text(
                    'Add to Cart',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.maxFinite,
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text(
                    'Order Now',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Product Details:",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(
                    onPressed: () {
                      // Copy product code to clipboard
                      Clipboard.setData(
                              ClipboardData(text: widget.product.description))
                          .then((_) {
                        // You can show a snackbar or a confirmation message
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text(" Copied!")),
                        );
                      });
                    },
                    icon: const Icon(Icons.copy, size: 18), // Copy button
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(widget.product.description,
                  style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addToCart(Product product) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> cartJson = prefs.getStringList('cart') ?? [];

    // Print the current cart before adding a new product
    print("Current Cart before adding: $cartJson");

    List<Product> cart = cartJson
        .map((jsonStr) => Product.fromJson(json.decode(jsonStr)))
        .toList();

    if (!cart.any((cartProduct) => cartProduct.productCode == product.productCode)) {
      cart.add(product);
      cartJson = cart.map((p) => json.encode(p.toJson())).toList();
      await prefs.setStringList('cart', cartJson);

      // Print the cart after adding the product
      print("Cart after adding product: $cartJson");

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Added to Cart!"))
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Already in Cart!"))
      );
    }
  }


}
