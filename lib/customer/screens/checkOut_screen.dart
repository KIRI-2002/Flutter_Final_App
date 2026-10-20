import 'package:flutter/material.dart';

class CheckoutScreenCustomer extends StatefulWidget {
  const CheckoutScreenCustomer({super.key});

  @override
  State<CheckoutScreenCustomer> createState() => _CheckoutScreenCustomerState();
}

class _CheckoutScreenCustomerState extends State<CheckoutScreenCustomer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Text("Check Out Screen"),
      ),
    );
  }
}