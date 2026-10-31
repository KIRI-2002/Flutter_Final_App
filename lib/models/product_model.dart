class ProductModel {
  int code;
  String name;
  String category;
  double oldprice;
  int discount;
  String image;
  int quantity;
  String rate;
  String view;
  String description;
  List<String> size;
  List<String> color;

  ProductModel({
    required this.category,
    required this.code,
    this.quantity = 1,
    required this.color,
    required this.description,
    required this.discount,
    required this.image,
    required this.name,
    required this.oldprice,
    required this.rate,
    required this.size,
    required this.view,
  });

  double get price => oldprice - (oldprice * discount) / 100;

  static String _resolveImageUrl(dynamic rawImage) {
    final image = rawImage?.toString().trim() ?? '';

    if (image.isEmpty) {
      return '';
    }

    if (image.startsWith('http://') ||
        image.startsWith('https://')) {
      return image;
    }

    if (image.startsWith('assets/')) {
      return image;
    }

    final path = image.replaceFirst(RegExp(r'^/+'), '');

    if (path.startsWith('storage/')) {
      return 'http://10.0.2.2:8000/$path';
    }

    return 'http://10.0.2.2:8000/storage/$path';
  }

  factory ProductModel.fromLaravel(Map<String, dynamic> json) {
    final rawCategory = json['category'];

    String categoryName = 'Other';

    if (rawCategory is Map) {
      categoryName =
          rawCategory['name']?.toString() ?? 'Other';
    } else if (rawCategory is String &&
        rawCategory.trim().isNotEmpty) {
      categoryName = rawCategory.trim();
    } else {
      categoryName =
          json['category_name']?.toString() ?? 'Other';
    }

    final imageUrl = _resolveImageUrl(
      json['image_url'] ??
          json['image'] ??
          json['image_path'],
    );

    return ProductModel(
      code: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? 'Unnamed product',
      category: categoryName,
      oldprice:
          double.tryParse(json['price']?.toString() ?? '') ?? 0,
      discount: 0,
      image: imageUrl,
      quantity:
          int.tryParse(json['stock']?.toString() ?? '') ?? 0,
      rate: 'N/A',
      view: '0',
      description: json['description']?.toString() ?? '',
      size: const [],
      color: const [],
    );
  }
}