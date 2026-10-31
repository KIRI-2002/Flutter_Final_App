import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:y3s1_final/bloc/product_bloc.dart';
import 'package:y3s1_final/bloc/product_event.dart';

import 'package:y3s1_final/chatbot/screen/chat_screen.dart';

import 'package:y3s1_final/customer/screens/cart_screen.dart';
import 'package:y3s1_final/customer/screens/favorite_screen.dart';
import 'package:y3s1_final/customer/screens/home_screen.dart';
import 'package:y3s1_final/customer/screens/profile_screen.dart';

import 'package:y3s1_final/services/app_preferences.dart';

class MainCustomer extends StatefulWidget {
  const MainCustomer({super.key});

  @override
  State<MainCustomer> createState() => _MainCustomerState();
}

class _MainCustomerState extends State<MainCustomer> {
  int currentPage = 0;

  final List<Widget> pages = const [
    HomeScreenCustomer(),
    FavoriteScreenCustomer(),
    CartScreen(),
    ProfileScreenCustomer(),
  ];

  static const _items = [
    _NavItem(
      Icons.home_outlined,
      'Home',
      'ទំព័រដើម',
    ),
    _NavItem(
      Icons.favorite_border,
      'Wishlist',
      'ចំណូលចិត្ត',
    ),
    _NavItem(
      Icons.shopping_cart_outlined,
      'Cart',
      'កន្ត្រក',
    ),
    _NavItem(
      Icons.person_outline,
      'Profile',
      'គណនី',
    ),
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<ProductBloc>().add(
        LoadProductsEvent(),
      );
    });
  }

  void _changePage(int index) {
    if (index < 0 || index >= pages.length) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    setState(() {
      currentPage = index;
    });

    if (index == 0) {
      context.read<ProductBloc>().add(
        LoadProductsEvent(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppPreferences.instance,
      builder: (context, _) {
        final theme = Theme.of(context);

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          extendBody: true,

          // Keep all Customer screens alive.
          body: IndexedStack(
            index: currentPage,
            children: pages,
          ),

          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                0,
                16,
                2,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _Glass(
                      height: 64,
                      radius: 40,
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceAround,
                        children: List.generate(
                          _items.length,
                          _buildItem,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Chatbot button
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(),
                        ),
                      );
                    },
                    child: _Glass(
                      height: 64,
                      width: 64,
                      radius: 32,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Image.asset(
                          'assets/images/chatbot.png',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildItem(int index) {
    final selected = currentPage == index;
    final item = _items[index];

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;

    final settings = AppPreferences.instance;

    final String label = settings.translate(
      item.englishLabel,
      item.khmerLabel,
    );

    final Color navColor = dark
        ? colorScheme.onSurface
        : const Color(0xFF1E2A5A);

    final Color activeBackground = dark
        ? colorScheme.primaryContainer
        : const Color(0xFFDDD6FF);

    final Color activeTextColor = dark
        ? colorScheme.onPrimaryContainer
        : navColor;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _changePage(index),

      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 250,
        ),
        curve: Curves.easeOut,

        padding: EdgeInsets.symmetric(
          horizontal: selected ? 12 : 8,
          vertical: 10,
        ),

        decoration: BoxDecoration(
          color: selected
              ? activeBackground
              : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),

        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              size: 25,
              color: selected
                  ? activeTextColor
                  : navColor,
            ),

            AnimatedSize(
              duration: const Duration(
                milliseconds: 250,
              ),

              child: selected
                  ? Padding(
                      padding: const EdgeInsets.only(
                        left: 6,
                      ),

                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,

                        style: TextStyle(
                          color: activeTextColor,
                          fontSize: settings.isKhmer
                              ? 12
                              : 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// GLASS NAVIGATION BACKGROUND
// SUPPORTS LIGHT MODE AND DARK MODE
// =====================================================

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
    final theme = Theme.of(context);

    final dark = theme.brightness == Brightness.dark;

    final surface = theme.colorScheme.surface;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),

      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 18,
          sigmaY: 18,
        ),

        child: Container(
          height: height,
          width: width,

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),

            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,

              colors: dark
                  ? [
                      surface.withValues(alpha: 0.95),
                      surface.withValues(alpha: 0.85),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.75),
                      Colors.white.withValues(alpha: 0.45),
                    ],
            ),

            border: Border.all(
              color: dark
                  ? Colors.white.withValues(alpha: 0.12)
                  : Colors.white.withValues(alpha: 0.7),
              width: 1.2,
            ),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: dark ? 0.30 : 0.08,
                ),
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

// =====================================================
// NAVIGATION ITEM MODEL
// =====================================================

class _NavItem {
  final IconData icon;
  final String englishLabel;
  final String khmerLabel;

  const _NavItem(
    this.icon,
    this.englishLabel,
    this.khmerLabel,
  );
}