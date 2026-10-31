import 'package:flutter/material.dart';

import 'package:y3s1_final/customer/screens/customer_orders_screen.dart';
import 'package:y3s1_final/customer/screens/customer_settings_screen.dart';
import 'package:y3s1_final/customer/screens/help_support_screen.dart';
import 'package:y3s1_final/customer/screens/notifications_screen.dart';
import 'package:y3s1_final/customer/screens/payment_method_screen.dart';
import 'package:y3s1_final/customer/screens/shipping_address_screen.dart';
import 'package:y3s1_final/login_form.dart';
import 'package:y3s1_final/screens/appearance_language_screen.dart';
import 'package:y3s1_final/services/app_preferences.dart';
import 'package:y3s1_final/services/commerce_api.dart';

// =====================================================
// CUSTOMER PROFILE SCREEN
// DARK MODE + ENGLISH / KHMER
// =====================================================

class ProfileScreenCustomer extends StatefulWidget {
  const ProfileScreenCustomer({super.key});

  @override
  State<ProfileScreenCustomer> createState() =>
      _ProfileScreenCustomerState();
}

class _ProfileScreenCustomerState extends State<ProfileScreenCustomer> {
  bool _loggingOut = false;

  String _tr(String english, String khmer) {
    return AppPreferences.instance.translate(english, khmer);
  }

  Map<String, dynamic> get _user =>
      CommerceApi.instance.currentUser ?? {};

  String get _name {
    final name = _user['name']?.toString().trim() ?? '';
    return name.isEmpty ? _tr('Customer', 'អតិថិជន') : name;
  }

  String get _email {
    final email = _user['email']?.toString().trim() ?? '';
    return email.isEmpty
        ? _tr('No email available', 'មិនមានអ៊ីមែល')
        : email;
  }

  String get _avatarUrl {
    final value = (_user['avatar_url'] ??
            _user['profile_image'] ??
            _user['avatar'])
        ?.toString()
        .trim();

    if (value == null || value.isEmpty) return '';

    if (value.startsWith('http://') ||
        value.startsWith('https://')) {
      return value;
    }

    return 'http://10.0.2.2:8000/'
        '${value.replaceFirst(RegExp(r'^/+'), '')}';
  }

  @override
  void initState() {
    super.initState();
    _refreshProfile();
  }

  // =====================================================
  // LOAD PROFILE FROM LARAVEL
  // =====================================================

  Future<void> _refreshProfile() async {
    try {
      await CommerceApi.instance.getProfile();

      if (!mounted) return;

      setState(() {});
    } catch (error) {
      debugPrint('Unable to refresh profile: $error');
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    final colors = Theme.of(context).colorScheme;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: isError ? colors.onError : null,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: isError ? colors.error : null,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // =====================================================
  // LOGOUT
  // =====================================================

  Future<void> _logout() async {
    if (_loggingOut) return;

    setState(() {
      _loggingOut = true;
    });

    try {
      await CommerceApi.instance.logout();
    } catch (error) {
      debugPrint('Logout error: $error');
    }

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const LoginForm(),
      ),
      (route) => false,
    );
  }

  // =====================================================
  // PROFILE PICTURE
  // =====================================================

  Widget _defaultAvatar() {
    final colors = Theme.of(context).colorScheme;

    return CircleAvatar(
      radius: 50,
      backgroundColor: colors.primaryContainer,
      child: Text(
        _name.isNotEmpty ? _name[0].toUpperCase() : 'U',
        style: TextStyle(
          color: colors.onPrimaryContainer,
          fontSize: 40,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _profilePicture() {
    final url = _avatarUrl;

    if (url.isEmpty) {
      return _defaultAvatar();
    }

    return ClipOval(
      child: Image.network(
        url,
        height: 100,
        width: 100,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _defaultAvatar(),
      ),
    );
  }

  void _editPicture() {
    _showMessage(
      _tr(
        'Photo upload needs an image upload API.',
        'ការបង្ហោះរូបភាពត្រូវការ API សម្រាប់បង្ហោះរូបភាព។',
      ),
    );
  }

  // =====================================================
  // COMMON DIALOG INPUT DECORATION
  // =====================================================

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    final colors = Theme.of(context).colorScheme;

    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: colors.onSurfaceVariant,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      prefixIcon: Icon(
        icon,
        color: colors.primary,
      ),
      filled: true,
      fillColor: colors.surfaceContainerLow,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: colors.outlineVariant,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: colors.primary,
          width: 2,
        ),
      ),
    );
  }

