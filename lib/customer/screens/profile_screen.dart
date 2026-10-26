import 'package:flutter/material.dart';
import 'package:y3s1_final/login_form.dart';

class ProfileScreenCustomer extends StatefulWidget {
  const ProfileScreenCustomer({super.key});

  @override
  State<ProfileScreenCustomer> createState() => _ProfileScreenCustomerState();
}

class _ProfileScreenCustomerState extends State<ProfileScreenCustomer> {
  static const _bg = Color.fromARGB(248, 255, 247, 247);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        centerTitle: true,
        title: Text('Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(),
          SizedBox(height: 16),
          //_buildStats(),
          SizedBox(height: 16),
          _buildMenu(),
          SizedBox(height: 16),
          _buildLogout(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.network(
                  height: 100,
                  width: 100,
                  'https://i.pinimg.com/736x/a8/e9/31/a8e9318594a91b1228e14e4574e18879.jpg',
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: CircleAvatar(
                  radius: 15,
                  backgroundColor: const Color.fromARGB(255, 240, 128, 128),
                  child: Icon(Icons.edit, size: 15, color: Colors.white),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            "Ta",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text("ta@example.com", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  // Widget _buildStats() {
  //   return ValueListenableBuilder<Set<int>>(
  //     valueListenable: favoriteCodes,
  //     builder: (context, favorites, _) {
  //       return Row(
  //         children: [
  //           _statCard(Icons.favorite, "${favorites.length}", "Favorites"),
  //           const SizedBox(width: 12),
  //           _statCard(Icons.shopping_bag, "0", "Orders"),
  //         ],
  //       );
  //     },
  //   );
  // }

  Widget _statCard(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.deepPurple),
            SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(label, style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildMenu() {
    final items = [
      (Icons.person_outline, "Edit Profile"),
      (Icons.shopping_bag_outlined, "My Orders"),
      (Icons.location_on_outlined, "Shipping Address"),
      (Icons.payment, "Payment Method"),
      (Icons.notifications_none, "Notifications"),
      (Icons.settings_outlined, "Settings"),
      (Icons.help_outline, "Help & Support"),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            ListTile(
              leading: Icon(items[i].$1, color: Colors.deepPurple),
              title: Text(items[i].$2),
              trailing: Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {},
            ),
            if (i != items.length - 1) Divider(height: 1, indent: 56),
          ],
        ],
      ),
    );
  }

  Widget _buildLogout() {
    return SizedBox(
      height: 48,
      child: OutlinedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => LoginForm()),
          );
        },
        icon: Icon(Icons.logout, color: Colors.red),
        label: Text("Log out", style: TextStyle(color: Colors.red)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.red),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
