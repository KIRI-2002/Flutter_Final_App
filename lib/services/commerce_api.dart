import 'dart:convert';
import 'dart:io';

import 'package:y3s1_final/services/auth_storage.dart';

class CommerceApi {
  CommerceApi._();

  static final CommerceApi instance = CommerceApi._();

  static const String baseUrl = 'http://10.0.2.2:8000/api';

  String? token;
  String? role;
  Map<String, dynamic>? currentUser;

  // =====================================================
  // SESSION
  // =====================================================

  Future<void> restoreSession() async {
    try {
      final session = await AuthStorage.instance.readSession();

      if (session == null) {
        token = null;
        role = null;
        currentUser = null;
        return;
      }

      final savedToken = session['token']?.toString() ?? '';
      final savedRole = session['role']?.toString().trim().toLowerCase() ?? '';

      final savedUser = session['user'];

      if (savedToken.isEmpty ||
          (savedRole != 'customer' && savedRole != 'seller') ||
          savedUser is! Map) {
        await AuthStorage.instance.clearSession();

        token = null;
        role = null;
        currentUser = null;
        return;
      }

      token = savedToken;
      role = savedRole;
      currentUser = Map<String, dynamic>.from(savedUser);

      try {
        await getProfile();
      } catch (error) {
        final message = error.toString().toLowerCase();

        if (message.contains('401') || message.contains('unauthenticated')) {
          await AuthStorage.instance.clearSession();

          token = null;
          role = null;
          currentUser = null;
        }
      }
    } catch (_) {
      token = null;
      role = null;
      currentUser = null;
    }
  }

  // =====================================================
  // HTTP REQUEST
  // =====================================================

  Future<dynamic> request(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final client =
        HttpClient()..connectionTimeout = const Duration(seconds: 12);

    try {
      final req = await client.openUrl(method, Uri.parse('$baseUrl$path'));

      req.headers.contentType = ContentType.json;

      req.headers.set(HttpHeaders.acceptHeader, 'application/json');

      if (token != null && token!.isNotEmpty) {
        req.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      }

      if (body != null) {
        req.write(jsonEncode(body));
      }

      final res = await req.close();
      final raw = await res.transform(utf8.decoder).join();

      dynamic data;

      try {
        data = raw.isEmpty ? null : jsonDecode(raw);
      } on FormatException {
        throw Exception(
          'Laravel returned an invalid response '
          '(HTTP ${res.statusCode}).',
        );
      }

      if (res.statusCode >= 400) {
        String message = 'HTTP ${res.statusCode}';

        if (data is Map && data['message'] != null) {
          message = data['message'].toString();
        }

        throw Exception(message);
      }

      return data;
    } finally {
      client.close(force: true);
    }
  }

