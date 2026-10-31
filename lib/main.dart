import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:y3s1_final/bloc/product_bloc.dart';
import 'package:y3s1_final/customer/main_customer.dart';
import 'package:y3s1_final/seller/seller_main.dart';
import 'package:y3s1_final/login_form.dart';

import 'package:y3s1_final/services/commerce_api.dart';
import 'package:y3s1_final/services/app_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load saved preferences first.
  await AppPreferences.instance.load();

  // Restore login session.
  await CommerceApi.instance.restoreSession();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // =====================================================
  // LIGHT THEME
  // =====================================================

  ThemeData get lightTheme {
    final colors = ColorScheme.fromSeed(
      seedColor: const Color(0xFF6C4DD3),
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colors,
      scaffoldBackgroundColor: const Color(0xFFF8F7FC),

      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFFF8F7FC),
        foregroundColor: colors.onSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: colors.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1,
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 14,
        ),
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),

      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // =====================================================
  // DARK THEME
  // =====================================================

  ThemeData get darkTheme {
    final colors = ColorScheme.fromSeed(
      seedColor: const Color(0xFFAAA4FF),
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colors,
      scaffoldBackgroundColor: const Color(0xFF12121C),

      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF12121C),
        foregroundColor: colors.onSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: colors.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      cardTheme: CardThemeData(
        color: const Color(0xFF222231),
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF252532),
        hintStyle: const TextStyle(
          color: Colors.white70,
          fontSize: 14,
        ),
        labelStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),

      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // =====================================================
  // BUILD APPLICATION
  // =====================================================

  @override
  Widget build(BuildContext context) {
    final api = CommerceApi.instance;

    Widget startScreen = const LoginForm();

    if (api.token != null && api.token!.isNotEmpty) {
      final role = api.role?.trim().toLowerCase();

      if (role == 'seller') {
        startScreen = const SellerMain();
      } else if (role == 'customer') {
        startScreen = const MainCustomer();
      }
    }

    return BlocProvider(
      create: (_) => ProductBloc(),

      child: ListenableBuilder(
        listenable: AppPreferences.instance,

        builder: (context, _) {
          final preferences = AppPreferences.instance;

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'SmartCommerce',

            // LANGUAGE
            locale: preferences.locale,

            // THEME
            themeMode: preferences.themeMode,
            theme: lightTheme,
            darkTheme: darkTheme,

            // INITIAL SCREEN
            home: startScreen,

            routes: {
              '/seller': (_) => const SellerMain(),
              '/customer': (_) => const MainCustomer(),
            },
          );
        },
      ),
    );
  }
}