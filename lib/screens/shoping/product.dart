class Product {
  final String id;
  final String name;
  final String productName;
  final String productCode;
  final String thumbnail;
  final List<String> images;
  final String stock;
  final String adminPrice;
  final String resellerPrice;
  final String description;
  final String category_id;
  final String discount;

  Product({
    required this.id,
    required this.name,
    required this.productName,
    required this.productCode,
    required this.thumbnail,
    required this.images,
    required this.stock,
    required this.adminPrice,
    required this.resellerPrice,
    required this.description,
    required this.category_id,
    required this.discount,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      productName: json['productName'] ?? '',
      category_id: json['productName'] ?? '',
      productCode: json['productCode'] ?? '',
      thumbnail: (json['thumbnail'] ?? '').replaceAll(r"\", ''),
      images: json['images'] is List
          ? List<String>.from(json['images'])
          : (json['images'] ?? '').toString().split(',').map((e) => e.trim()).toList(),
      stock: json['stock'] ?? '0',
      adminPrice: json['adminPrice'] ?? '0',
      resellerPrice: json['resellerPrice'] ?? '0',
      description: json['description'] ?? 'No description available',
      discount: json['discount'] ?? '0%',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'productName': productName,
      'productCode': productCode,
      'thumbnail': thumbnail,
      'images': images,
      'stock': stock,
      'adminPrice': adminPrice,
      'resellerPrice': resellerPrice,
      'description': description,
      'discount': discount,
    };
  }

  double? get resellerPriceAsDouble {
    return double.tryParse(resellerPrice);
  }
}