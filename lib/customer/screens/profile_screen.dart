import 'package:flutter/material.dart';

class ProfileScreenCustomer extends StatefulWidget {
  const ProfileScreenCustomer({super.key});

  @override
  State<ProfileScreenCustomer> createState() => _ProfileScreenCustomerState();
}

class _ProfileScreenCustomerState extends State<ProfileScreenCustomer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Text("Profile Screen"),
      ),
    );
  }
}