  // =====================================================
  // REGISTER
  // =====================================================

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    await request(
      'POST',
      '/register',
      body: {
        'name': name.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
  }

  // =====================================================
  // LOGIN
  // =====================================================

  Future<void> login(String email, String password) async {
    final result = await request(
      'POST',
      '/login',
      body: {'email': email.trim(), 'password': password},
    );

    final data = Map<String, dynamic>.from(result as Map);

    final user = Map<String, dynamic>.from(data['user'] as Map);

    final newToken = data['token']?.toString() ?? '';

    final String newRole = user['role']?.toString().trim().toLowerCase() ?? '';

    if (newToken.isEmpty) {
      throw Exception('Laravel did not return a login token.');
    }

    if (newRole != 'customer' && newRole != 'seller') {
      throw Exception('Unsupported account role: $newRole');
    }

    await AuthStorage.instance.saveSession(
      token: newToken,
      role: newRole,
      user: user,
    );

    token = newToken;
    role = newRole;
    currentUser = user;
  }

  // =====================================================
  // LOGOUT
  // =====================================================

  Future<void> logout() async {
    try {
      if (token != null && token!.isNotEmpty) {
        await request('POST', '/logout');
      }
    } finally {
      try {
        await AuthStorage.instance.clearSession();
      } finally {
        token = null;
        role = null;
        currentUser = null;
      }
    }
  }

  // =====================================================
  // PROFILE
  // =====================================================

  Future<Map<String, dynamic>> getProfile() async {
    final result = await request('GET', '/profile');

    final data = Map<String, dynamic>.from(result as Map);

    final user = Map<String, dynamic>.from(data['user'] as Map);

    currentUser = user;

    if (token != null && role != null) {
      await AuthStorage.instance.saveSession(
        token: token!,
        role: role!,
        user: user,
      );
    }

    return user;
  }

  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String email,
    required String phone,
  }) async {
    final result = await request(
      'PUT',
      '/profile',
      body: {'name': name.trim(), 'email': email.trim(), 'phone': phone.trim()},
    );

    final data = Map<String, dynamic>.from(result as Map);

    final user = Map<String, dynamic>.from(data['user'] as Map);

    currentUser = user;

    if (token != null && role != null) {
      await AuthStorage.instance.saveSession(
        token: token!,
        role: role!,
        user: user,
      );
    }

    return user;
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    await request(
      'PUT',
      '/profile/password',
      body: {
        'current_password': currentPassword,
        'password': newPassword,
        'password_confirmation': confirmPassword,
      },
    );
  }

  // =====================================================
  // CUSTOMER PRODUCTS
  // =====================================================

  Future<List<Map<String, dynamic>>> products() async {
    final result = await request('GET', '/products');

    return (result as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  Future<List<Map<String, dynamic>>> categories() async {
    final result = await request('GET', '/categories');

    return (result as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  // =====================================================
  // CUSTOMER ORDERS
  // =====================================================

  Future<List<Map<String, dynamic>>> myOrders() async {
    final result = await request('GET', '/orders');

    return (result as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  Future<Map<String, dynamic>> checkout(
    String shippingAddress,
    List<Map<String, dynamic>> items, {
    String paymentMethod = 'cod',
  }) async {
    final result = await request(
      'POST',
      '/checkout',
      body: {
        'shipping_address': shippingAddress,
        'payment_method': paymentMethod,
        'items': items,
      },
    );

    return Map<String, dynamic>.from(result as Map);
  }

  Future<Map<String, dynamic>> confirmOrderReceived(int orderId) async {
    final result = await request('PATCH', '/orders/$orderId/confirm-received');

    return Map<String, dynamic>.from(result as Map);
  }

  // =====================================================
  // SELLER PRODUCTS
  // =====================================================

  Future<List<Map<String, dynamic>>> sellerProducts() async {
    final result = await request('GET', '/seller/products');

    return (result as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  Future<Map<String, dynamic>> saveProduct(
    Map<String, dynamic> data, {
    int? id,
  }) async {
    final result = await request(
      id == null ? 'POST' : 'PUT',
      id == null ? '/seller/products' : '/seller/products/$id',
      body: data,
    );

    return Map<String, dynamic>.from(result as Map);
  }

  /// Uploads a product image and product fields using multipart/form-data.
  /// Laravel must validate and store the `image` field on this endpoint.
  Future<Map<String, dynamic>> saveProductWithImage(
    Map<String, dynamic> data, {
    required String imagePath,
    int? id,
  }) async {
    final file = File(imagePath);
    if (!await file.exists()) {
      throw Exception('Selected image does not exist.');
    }

    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 20);
    try {
      final uri = Uri.parse(
        '$baseUrl/seller/products${id == null ? '' : '/$id'}',
      );
      final req = await client.postUrl(uri);
      final boundary =
          'flutter-product-${DateTime.now().microsecondsSinceEpoch}';
      req.headers.set(
        HttpHeaders.contentTypeHeader,
        'multipart/form-data; boundary=$boundary',
      );
      req.headers.set(HttpHeaders.acceptHeader, 'application/json');
      if (token != null && token!.isNotEmpty) {
        req.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      }

      void writeField(String name, String value) {
        req.write('--$boundary\r\n');
        req.write('Content-Disposition: form-data; name="$name"\r\n\r\n');
        req.write(value);
        req.write('\r\n');
      }

      if (id != null) writeField('_method', 'PUT');
      for (final entry in data.entries) {
        if (entry.value != null) {
          writeField(entry.key, entry.value.toString());
        }
      }

      final filename = file.uri.pathSegments.last.replaceAll('"', '');
      final extension = filename.split('.').last.toLowerCase();
      final contentType = switch (extension) {
        'png' => 'image/png',
        'webp' => 'image/webp',
        'gif' => 'image/gif',
        _ => 'image/jpeg',
      };
      req.write('--$boundary\r\n');
      req.write('Content-Disposition: form-data; '
          'name="image"; filename="$filename"\r\n');
      req.write('Content-Type: $contentType\r\n\r\n');
      await req.addStream(file.openRead());
      req.write('\r\n--$boundary--\r\n');

      final res = await req.close();
      final raw = await res.transform(utf8.decoder).join();
      dynamic result;
      try {
        result = jsonDecode(raw);
      } on FormatException {
        throw Exception('Laravel returned an invalid response (HTTP ${res.statusCode}).');
      }
      if (res.statusCode >= 400) {
        final message = result is Map ? result['message']?.toString() : null;
        throw Exception(message ?? 'Image upload failed (HTTP ${res.statusCode}).');
      }
      if (result is! Map) {
        throw Exception('Invalid product response from Laravel.');
      }
      return Map<String, dynamic>.from(result);
    } finally {
      client.close(force: true);
    }
  }

  Future<void> deleteSellerProduct(int productId) async {
    await request('DELETE', '/seller/products/$productId');
  }

  // =====================================================
  // SELLER DASHBOARD
  // =====================================================

  Future<Map<String, dynamic>> sellerDashboard() async {
    final result = await request('GET', '/seller/dashboard');

    return Map<String, dynamic>.from(result as Map);
  }

  // =====================================================
  // SELLER ORDERS
  // =====================================================

  Future<List<Map<String, dynamic>>> sellerOrders() async {
    final result = await request('GET', '/seller/orders');

    return (result as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  Future<Map<String, dynamic>> updateSellerOrder(
    int orderId,
    String status,
  ) async {
    final result = await request(
      'PATCH',
      '/seller/orders/$orderId',
      body: {'status': status},
    );

    return Map<String, dynamic>.from(result as Map);
  }

  // =====================================================
  // CHATBOT
  // =====================================================

  Future<String> sendChatMessage(String message) async {
    final result = await request(
      'POST',
      '/chat',
      body: {'message': message.trim()},
    );

    if (result is! Map) {
      throw Exception('Invalid chatbot response.');
    }

    final reply = result['reply']?.toString();

    if (reply == null || reply.isEmpty) {
      throw Exception('The chatbot returned an empty response.');
    }

    return reply;
  }

  Future<String> chatbotMyOrders() async {
    final result = await request('GET', '/chat/my-orders');

    if (result is! Map) {
      throw Exception('Invalid order response.');
    }

    return result['reply']?.toString() ?? 'Unable to retrieve your orders.';
  }

  Future<String> chatbotOrderDetails(int orderId) async {
    final result = await request('GET', '/chat/orders/$orderId');

    if (result is! Map) {
      throw Exception('Invalid order response.');
    }

    return result['reply']?.toString() ?? 'Unable to retrieve order details.';
  }

  Future<String> sendConversationMessage(String message) async {
    final result = await request(
      'POST',
      '/chat/conversation',
      body: {'message': message.trim()},
    );

    if (result is! Map) {
      throw Exception('Invalid chatbot response.');
    }

    final reply = result['reply']?.toString();

    if (reply == null || reply.isEmpty) {
      throw Exception('The chatbot returned an empty response.');
    }

    return reply;
  }

  Future<List<Map<String, dynamic>>> chatHistory() async {
    final result = await request('GET', '/chat/history');

    if (result is! Map || result['messages'] is! List) {
      throw Exception('Invalid chat history response.');
    }

    return (result['messages'] as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  Future<void> clearChatHistory() async {
    await request('DELETE', '/chat/history');
  }

  // =====================================================
  // WAREHOUSE ORDERS
  // =====================================================

  Future<List<Map<String, dynamic>>> warehouseOrders() async {
    final result = await request('GET', '/warehouse/orders');

    return (result as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  Future<Map<String, dynamic>> updateWarehouseOrder(
    int orderId,
    String status,
  ) async {
    final result = await request(
      'PATCH',
      '/warehouse/orders/$orderId',
      body: {'status': status},
    );

    return Map<String, dynamic>.from(result as Map);
  }

  Future<Map<String, dynamic>> updateWarehouseStock(
    int productId,
    int stock,
  ) async {
    final result = await request(
      'PATCH',
      '/warehouse/products/$productId/stock',
      body: {'stock': stock},
    );

    return Map<String, dynamic>.from(result as Map);
  }
  // =====================================================
  // SELLER STORE SETTINGS
  // =====================================================

  Future<Map<String, dynamic>> sellerStoreSettings() async {
    final result = await request('GET', '/seller/store-settings');

    final data = Map<String, dynamic>.from(result as Map);

    return Map<String, dynamic>.from(data['store'] as Map);
  }

  Future<Map<String, dynamic>> updateSellerStoreSettings({
    required String storeName,
    required String description,
    required bool isOpen,
  }) async {
    final result = await request(
      'PUT',
      '/seller/store-settings',
      body: {
        'store_name': storeName.trim(),
        'description': description.trim(),
        'is_open': isOpen,
      },
    );

    final data = Map<String, dynamic>.from(result as Map);

    return Map<String, dynamic>.from(data['store'] as Map);
  }
  // =====================================================
  // CUSTOMER SHIPPING ADDRESSES
  // =====================================================

  Future<List<Map<String, dynamic>>> customerAddresses() async {
    final result = await request('GET', '/addresses');

    return (result as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  Future<Map<String, dynamic>> saveCustomerAddress({
    int? id,
    required String fullName,
    required String phone,
    required String city,
    required String address,
    required bool isDefault,
  }) async {
    final result = await request(
      id == null ? 'POST' : 'PUT',
      id == null ? '/addresses' : '/addresses/$id',
      body: {
        'full_name': fullName.trim(),
        'phone': phone.trim(),
        'city': city.trim(),
        'address': address.trim(),
        'is_default': isDefault,
      },
    );

    return Map<String, dynamic>.from(result as Map);
  }

  Future<void> setDefaultCustomerAddress(int id) async {
    await request('PATCH', '/addresses/$id/default');
  }

  Future<void> deleteCustomerAddress(int id) async {
    await request('DELETE', '/addresses/$id');
  }
  // =====================================================
  // CUSTOMER SETTINGS
  // =====================================================

  Future<Map<String, dynamic>> customerSettings() async {
    final result = await request('GET', '/customer/settings');

    return Map<String, dynamic>.from(result as Map);
  }

  Future<Map<String, dynamic>> updateCustomerSettings({
    required bool orderNotifications,
    required bool promotionalNotifications,
  }) async {
    final result = await request(
      'PUT',
      '/customer/settings',
      body: {
        'order_notifications': orderNotifications,
        'promotional_notifications': promotionalNotifications,
      },
    );

    return Map<String, dynamic>.from(result as Map);
  }
  // CUSTOMER SUPPORT

  Future<List<Map<String, dynamic>>> customerSupportTickets() async {
    final result = await request('GET', '/customer/support');

    return (result as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  Future<Map<String, dynamic>> createSupportTicket({
    required String subject,
    required String message,
  }) async {
    final result = await request(
      'POST',
      '/customer/support',
      body: {'subject': subject, 'message': message},
    );

    return Map<String, dynamic>.from(result as Map);
  }
    // =====================================================
  // SELLER PAYOUT ACCOUNT
  // =====================================================

  Future<Map<String, dynamic>?> sellerPayoutAccount() async {
    final result = await request('GET', '/seller/payout-account');

    final account = (result as Map)['account'];

    return account == null
        ? null
        : Map<String, dynamic>.from(account as Map);
  }

  Future<void> saveSellerPayoutAccount({
    required String accountHolder,
    required String bankName,
    required String accountNumber,
  }) async {
    await request(
      'PUT',
      '/seller/payout-account',
      body: {
        'account_holder': accountHolder,
        'bank_name': bankName,
        'account_number': accountNumber,
      },
    );
  }

  // =====================================================
  // SELLER SHIPPING SETTINGS
  // =====================================================

  Future<Map<String, dynamic>?> sellerShippingSettings() async {
    final result = await request('GET', '/seller/shipping-settings');

    final settings = (result as Map)['settings'];

    return settings == null
        ? null
        : Map<String, dynamic>.from(settings as Map);
  }

  Future<void> saveSellerShippingSettings({
    required String pickupAddress,
    required String courierName,
    required double shippingFee,
    required int estimatedDays,
  }) async {
    await request(
      'PUT',
      '/seller/shipping-settings',
      body: {
        'pickup_address': pickupAddress,
        'courier_name': courierName,
        'shipping_fee': shippingFee,
        'estimated_days': estimatedDays,
      },
    );
  }

  // =====================================================
  // SELLER CUSTOMER REVIEWS
  // =====================================================

  Future<List<Map<String, dynamic>>> sellerReviews() async {
    final result = await request('GET', '/seller/reviews');

    final reviews = (result as Map)['reviews'] as List;

    return reviews
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  Future<void> replyToSellerReview(
    int reviewId,
    String reply,
  ) async {
    await request(
      'PUT',
      '/seller/reviews/$reviewId/reply',
      body: {
        'seller_reply': reply,
      },
    );
  }
    // =====================================================
  // SELLER HELP AND SUPPORT
  // =====================================================

  Future<List<Map<String, dynamic>>> sellerSupportTickets() async {
    final result = await request('GET', '/seller/support');

    return (result as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  Future<Map<String, dynamic>> createSellerSupportTicket({
    required String subject,
    required String message,
  }) async {
    final result = await request(
      'POST',
      '/seller/support',
      body: {
        'subject': subject.trim(),
        'message': message.trim(),
      },
    );

    return Map<String, dynamic>.from(result as Map);
  }
}
