class Product {
  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.specification,
    required this.diameterInches,
    required this.lengthMeters,
    required this.nominalWeight,
    required this.unitOfMeasure,
    required this.price,
    required this.stock,
    this.description = '',
    this.imageBase64,
    this.pdfBase64,
    this.pdfName,
  });

  final String id;
  final String name;
  final String category;
  final String specification;
  final double diameterInches;
  final double lengthMeters;
  final double nominalWeight;
  final String unitOfMeasure;
  final double price;
  final int stock;
  final String description;
  
  // Nuevos campos para archivos
  final String? imageBase64;
  final String? pdfBase64;
  final String? pdfName;

  String get dimension => '${lengthMeters.toStringAsFixed(1)} m • ${diameterInches.toStringAsFixed(1)}"';
  String get priceLabel => 'S/ ${price.toStringAsFixed(2)}';
  String get weightLabel => '${nominalWeight.toStringAsFixed(2)} kg/m';

  factory Product.fromJson(Map<String, dynamic> json, String id) {
    return Product(
      id: id,
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      specification: json['specification'] ?? '',
      diameterInches: (json['diameterInches'] ?? 0).toDouble(),
      lengthMeters: (json['lengthMeters'] ?? 0).toDouble(),
      nominalWeight: (json['nominalWeight'] ?? 0).toDouble(),
      unitOfMeasure: json['unitOfMeasure'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      stock: json['stock'] ?? 0,
      description: json['description'] ?? '',
      imageBase64: json['imageBase64'],
      pdfBase64: json['pdfBase64'],
      pdfName: json['pdfName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'specification': specification,
      'diameterInches': diameterInches,
      'lengthMeters': lengthMeters,
      'nominalWeight': nominalWeight,
      'unitOfMeasure': unitOfMeasure,
      'price': price,
      'stock': stock,
      'description': description,
      'imageBase64': imageBase64,
      'pdfBase64': pdfBase64,
      'pdfName': pdfName,
    };
  }
}
