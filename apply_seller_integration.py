"""Apply Seller->Laravel API integration to the existing Flutter Git clone.
Usage: py apply_seller_integration.py "D:\\path\\to\\Flutter_Final_App"
"""
from pathlib import Path
import sys, shutil
root = Path(sys.argv[1]) if len(sys.argv)>1 else Path.cwd()
if not (root/'lib/seller/seller_screens.dart').exists():
    raise SystemExit('Run this with the Flutter project directory as the argument.')

def patch(rel, old, new):
    p=root/rel
    s=p.read_text(encoding='utf-8')
    if old not in s:
        if new in s: print('Already updated:',rel);return
        raise SystemExit(f'Could not find expected text in {rel}; stopped to avoid damage.')
    if not (p.with_suffix(p.suffix+'.before_api')).exists():
        shutil.copy2(p,p.with_suffix(p.suffix+'.before_api'))
    p.write_text(s.replace(old,new,1),encoding='utf-8')
    print('Updated:',rel)

service=root/'lib/services/commerce_api.dart'
service.parent.mkdir(parents=True,exist_ok=True)
service.write_text('''import 'dart:convert';
import 'dart:io';

class CommerceApi {
  CommerceApi._();
  static final CommerceApi instance = CommerceApi._();
  static const baseUrl = 'http://10.0.2.2:8000/api';
  String? token;

  Future<dynamic> request(String method, String path, {Map<String, dynamic>? body}) async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 12);
    try {
      final req = await client.openUrl(method, Uri.parse('$baseUrl$path'));
      req.headers.contentType = ContentType.json;
      req.headers.set(HttpHeaders.acceptHeader, 'application/json');
      if (token != null) req.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      if (body != null) req.write(jsonEncode(body));
      final res = await req.close();
      final raw = await res.transform(utf8.decoder).join();
      final data = raw.isEmpty ? null : jsonDecode(raw);
      if (res.statusCode >= 400) {
        String message = 'HTTP ${res.statusCode}';
        if (data is Map && data['message'] != null) message = data['message'].toString();
        throw Exception(message);
      }
      return data;
    } finally {
      client.close(force: true);
    }
  }

  Future<void> login(String email, String password) async {
    final data = await request('POST', '/login', body: {'email': email, 'password': password});
    final role = (data['user'] as Map)['role'];
    if (role != 'seller') throw Exception('Please sign in with a seller account');
    token = data['token'] as String;
  }

  Future<List<Map<String, dynamic>>> sellerProducts() async {
    final result = await request('GET', '/seller/products');
    return (result as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<List<Map<String, dynamic>>> categories() async {
    final result = await request('GET', '/categories');
    return (result as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<Map<String, dynamic>> saveProduct(Map<String, dynamic> data, {int? id}) async {
    final result = await request(id == null ? 'POST' : 'PUT',
        id == null ? '/seller/products' : '/seller/products/$id', body: data);
    return Map<String, dynamic>.from(result as Map);
  }
}
''',encoding='utf-8')
print('Created:',service.relative_to(root))
patch('lib/seller/seller_data.dart', '  String name, category, description;','  int? id;\n  String name, category, description;')
patch('lib/seller/seller_data.dart', "    this.description = '',\n", "    this.description = '',\n    this.id,\n")
p=root/'lib/seller/seller_data.dart'
s=p.read_text(encoding='utf-8')
a=s.index('  final products = <SellerProduct>[')
b=s.index('  final orders = <SellerOrder>[',a)
s=s[:a]+'  final products = <SellerProduct>[];\n'+s[b:]
p.write_text(s,encoding='utf-8')
patch('lib/seller/seller_main.dart', "import 'seller_data.dart';", "import 'seller_data.dart';\nimport '../services/commerce_api.dart';")
patch('lib/seller/seller_main.dart', '  bool adding = false;', '''  bool adding = false;
  bool _signedIn = false;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Existing tokens are deliberately not persisted on disk.
  }

  Future<void> _signIn() async {
    final email = TextEditingController();
    final password = TextEditingController();
    final credentials = await showDialog<List<String>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Seller login'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: email, keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email')),
          TextField(controller: password, obscureText: true,
            decoration: const InputDecoration(labelText: 'Password')),
        ]),
        actions: [FilledButton(onPressed: () => Navigator.pop(context,
          [email.text.trim(), password.text]), child: const Text('Sign in'))],
      ),
    );
    email.dispose();
    password.dispose();
    if (credentials == null || !mounted) return;
    setState(() { _loading = true; _error = null; });
    try {
      await CommerceApi.instance.login(credentials[0], credentials[1]);
      await _loadProducts();
      if (mounted) setState(() => _signedIn = true);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadProducts() async {
    final rows = await CommerceApi.instance.sellerProducts();
    store.products
      ..clear()
      ..addAll(rows.map((row) => SellerProduct(
        row['name'].toString(),
        double.tryParse(row['price'].toString()) ?? 0,
        int.tryParse(row['stock'].toString()) ?? 0,
        Icons.inventory_2_outlined,
        lavender,
        description: row['description']?.toString() ?? '',
        id: int.tryParse(row['id'].toString()),
      )));
    if (mounted) setState(() {});
  }
''')
patch('lib/seller/seller_main.dart', '  Widget build(BuildContext context) {\n    final pages', '''  Widget build(BuildContext context) {
    if (!_signedIn) {
      return Scaffold(body: Center(child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.storefront, size: 64, color: navy),
          const SizedBox(height: 12),
          const Text('SmartEcommerce Seller', style: TextStyle(fontSize: 22)),
          if (_error != null) Padding(padding: const EdgeInsets.all(12),
            child: Text(_error!, style: const TextStyle(color: Colors.red))),
          const SizedBox(height: 16),
          FilledButton(onPressed: _loading ? null : _signIn,
            child: Text(_loading ? 'Signing in...' : 'Sign in as seller')),
        ]),
      )));
    }
    final pages''')
