import 'package:flutter/material.dart';

class SellerProduct {
  int? id;
  String name;
  String category;
  String description;
  double price;
  int stock;
  IconData icon;
  Color color;
  String? imageUrl;

  SellerProduct(
    this.name,
    this.price,
    this.stock,
    this.icon,
    this.color, {
    this.category = 'Phones',
    this.description = '',
    this.id,
    this.imageUrl,
  });
}

class SellerOrder {
  final String id;
  final String details;
  final String customer;
  final String city;
  final String time;
  final double total;
  String status;
  final bool canUpdate;

  SellerOrder(
    this.id,
    this.details,
    this.total,
    this.status,
    this.time, {
    this.customer = 'Customer',
    this.city = '',
    this.canUpdate = true,
  });

  static String displayStatus(String raw) {
    switch (raw.trim().toLowerCase()) {
      case 'pending':
        return 'New';

      case 'processing':
      case 'packed':
        return 'To ship';

      case 'shipped':
      case 'delivered':
      case 'completed':
        return 'Shipped';

      case 'cancelled':
        return 'Cancelled';

      default:
        return raw;
    }
  }

  factory SellerOrder.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final items = rawItems is List ? rawItems : <dynamic>[];

    final descriptions = items
        .map((item) {
          if (item is! Map) return 'Product';

          final name = item['product_name']?.toString() ?? 'Product';
          final quantity = item['quantity']?.toString() ?? '1';

          return '$name × $quantity';
        })
        .join(', ');

    final address = json['shipping_address']?.toString() ?? '';

    final createdAt =
        DateTime.tryParse(json['created_at']?.toString() ?? '');

    final time = createdAt == null
        ? ''
        : '${createdAt.day}/${createdAt.month}/${createdAt.year}';

    return SellerOrder(
      json['id'].toString(),
      descriptions.isEmpty ? 'No product details' : descriptions,
      double.tryParse(json['total'].toString()) ?? 0,
      displayStatus(json['status']?.toString() ?? 'pending'),
      time,
      customer: json['customer']?.toString() ?? 'Customer',
      city: address,
      canUpdate: json['can_update'] == true,
    );
  }
}

class SellerDailySale {
  final String day;
  final String date;
  final double sales;

  const SellerDailySale({
    required this.day,
    required this.date,
    required this.sales,
  });

  factory SellerDailySale.fromJson(Map<String, dynamic> json) {
    return SellerDailySale(
      day: json['day']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      sales: double.tryParse(json['sales'].toString()) ?? 0,
    );
  }
}

class SellerStore {
  String name = 'My Store';
  bool open = true;

  final List<SellerProduct> products = [];
  final List<SellerOrder> orders = [];
  final List<SellerDailySale> dailySales = [];

  double todaySales = 0;
  double totalSales = 0;
  double balance = 0;

  bool dashboardLoaded = false;

  int get totalProducts => products.length;

  int get lowStockProducts =>
      products.where((product) => product.stock <= 3).length;

  int get newOrders =>
      orders.where((order) => order.status == 'New').length;

  int get toShipOrders =>
      orders.where((order) => order.status == 'To ship').length;

  int get shippedOrders =>
      orders.where((order) => order.status == 'Shipped').length;

  void updateDashboard(Map<String, dynamic> json) {
    name = json['seller_name']?.toString() ?? name;

    todaySales =
        double.tryParse(json['today_sales'].toString()) ?? 0;

    totalSales =
        double.tryParse(json['total_sales'].toString()) ?? 0;

    dailySales.clear();

    final rawSales = json['daily_sales'];

    if (rawSales is List) {
      for (final item in rawSales) {
        if (item is Map) {
          dailySales.add(
            SellerDailySale.fromJson(
              Map<String, dynamic>.from(item),
            ),
          );
        }
      }
    }

    dashboardLoaded = true;
  }
}