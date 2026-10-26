import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:y3s1_final/chatbot/screen/chat_screen.dart';
import 'package:y3s1_final/customer/screens/cart_screen.dart';
//import 'package:y3s1_final/customer/screens/checkOut_screen.dart';
import 'package:y3s1_final/customer/screens/favorite_screen.dart';
import 'package:y3s1_final/customer/screens/home_screen.dart';
import 'package:y3s1_final/customer/screens/profile_screen.dart';

class MainCustomer extends StatefulWidget {
  const MainCustomer({super.key});

  @override
  State<MainCustomer> createState() => _MainCustomerState();
}

class _MainCustomerState extends State<MainCustomer> {
  final List<Widget> page = [
    const HomeScreenCustomer(),
    const FavoriteScreenCustomer(),
    const CartScreen(),
    const ProfileScreenCustomer(),
  ];
  int currentPage = 0;

  static const _items = [
    _NavItem(Icons.home_outlined, "Home"),
    _NavItem(Icons.favorite_border, "Wishlist"),
    _NavItem(Icons.shopping_cart_outlined, "Cart"),
    _NavItem(Icons.person_outline, "Profile"),
  ];

  static const _navColor = Color(0xFF1E2A5A);
  static const _activeBg = Color(0xFFDDD6FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: page[currentPage],
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 2),
          child: Row(
            children: [
              Expanded(
                child: _Glass(
                  height: 64,
                  radius: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(_items.length, _buildItem),
                  ),
                ),
              ),
               SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen()));
                },
                child: _Glass(
                  height: 64,
                  width: 64,
                  radius: 32,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Image.asset('assets/images/chatbot.png'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem(int i) {
    final selected = currentPage == i;
    final item = _items[i];
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => currentPage = i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(
          horizontal: selected ? 16 : 8,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: selected ? _activeBg : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(item.icon, size: 28, color: _navColor),
            AnimatedSize(
              duration:  Duration(milliseconds: 250),
              child:
                  selected
                      ? Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          item.label,
                          style:  TextStyle(
                            color: _navColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                      :  SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _Glass extends StatelessWidget {
  final Widget child;
  final double height;
  final double? width;
  final double radius;
  const _Glass({
    required this.child,
    required this.height,
    required this.radius,
    this.width,
  });
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.45),
                Colors.white.withOpacity(0.15),
              ],
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.7),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}
