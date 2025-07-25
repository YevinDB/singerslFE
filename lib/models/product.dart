class Product {
  final int? id;
  final String productCode;
  final String productName;
  final double price;

  Product({
    this.id,
    required this.productCode,
    required this.productName,
    required this.price,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      productCode: json['productCode'] ?? '',
      productName: json['productName'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productCode': productCode,
      'productName': productName,
      'price': price,
    };
  }

  Product copyWith({
    int? id,
    String? productCode,
    String? productName,
    double? price,
  }) {
    return Product(
      id: id ?? this.id,
      productCode: productCode ?? this.productCode,
      productName: productName ?? this.productName,
      price: price ?? this.price,
    );
  }
}
