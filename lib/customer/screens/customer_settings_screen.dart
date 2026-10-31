import 'package:flutter/material.dart';

import 'package:y3s1_final/services/app_preferences.dart';
import 'package:y3s1_final/services/commerce_api.dart';

// =====================================================
// CUSTOMER SETTINGS SCREEN
// DARK MODE + ENGLISH / KHMER + LARAVEL
// =====================================================

class CustomerSettingsScreen extends StatefulWidget {
  const CustomerSettingsScreen({super.key});

  @override
  State<CustomerSettingsScreen> createState() =>
      _CustomerSettingsScreenState();
}

class _CustomerSettingsScreenState extends State<CustomerSettingsScreen> {
  bool _orderNotifications = true;
  bool _promotionalNotifications = false;

  bool _loading = true;
  bool _saving = false;

  String? _error;

  // =====================================================
  // TRANSLATION
  // =====================================================

  String _tr(String english, String khmer) {
    return AppPreferences.instance.translate(english, khmer);
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // =====================================================
  // LOAD SETTINGS FROM LARAVEL
  // =====================================================

  Future<void> _loadSettings() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final settings = await CommerceApi.instance.customerSettings();

      if (!mounted) return;

      setState(() {
        _orderNotifications =
            settings['order_notifications'] == true ||
            settings['order_notifications'] == 1;

        _promotionalNotifications =
            settings['promotional_notifications'] == true ||
            settings['promotional_notifications'] == 1;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  // =====================================================
  // SAVE SETTINGS TO LARAVEL
  // =====================================================

  Future<void> _saveSettings() async {
    if (_saving) return;

    setState(() {
      _saving = true;
    });

    try {
      await CommerceApi.instance.updateCustomerSettings(
        orderNotifications: _orderNotifications,
        promotionalNotifications: _promotionalNotifications,
      );

      if (!mounted) return;

      _showMessage(
        _tr(
          'Settings saved successfully!',
          'បានរក្សាទុកការកំណត់ដោយជោគជ័យ!',
        ),
      );
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        '${_tr(
          'Unable to save settings',
          'មិនអាចរក្សាទុកការកំណត់បាន',
        )}: $error',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  // =====================================================
  // SHOW MESSAGE
  // =====================================================

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
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
  // SETTINGS CARD
  // =====================================================

  Widget _settingsCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colors.outlineVariant,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        secondary: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: colors.onPrimaryContainer,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 15,
            fontWeight: FontWeight.w800,
            height: 1.3,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            subtitle,
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ),
        value: value,
        activeTrackColor: colors.primary,
        activeColor: colors.onPrimary,
        inactiveTrackColor: colors.surfaceContainerHighest,
        onChanged: _saving ? null : onChanged,
      ),
    );
  }

  // =====================================================
  // ERROR STATE
  // =====================================================

  Widget _buildErrorState() {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: colors.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: colors.onErrorContainer,
                size: 46,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              _tr(
                'Unable to load settings',
                'មិនអាចផ្ទុកការកំណត់បាន',
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              _error ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontSize: 13,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 22),

            FilledButton.icon(
              onPressed: _loadSettings,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(
                _tr(
                  'Try Again',
                  'ព្យាយាមម្តងទៀត',
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // SETTINGS CONTENT
  // =====================================================

  Widget _buildSettingsContent() {
    final colors = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        18,
        20,
        18,
        30,
      ),
      children: [
        // SECTION HEADING
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                Icons.notifications_active_outlined,
                color: colors.onPrimaryContainer,
                size: 25,
              ),
            ),

            const SizedBox(width: 13),

            Expanded(
              child: Text(
                _tr(
                  'Notification Preferences',
                  'ចំណូលចិត្តការជូនដំណឹង',
                ),
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Text(
          _tr(
            'Manage your notification preferences.',
            'គ្រប់គ្រងចំណូលចិត្តការជូនដំណឹងរបស់អ្នក។',
          ),
          style: TextStyle(
            color: colors.onSurfaceVariant,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
        ),

        const SizedBox(height: 26),

        // ORDER NOTIFICATIONS
        _settingsCard(
          icon: Icons.local_shipping_outlined,
          title: _tr(
            'Order Notifications',
            'ការជូនដំណឹងអំពីការបញ្ជាទិញ',
          ),
          subtitle: _tr(
            'Receive alerts about your order status.',
            'ទទួលការជូនដំណឹងអំពីស្ថានភាពការបញ្ជាទិញរបស់អ្នក។',
          ),
          value: _orderNotifications,
          onChanged: (value) {
            setState(() {
              _orderNotifications = value;
            });
          },
        ),

        // PROMOTIONAL NOTIFICATIONS
        _settingsCard(
          icon: Icons.campaign_outlined,
          title: _tr(
            'Promotional Notifications',
            'ការជូនដំណឹងអំពីការផ្សព្វផ្សាយ',
          ),
          subtitle: _tr(
            'Receive updates about offers and promotions.',
            'ទទួលព័ត៌មានអំពីការផ្តល់ជូន និងការបញ្ចុះតម្លៃ។',
          ),
          value: _promotionalNotifications,
          onChanged: (value) {
            setState(() {
              _promotionalNotifications = value;
            });
          },
        ),

        const SizedBox(height: 24),

        // SAVE SETTINGS BUTTON
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _saving ? null : _saveSettings,
            icon: _saving
                ? SizedBox(
                    width: 19,
                    height: 19,
                    child: CircularProgressIndicator(
                      color: colors.onPrimary,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(
                    Icons.save_outlined,
                    size: 21,
                  ),
            label: Text(
              _saving
                  ? _tr(
                      'Saving...',
                      'កំពុងរក្សាទុក...',
                    )
                  : _tr(
                      'Save Settings',
                      'រក្សាទុកការកំណត់',
                    ),
              textAlign: TextAlign.center,
            ),
            style: FilledButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
              padding: const EdgeInsets.symmetric(
                vertical: 17,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // =====================================================
  // MAIN SCREEN
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppPreferences.instance,
      builder: (context, _) {
        final theme = Theme.of(context);
        final colors = theme.colorScheme;
        final isDark = theme.brightness == Brightness.dark;

        final backgroundColor = isDark
            ? theme.scaffoldBackgroundColor
            : const Color(0xFFF8F7FB);

        return Scaffold(
          backgroundColor: backgroundColor,

          appBar: AppBar(
            backgroundColor: backgroundColor,
            foregroundColor: colors.onSurface,
            elevation: 0,
            centerTitle: true,
            title: Text(
              _tr(
                'Settings',
                'ការកំណត់',
              ),
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          body: _loading
              ? Center(
                  child: CircularProgressIndicator(
                    color: colors.primary,
                  ),
                )
              : _error != null
                  ? _buildErrorState()
                  : _buildSettingsContent(),
        );
      },
    );
  }
}