import 'package:climax_it_user_app/screens/shoping/favourite_Screen.dart';
import 'package:climax_it_user_app/screens/shoping/product.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'ProductItem.dart';
import 'all_products.dart';

class ShoppingScreen extends StatefulWidget {
  const ShoppingScreen({super.key});

  @override
  State<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends State<ShoppingScreen> {
  late Future<List<Product>> _futureProducts;
  TextEditingController _searchController = TextEditingController();
  List<Product> allProducts = [];
  List<Product> filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _futureProducts = _fetchProducts();
  }

  // Fetching product data from the API
  Future<List<Product>> _fetchProducts() async {
    try {
      final response = await http.get(
        Uri.parse('https://climaxitbd.com/php/shopping/get-products-items.php'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        print('Data fetched: ${data.length} items');

        // Initialize allProducts and filteredProducts
        allProducts = data.map((json) => Product.fromJson(json)).toList();
        filteredProducts = allProducts; // Initially show all products
        return allProducts;
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching products: $e');
      throw Exception('Error fetching products: $e');
    }
  }

  // Filter products based on search query
  void _filterProducts(String query) {
    final filtered = allProducts.where((product) {
      return product.productName.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredProducts = filtered;
    });
  }

  // Group products by category name
  Map<String, List<Product>> _groupProductsByCategory(List<Product> products) {
    Map<String, List<Product>> groupedProducts = {};

    for (var product in products) {
      String category = product.name; // Use 'name' as category
      if (!groupedProducts.containsKey(category)) {
        groupedProducts[category] = [];
      }
      groupedProducts[category]!.add(product);
    }

    return groupedProducts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('শপিং'),

      actions: [
        IconButton(onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>FavoriteScreen()));
        }, icon: Icon(Icons.favorite_sharp))
      ],
      ),
      body: Column(
        children: [
          // Search TextField
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterProducts, // Filter products as user types
              decoration: InputDecoration(
                hintText: 'পণ্য খুঁজুন...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          // FutureBuilder to fetch data
          Expanded(
            child: FutureBuilder<List<Product>>(
              future: _futureProducts,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: Transform.scale(scale: 1.2,child: CircularProgressIndicator()));
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                // Data is available, proceed to display
                final products = filteredProducts.isEmpty ? snapshot.data! : filteredProducts;
                final groupedProducts = _groupProductsByCategory(products);

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: groupedProducts.entries.map((entry) {
                        return _buildCategorySection(context, entry.key, entry.value);
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Build UI for each category and products under it
  Widget _buildCategorySection(BuildContext context, String category, List<Product> products) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(category, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AllProductsScreen(products: products),
                  ),
                ),
                child: const Text('সব দেখুন..'),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            itemBuilder: (context, index) => ProductItem(product: products[index]),
          ),
        ),
      ],
    );
  }
}
