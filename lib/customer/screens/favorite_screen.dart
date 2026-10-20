import 'package:flutter/material.dart';

class FavoriteScreenCustomer extends StatefulWidget {
  const FavoriteScreenCustomer({super.key});

  @override
  State<FavoriteScreenCustomer> createState() => _FavoriteScreenCustomerState();
}

class _FavoriteScreenCustomerState extends State<FavoriteScreenCustomer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFE4F1), // Soft Pink
              Color(0xFFE8E1FF), // Soft Lavender
              Color(0xFFDDF6FF), // Soft Blue
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(child: Text("Favorite Screen")),
      ),
    );
  }
}