patch('lib/seller/seller_main.dart', '  void navigate(int value) {\n    setState(() {', '''  void navigate(int value) {
    if (value == 1) _loadProducts().catchError((Object e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    });
    setState(() {''')
patch('lib/seller/seller_main.dart', '                                        tab = 1;\n', '                                        tab = 1;\n                                        _loadProducts();\n')
patch('lib/seller/seller_main.dart', '                          setState(() {});\n', '                          _loadProducts();\n')
patch('lib/seller/seller_screens.dart', "import 'seller_data.dart';", "import 'seller_data.dart';\nimport '../services/commerce_api.dart';")
patch('lib/seller/seller_screens.dart', "  String category = 'Phones';", "  String category = 'Phones';\n  bool saving = false;\n  List<Map<String, dynamic>> remoteCategories = [];\n")
patch('lib/seller/seller_screens.dart', "    category = p?.category ?? 'Phones';\n", "    category = p?.category ?? 'Phones';\n    _loadCategories();\n")
patch('lib/seller/seller_screens.dart', '  void save(bool draft) {\n    if (!key.currentState!.validate()) return;', '''  Future<void> _loadCategories() async {
    try {
      final categories = await CommerceApi.instance.categories();
      if (mounted) setState(() => remoteCategories = categories);
    } catch (_) { /* Category can remain unspecified. */ }
  }

  Future<void> save(bool draft) async {
    if (!key.currentState!.validate() || saving) return;
    setState(() => saving = true);
    try {
      final categoryMatches = remoteCategories.where((c) => c['name'] == category);
      final categoryId = categoryMatches.isEmpty ? null : categoryMatches.first['id'];
      final result = await CommerceApi.instance.saveProduct({
        'name': name.text.trim(),
        'description': description.text.trim(),
        'category_id': categoryId,
        'price': double.parse(price.text),
        'stock': int.parse(stock.text),
        'active': !draft,
      }, id: widget.existing?.id);
      final existing = widget.existing;
      if (existing == null) {
        widget.store.products.add(SellerProduct(name.text.trim(),
          double.parse(price.text), int.parse(stock.text),
          Icons.inventory_2_outlined, lavender,
          category: category, description: description.text,
          id: int.tryParse(result['id'].toString())));
      } else {
        existing.name = name.text.trim();
        existing.price = double.parse(price.text);
        existing.stock = int.parse(stock.text);
        existing.category = category;
        existing.description = description.text;
      }
      if (!mounted) return;
      info(context, draft ? 'Draft saved to Laravel' : 'Product saved to Laravel');
      widget.done();
    } catch (e) {
      if (mounted) info(context, 'Could not save product: $e');
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  void _unusedOldSave(bool draft) {
    if (!key.currentState!.validate()) return;''')
# Remove old save method, which was renamed solely to identify its exact bounds.
p=root/'lib/seller/seller_screens.dart';s=p.read_text(encoding='utf-8');a=s.index('  void _unusedOldSave(bool draft) {');b=s.index('  @override\n  Widget build(BuildContext context) => Form(',a);s=s[:a]+s[b:];p.write_text(s,encoding='utf-8')
patch('lib/seller/seller_screens.dart', "                initialValue: category,", "                value: category,") if '                initialValue: category,' in s else None
p=root/'lib/seller/seller_screens.dart';s=p.read_text(encoding='utf-8');s=s.replace("'Sample data only. Photos are placeholders and products are not saved after restarting the app.'", "'Products are saved in Laravel. Photos are still placeholders.'");p.write_text(s,encoding='utf-8')
# Android debug cleartext only; do not enable cleartext for release.
manifest=root/'android/app/src/debug/AndroidManifest.xml'
if manifest.exists():
    s=manifest.read_text(encoding='utf-8')
    if 'usesCleartextTraffic' not in s:
        s=s.replace('<application', '<application android:usesCleartextTraffic="true"',1)
        manifest.write_text(s,encoding='utf-8')
    print('Updated debug Android manifest')
main_manifest=root/'android/app/src/main/AndroidManifest.xml'
if main_manifest.exists():
    s=main_manifest.read_text(encoding='utf-8')
    if 'android.permission.INTERNET' not in s:
        s=s.replace('<application', '<uses-permission android:name="android.permission.INTERNET"/>\n    <application',1)
        main_manifest.write_text(s,encoding='utf-8')
    print('Updated Android INTERNET permission')
print('\nDone. Run dart format lib and flutter analyze. Existing seller orders and customer demo screens are not yet connected.')
