import 'package:climax_it_user_app/screens/shoping/product.dart';
import 'package:flutter/material.dart';

import 'ProductItem.dart';

class AllProductsScreen extends StatelessWidget {
  final List<Product> products;

  const AllProductsScreen({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('সকল প্রোডাক্ট')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          itemCount: products.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.6,

          ),
          itemBuilder: (context, index) =>
              ProductItem(product: products[index]),
        ),
      ),
    );
  }
}