  // =====================================================
  // EDIT PROFILE
  // =====================================================

  Future<void> _editProfile() async {
    final nameController = TextEditingController(text: _name);
    final emailController = TextEditingController(
      text: _user['email']?.toString() ?? '',
    );
    final phoneController = TextEditingController(
      text: _user['phone']?.toString() ?? '',
    );

    bool saving = false;

    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (dialogContext, setDialogState) {
              final colors =
                  Theme.of(dialogContext).colorScheme;

              return AlertDialog(
                backgroundColor: colors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: Text(
                  _tr('Edit Profile', 'កែប្រែប្រវត្តិរូប'),
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        enabled: !saving,
                        style: TextStyle(
                          color: colors.onSurface,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: _inputDecoration(
                          label: _tr(
                            'Full name',
                            'ឈ្មោះពេញ',
                          ),
                          icon: Icons.person_outline,
                        ),
                      ),

                      const SizedBox(height: 14),

                      TextField(
                        controller: emailController,
                        enabled: !saving,
                        keyboardType:
                            TextInputType.emailAddress,
                        style: TextStyle(
                          color: colors.onSurface,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: _inputDecoration(
                          label: _tr('Email', 'អ៊ីមែល'),
                          icon: Icons.email_outlined,
                        ),
                      ),

                      const SizedBox(height: 14),

                      TextField(
                        controller: phoneController,
                        enabled: !saving,
                        keyboardType: TextInputType.phone,
                        style: TextStyle(
                          color: colors.onSurface,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: _inputDecoration(
                          label: _tr('Phone', 'លេខទូរស័ព្ទ'),
                          icon: Icons.phone_outlined,
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: saving
                        ? null
                        : () => Navigator.pop(dialogContext),
                    child: Text(
                      _tr('Cancel', 'បោះបង់'),
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  FilledButton(
                    onPressed: saving
                        ? null
                        : () async {
                            final name =
                                nameController.text.trim();
                            final email =
                                emailController.text.trim();
                            final phone =
                                phoneController.text.trim();

                            if (name.isEmpty || email.isEmpty) {
                              _showMessage(
                                _tr(
                                  'Name and email are required.',
                                  'ត្រូវបញ្ចូលឈ្មោះ និងអ៊ីមែល។',
                                ),
                                isError: true,
                              );
                              return;
                            }

                            setDialogState(() {
                              saving = true;
                            });

                            try {
                              await CommerceApi.instance
                                  .updateProfile(
                                name: name,
                                email: email,
                                phone: phone,
                              );

                              if (!mounted) return;

                              setState(() {});

                              if (dialogContext.mounted) {
                                Navigator.pop(dialogContext);
                              }

                              _showMessage(
                                _tr(
                                  'Profile updated successfully!',
                                  'បានកែប្រែប្រវត្តិរូបដោយជោគជ័យ!',
                                ),
                              );
                            } catch (error) {
                              if (!mounted) return;

                              _showMessage(
                                '${_tr(
                                  'Unable to update profile',
                                  'មិនអាចកែប្រែប្រវត្តិរូបបាន',
                                )}: $error',
                                isError: true,
                              );

                              if (dialogContext.mounted) {
                                setDialogState(() {
                                  saving = false;
                                });
                              }
                            }
                          },
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: colors.onPrimary,
                    ),
                    child: saving
                        ? SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colors.onPrimary,
                            ),
                          )
                        : Text(
                            _tr('Save', 'រក្សាទុក'),
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {
      await Future<void>.delayed(
        const Duration(milliseconds: 300),
      );

      nameController.dispose();
      emailController.dispose();
      phoneController.dispose();
    }
  }

  // =====================================================
  // CHANGE PASSWORD
  // =====================================================

  Future<void> _changePassword() async {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();

    bool saving = false;

    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (dialogContext, setDialogState) {
              final colors =
                  Theme.of(dialogContext).colorScheme;

              return AlertDialog(
                backgroundColor: colors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: Text(
                  _tr(
                    'Change Password',
                    'ផ្លាស់ប្តូរពាក្យសម្ងាត់',
                  ),
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: currentController,
                        obscureText: true,
                        enabled: !saving,
                        style: TextStyle(
                          color: colors.onSurface,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: _inputDecoration(
                          label: _tr(
                            'Current password',
                            'ពាក្យសម្ងាត់បច្ចុប្បន្ន',
                          ),
                          icon: Icons.lock_outline,
                        ),
                      ),

                      const SizedBox(height: 14),

                      TextField(
                        controller: newController,
                        obscureText: true,
                        enabled: !saving,
                        style: TextStyle(
                          color: colors.onSurface,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: _inputDecoration(
                          label: _tr(
                            'New password',
                            'ពាក្យសម្ងាត់ថ្មី',
                          ),
                          icon: Icons.lock_reset_outlined,
                        ),
                      ),

                      const SizedBox(height: 14),

                      TextField(
                        controller: confirmController,
                        obscureText: true,
                        enabled: !saving,
                        style: TextStyle(
                          color: colors.onSurface,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: _inputDecoration(
                          label: _tr(
                            'Confirm new password',
                            'បញ្ជាក់ពាក្យសម្ងាត់ថ្មី',
                          ),
                          icon: Icons.verified_user_outlined,
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: saving
                        ? null
                        : () => Navigator.pop(dialogContext),
                    child: Text(
                      _tr('Cancel', 'បោះបង់'),
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  FilledButton(
                    onPressed: saving
                        ? null
                        : () async {
                            final current =
                                currentController.text;
                            final next = newController.text;
                            final confirm =
                                confirmController.text;

                            if (next.length < 8) {
                              _showMessage(
                                _tr(
                                  'Password must be at least 8 characters.',
                                  'ពាក្យសម្ងាត់ត្រូវមានយ៉ាងតិច ៨ តួអក្សរ។',
                                ),
                                isError: true,
                              );
                              return;
                            }

                            if (next != confirm) {
                              _showMessage(
                                _tr(
                                  'Passwords do not match.',
                                  'ពាក្យសម្ងាត់មិនត្រូវគ្នា។',
                                ),
                                isError: true,
                              );
                              return;
                            }

                            setDialogState(() {
                              saving = true;
                            });

                            try {
                              await CommerceApi.instance
                                  .changePassword(
                                currentPassword: current,
                                newPassword: next,
                                confirmPassword: confirm,
                              );

                              if (!mounted) return;

                              if (dialogContext.mounted) {
                                Navigator.pop(dialogContext);
                              }

                              _showMessage(
                                _tr(
                                  'Password changed successfully!',
                                  'បានផ្លាស់ប្តូរពាក្យសម្ងាត់ដោយជោគជ័យ!',
                                ),
                              );
                            } catch (error) {
                              if (!mounted) return;

                              _showMessage(
                                '${_tr(
                                  'Unable to change password',
                                  'មិនអាចផ្លាស់ប្តូរពាក្យសម្ងាត់បាន',
                                )}: $error',
                                isError: true,
                              );

                              if (dialogContext.mounted) {
                                setDialogState(() {
                                  saving = false;
                                });
                              }
                            }
                          },
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: colors.onPrimary,
                    ),
                    child: saving
                        ? SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colors.onPrimary,
                            ),
                          )
                        : Text(
                            _tr('Save', 'រក្សាទុក'),
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {
      await Future<void>.delayed(
        const Duration(milliseconds: 300),
      );

      currentController.dispose();
      newController.dispose();
      confirmController.dispose();
    }
  }

  // =====================================================
  // PROFILE MENU NAVIGATION
  // =====================================================

  void _handleMenu(String title) {
    switch (title) {
      case 'Edit Profile':
        _editProfile();
        break;

      case 'My Orders':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const CustomerOrdersScreen(),
          ),
        );
        break;

      case 'Change Password':
        _changePassword();
        break;

      case 'Shipping Address':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const ShippingAddressScreen(),
          ),
        );
        break;

      case 'Payment Method':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const PaymentMethodScreen(),
          ),
        );
        break;

      case 'Notifications':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const NotificationsScreen(),
          ),
        );
        break;

      case 'Settings':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const CustomerSettingsScreen(),
          ),
        );
        break;

      case 'Help & Support':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const HelpSupportScreen(),
          ),
        );
        break;

