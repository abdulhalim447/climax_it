import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:climax_it_user_app/screens/shoping/product.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ProductDetailScreen.dart';

class ProductItem extends StatefulWidget {
  final Product product;

  const ProductItem({super.key, required this.product});

  @override
  State<ProductItem> createState() => _ProductItemState();
}

class _ProductItemState extends State<ProductItem> {
  bool _isFavorite = false;

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
      _isFavorite = favorites.any((favProduct) =>
      favProduct.productCode == widget.product.productCode);
    });
  }

  Future<void> _addToFavorites(Product product) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favoritesJson = prefs.getStringList('favorites') ?? [];
    List<Product> favorites = favoritesJson
        .map((jsonStr) => Product.fromJson(json.decode(jsonStr)))
        .toList();

    if (!favorites.any((favProduct) =>
    favProduct.productCode == product.productCode)) {
      favorites.add(product);
      favoritesJson =
          favorites.map((product) => json.encode(product.toJson())).toList();
      await prefs.setStringList('favorites', favoritesJson);
      setState(() {
        _isFavorite = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Added to Favorites!")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Already in Favorites!")));
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
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Removed from Favorites!")));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetailScreen(product: widget.product),
        ),
      ),
      child: Container(
        width: 180,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 3,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Stack( // Use a Stack to overlay icons
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
                  child: CachedNetworkImage(
                    imageUrl: widget.product.thumbnail,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                    Transform.scale(scale: 1.5, child: const CircularProgressIndicator()),
                    errorWidget: (context, url, error) =>
                    const Icon(Icons.error),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    widget.product.productName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    'TK ${widget.product.resellerPrice} | Stock ${widget.product.stock}',
                    style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            Positioned( // Favorite Icon
              top: 8,
              right: 8,
              child: IconButton(
                onPressed: () {
                  if (_isFavorite) {
                    _removeFromFavorites(widget.product);
                  } else {
                    _addToFavorites(widget.product);
                  }
                },
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_outline,
                  color: _isFavorite ? Colors.red : Colors.grey,
                ),
              ),
            ),
            if (widget.product.discount != "0%" && widget.product.discount != '0') // Discount Prize
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.product.discount,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}