import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:y3s1_final/bloc/product_bloc.dart';
import 'package:y3s1_final/customer/main_customer.dart';
import 'package:y3s1_final/seller/seller_main.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProductBloc(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Final',
        home: const SellerMain(),
        routes: {
          '/seller': (_) => const SellerMain(),
          '/customer': (_) => const MainCustomer(),
        },
      ),
    );
  }
}