      case 'Appearance & Language':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const AppearanceLanguageScreen(),
          ),
        );
        break;
    }
  }

  // =====================================================
  // MAIN PROFILE SCREEN
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppPreferences.instance,
      builder: (context, _) {
        final theme = Theme.of(context);
        final colors = theme.colorScheme;

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: theme.scaffoldBackgroundColor,
            foregroundColor: colors.onSurface,
            elevation: 0,
            centerTitle: true,
            title: Text(
              _tr('Profile', 'ប្រវត្តិរូប'),
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          body: RefreshIndicator(
            onRefresh: _refreshProfile,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                _buildHeader(),
                const SizedBox(height: 26),
                _buildMenu(),
                const SizedBox(height: 22),
                _buildLogout(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      },
    );
  }

  // =====================================================
  // PROFILE HEADER
  // =====================================================

  Widget _buildHeader() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 26,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.outlineVariant,
        ),
        boxShadow: dark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              _profilePicture(),

              Positioned(
                right: 0,
                bottom: 0,
                child: Material(
                  color: colors.primary,
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: _editPicture,
                    customBorder: const CircleBorder(),
                    child: Padding(
                      padding: const EdgeInsets.all(9),
                      child: Icon(
                        Icons.edit_rounded,
                        size: 17,
                        color: colors.onPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Text(
            _name,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1.3,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            _email,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _tr('Customer Account', 'គណនីអតិថិជន'),
              style: TextStyle(
                color: colors.onPrimaryContainer,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // PROFILE MENU
  // =====================================================

  Widget _buildMenu() {
    final colors = Theme.of(context).colorScheme;

    final items = [
      (
        icon: Icons.person_outline_rounded,
        key: 'Edit Profile',
        label: _tr('Edit Profile', 'កែប្រែប្រវត្តិរូប'),
      ),
      (
        icon: Icons.shopping_bag_outlined,
        key: 'My Orders',
        label: _tr('My Orders', 'ការបញ្ជាទិញរបស់ខ្ញុំ'),
      ),
      (
        icon: Icons.location_on_outlined,
        key: 'Shipping Address',
        label: _tr(
          'Shipping Address',
          'អាសយដ្ឋានដឹកជញ្ជូន',
        ),
      ),
      (
        icon: Icons.payment_rounded,
        key: 'Payment Method',
        label: _tr('Payment Method', 'វិធីសាស្ត្រទូទាត់'),
      ),
      (
        icon: Icons.notifications_none_rounded,
        key: 'Notifications',
        label: _tr('Notifications', 'ការជូនដំណឹង'),
      ),
      (
        icon: Icons.lock_outline_rounded,
        key: 'Change Password',
        label: _tr(
          'Change Password',
          'ផ្លាស់ប្តូរពាក្យសម្ងាត់',
        ),
      ),
      (
        icon: Icons.settings_outlined,
        key: 'Settings',
        label: _tr('Settings', 'ការកំណត់'),
      ),
      (
        icon: Icons.help_outline_rounded,
        key: 'Help & Support',
        label: _tr('Help & Support', 'ជំនួយ និងការគាំទ្រ'),
      ),
      (
        icon: Icons.dark_mode_outlined,
        key: 'Appearance & Language',
        label: _tr(
          'Appearance & Language',
          'រូបរាង និងភាសា',
        ),
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.outlineVariant,
        ),
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 5,
              ),
              leading: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  items[i].icon,
                  color: colors.onPrimaryContainer,
                  size: 22,
                ),
              ),
              title: Text(
                items[i].label,
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              trailing: Icon(
                Icons.chevron_right_rounded,
                color: colors.onSurfaceVariant,
                size: 24,
              ),
              onTap: () => _handleMenu(items[i].key),
            ),

            if (i != items.length - 1)
              Divider(
                height: 1,
                indent: 74,
                endIndent: 16,
                color: colors.outlineVariant,
              ),
          ],
        ],
      ),
    );
  }

  // =====================================================
  // LOGOUT BUTTON
  // =====================================================

  Widget _buildLogout() {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton.icon(
        onPressed: _loggingOut ? null : _logout,
        icon: _loggingOut
            ? SizedBox(
                height: 19,
                width: 19,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colors.error,
                ),
              )
            : Icon(
                Icons.logout_rounded,
                color: colors.error,
                size: 22,
              ),
        label: Text(
          _loggingOut
              ? _tr('Logging out...', 'កំពុងចាកចេញ...')
              : _tr('Log out', 'ចាកចេញ'),
          style: TextStyle(
            color: colors.error,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: colors.surface,
          foregroundColor: colors.error,
          side: BorderSide(
            color: colors.error,
            width: 1.4,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }
}