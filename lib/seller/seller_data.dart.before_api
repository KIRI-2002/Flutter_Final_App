import 'package:flutter/material.dart';

class SellerProduct {
  String name, category, description;
  double price;
  int stock;
  IconData icon;
  Color color;
  SellerProduct(
    this.name,
    this.price,
    this.stock,
    this.icon,
    this.color, {
    this.category = 'Phones',
    this.description = '',
  });
}

class SellerOrder {
  final String id, details, customer, city, time;
  final double total;
  String status;
  SellerOrder(
    this.id,
    this.details,
    this.total,
    this.status,
    this.time, {
    this.customer = 'Customer name',
    this.city = 'City',
  });
}

class SellerStore {
  String name = 'Store name';
  bool open = true;
  double balance = 2480;
  final products = <SellerProduct>[
    SellerProduct(
      'Aero Phone 12 Pro',
      899,
      14,
      Icons.smartphone_outlined,
      const Color(0xFFDDD7FF),
    ),
    SellerProduct(
      'Pulse Buds',
      89,
      3,
      Icons.headphones_outlined,
      const Color(0xFFD6F0EA),
      category: 'Audio',
    ),
    SellerProduct(
      'Atlas Mini Laptop',
      649,
      8,
      Icons.laptop_outlined,
      const Color(0xFFFFE9B7),
      category: 'Computers',
    ),
    SellerProduct(
      'Slate 11 Tablet',
      399,
      0,
      Icons.tablet_android_outlined,
      const Color(0xFFFFE2D7),
    ),
    SellerProduct(
      'Beam Speaker',
      119,
      21,
      Icons.speaker_outlined,
      const Color(0xFFDDD7FF),
      category: 'Audio',
    ),
  ];
  final orders = <SellerOrder>[
    SellerOrder(
      '1042',
      'Pulse Buds ×1, Beam Speaker ×1',
      208,
      'New',
      '10 min ago',
    ),
    SellerOrder('1043', 'Aero Phone 12 Pro ×1', 899, 'New', '25 min ago'),
    SellerOrder('1041', 'Atlas Mini Laptop ×1', 899, 'To ship', '1 hour ago'),
    SellerOrder('1039', 'Beam Speaker ×1', 119, 'To ship', 'Yesterday'),
    SellerOrder('1040', 'Slate 11 Tablet ×1', 214.50, 'Shipped', 'Yesterday'),
  ];
}
