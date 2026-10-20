import 'package:flutter/material.dart';
import 'package:y3s1_final/customer/main_customer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Final',
      home: MainCustomer(),
    );
  }
}
