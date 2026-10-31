import 'package:flutter/material.dart';

import 'package:y3s1_final/services/app_preferences.dart';
import 'package:y3s1_final/services/commerce_api.dart';

// =====================================================
// CUSTOMER SHIPPING ADDRESS SCREEN
// DARK MODE + ENGLISH / KHMER + LARAVEL
// =====================================================

class ShippingAddressScreen extends StatefulWidget {
  const ShippingAddressScreen({super.key});

  @override
  State<ShippingAddressScreen> createState() => _ShippingAddressScreenState();
}

class _ShippingAddressScreenState extends State<ShippingAddressScreen> {
  List<Map<String, dynamic>> _addresses = [];

  bool _loading = true;
  int? _busyId;

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
    _loadAddresses();
  }

  // =====================================================
  // LOAD ADDRESSES FROM LARAVEL
  // =====================================================

  Future<void> _loadAddresses() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final addresses = await CommerceApi.instance.customerAddresses();

      if (!mounted) return;

      setState(() {
        _addresses = addresses;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = error.toString();
      });

      _message(
        '${_tr(
          'Unable to load addresses',
          'មិនអាចផ្ទុកអាសយដ្ឋានបាន',
        )}: $error',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  // =====================================================
  // SHOW MESSAGE
  // =====================================================

  void _message(
    String message, {
    bool isError = false,
  }) {
    if (!mounted) return;

    final colors = Theme.of(context).colorScheme;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: isError ? colors.error : null,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // =====================================================
  // INPUT DECORATION
  // =====================================================

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    String? hint,
  }) {
    final colors = Theme.of(context).colorScheme;

    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: TextStyle(
        color: colors.onSurfaceVariant,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      hintStyle: TextStyle(
        color: colors.onSurfaceVariant,
        fontSize: 13,
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: colors.error,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: colors.error,
          width: 2,
        ),
      ),
    );
  }

  // =====================================================
  // ADD OR EDIT ADDRESS
  // =====================================================

  Future<void> _openAddressForm({
    Map<String, dynamic>? existing,
  }) async {
    final formKey = GlobalKey<FormState>();

    final nameController = TextEditingController(
      text: existing?['full_name']?.toString() ?? '',
    );

    final phoneController = TextEditingController(
      text: existing?['phone']?.toString() ?? '',
    );

    final cityController = TextEditingController(
      text: existing?['city']?.toString() ?? '',
    );

    final addressController = TextEditingController(
      text: existing?['address']?.toString() ?? '',
    );

    bool isDefault = existing?['is_default'] == true ||
        existing?['is_default'] == 1 ||
        existing?['is_default'] == '1';

    bool saving = false;
    bool saved = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            final colors = Theme.of(dialogContext).colorScheme;

            return AlertDialog(
              backgroundColor: colors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                existing == null
                    ? _tr(
                        'Add Shipping Address',
                        'បន្ថែមអាសយដ្ឋានដឹកជញ្ជូន',
                      )
                    : _tr(
                        'Edit Shipping Address',
                        'កែប្រែអាសយដ្ឋានដឹកជញ្ជូន',
                      ),
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // FULL NAME
                        TextFormField(
                          controller: nameController,
                          enabled: !saving,
                          textCapitalization: TextCapitalization.words,
                          style: TextStyle(
                            color: colors.onSurface,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: _inputDecoration(
                            label: _tr('Full Name', 'ឈ្មោះពេញ'),
                            icon: Icons.person_outline_rounded,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return _tr(
                                'Enter your name',
                                'សូមបញ្ចូលឈ្មោះរបស់អ្នក',
                              );
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 14),

                        // PHONE NUMBER
                        TextFormField(
                          controller: phoneController,
                          enabled: !saving,
                          keyboardType: TextInputType.phone,
                          style: TextStyle(
                            color: colors.onSurface,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: _inputDecoration(
                            label: _tr(
                              'Phone Number',
                              'លេខទូរស័ព្ទ',
                            ),
                            icon: Icons.phone_outlined,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return _tr(
                                'Enter your phone number',
                                'សូមបញ្ចូលលេខទូរស័ព្ទ',
                              );
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 14),

                        // CITY / PROVINCE
                        TextFormField(
                          controller: cityController,
                          enabled: !saving,
                          style: TextStyle(
                            color: colors.onSurface,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: _inputDecoration(
                            label: _tr(
                              'City / Province',
                              'ទីក្រុង / ខេត្ត',
                            ),
                            icon: Icons.location_city_outlined,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return _tr(
                                'Enter your city',
                                'សូមបញ្ចូលទីក្រុង ឬខេត្ត',
                              );
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 14),

                        // FULL ADDRESS
                        TextFormField(
                          controller: addressController,
                          enabled: !saving,
                          maxLines: 3,
                          style: TextStyle(
                            color: colors.onSurface,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: _inputDecoration(
                            label: _tr(
                              'Full Address',
                              'អាសយដ្ឋានពេញលេញ',
                            ),
                            hint: _tr(
                              'Street, house number, village...',
                              'ផ្លូវ លេខផ្ទះ ភូមិ...',
                            ),
                            icon: Icons.home_outlined,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return _tr(
                                'Enter your full address',
                                'សូមបញ្ចូលអាសយដ្ឋានពេញលេញ',
                              );
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 12),

                        // DEFAULT ADDRESS SWITCH
                        Container(
                          decoration: BoxDecoration(
                            color: colors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: colors.outlineVariant,
                            ),
                          ),
                          child: SwitchListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 3,
                            ),
                            title: Text(
                              _tr(
                                'Set as default address',
                                'កំណត់ជាអាសយដ្ឋានលំនាំដើម',
                              ),
                              style: TextStyle(
                                color: colors.onSurface,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            value: isDefault,
                            activeTrackColor: colors.primary,
                            activeColor: colors.onPrimary,
                            onChanged: saving
                                ? null
                                : (value) {
                                    setDialogState(() {
                                      isDefault = value;
                                    });
                                  },
                          ),
                        ),
                      ],
                    ),
                  ),
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
                          if (!formKey.currentState!.validate()) {
                            return;
                          }

                          setDialogState(() {
                            saving = true;
                          });

                          try {
                            await CommerceApi.instance.saveCustomerAddress(
                              id: existing?['id'] == null
                                  ? null
                                  : int.parse(
                                      existing!['id'].toString(),
                                    ),
                              fullName: nameController.text.trim(),
                              phone: phoneController.text.trim(),
                              city: cityController.text.trim(),
                              address: addressController.text.trim(),
                              isDefault: isDefault,
                            );

                            saved = true;

                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                            }
                          } catch (error) {
                            if (!mounted) return;

                            _message(
                              '${_tr(
                                'Unable to save address',
                                'មិនអាចរក្សាទុកអាសយដ្ឋានបាន',
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
                          width: 18,
                          height: 18,
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

    // Allow the dialog closing animation to finish.
    await Future<void>.delayed(
      const Duration(milliseconds: 300),
    );

    nameController.dispose();
    phoneController.dispose();
    cityController.dispose();
    addressController.dispose();

    if (saved && mounted) {
      _message(
        _tr(
          'Address saved successfully',
          'បានរក្សាទុកអាសយដ្ឋានដោយជោគជ័យ',
        ),
      );

      await _loadAddresses();
    }
  }

  // =====================================================
  // SET DEFAULT ADDRESS
  // =====================================================

  Future<void> _setDefault(int id) async {
    if (_busyId != null) return;

    setState(() {
      _busyId = id;
    });

    try {
      await CommerceApi.instance.setDefaultCustomerAddress(id);

      if (!mounted) return;

      _message(
        _tr(
          'Default address updated',
          'បានកែប្រែអាសយដ្ឋានលំនាំដើម',
        ),
      );

      await _loadAddresses();
    } catch (error) {
      if (!mounted) return;

      _message(
        '${_tr(
          'Unable to update default address',
          'មិនអាចកែប្រែអាសយដ្ឋានលំនាំដើមបាន',
        )}: $error',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _busyId = null;
        });
      }
    }
  }

  // =====================================================
  // DELETE ADDRESS
  // =====================================================

  Future<void> _deleteAddress(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final colors = Theme.of(dialogContext).colorScheme;

        return AlertDialog(
          backgroundColor: colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            _tr('Delete Address', 'លុបអាសយដ្ឋាន'),
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            _tr(
              'Are you sure you want to delete this address?',
              'តើអ្នកប្រាកដថាចង់លុបអាសយដ្ឋាននេះឬ?',
            ),
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 15,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                _tr('Cancel', 'បោះបង់'),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(
                _tr('Delete', 'លុប'),
                style: TextStyle(
                  color: colors.error,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;
    if (_busyId != null) return;

    setState(() {
      _busyId = id;
    });

    try {
      await CommerceApi.instance.deleteCustomerAddress(id);

      if (!mounted) return;

      _message(
        _tr(
          'Address deleted successfully',
          'បានលុបអាសយដ្ឋានដោយជោគជ័យ',
        ),
      );

      await _loadAddresses();
    } catch (error) {
      if (!mounted) return;

      _message(
        '${_tr(
          'Unable to delete address',
          'មិនអាចលុបអាសយដ្ឋានបាន',
        )}: $error',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _busyId = null;
        });
      }
    }
  }

  // =====================================================
  // ADDRESS CARD
  // =====================================================

  Widget _buildAddressCard(Map<String, dynamic> item) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final id = int.tryParse(
      item['id']?.toString() ?? '',
    );

    final isDefault = item['is_default'] == true ||
        item['is_default'] == 1 ||
        item['is_default'] == '1';

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: isDefault ? colors.primary : colors.outlineVariant,
          width: isDefault ? 1.5 : 1,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ADDRESS HEADER
          Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  Icons.location_on_outlined,
                  color: colors.onPrimaryContainer,
                  size: 23,
                ),
              ),

              const SizedBox(width: 11),

              Expanded(
                child: Text(
                  item['full_name']?.toString() ?? '',
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                  ),
                ),
              ),

              if (isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _tr('Default', 'លំនាំដើម'),
                    style: TextStyle(
                      color: colors.onPrimaryContainer,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 15),

          // PHONE NUMBER
          _infoRow(
            icon: Icons.phone_outlined,
            text: item['phone']?.toString() ?? '',
            important: true,
          ),

          const SizedBox(height: 10),

          // CITY / PROVINCE
          _infoRow(
            icon: Icons.location_city_outlined,
            text: item['city']?.toString() ?? '',
          ),

          const SizedBox(height: 10),

          // FULL ADDRESS
          _infoRow(
            icon: Icons.home_outlined,
            text: item['address']?.toString() ?? '',
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 13),
            child: Divider(height: 1),
          ),

          // ACTION BUTTONS
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (!isDefault && id != null)
                OutlinedButton.icon(
                  onPressed: _busyId != null
                      ? null
                      : () => _setDefault(id),
                  icon: const Icon(
                    Icons.check_circle_outline_rounded,
                    size: 18,
                  ),
                  label: Text(
                    _tr(
                      'Set Default',
                      'កំណត់លំនាំដើម',
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.primary,
                    side: BorderSide(
                      color: colors.primary,
                    ),
                  ),
                ),

              OutlinedButton.icon(
                onPressed: _busyId != null
                    ? null
                    : () => _openAddressForm(existing: item),
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 18,
                ),
                label: Text(
                  _tr('Edit', 'កែប្រែ'),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.onSurface,
                  side: BorderSide(
                    color: colors.outlineVariant,
                  ),
                ),
              ),

              if (id != null)
                OutlinedButton.icon(
                  onPressed: _busyId != null
                      ? null
                      : () => _deleteAddress(id),
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: colors.error,
                    size: 18,
                  ),
                  label: Text(
                    _tr('Delete', 'លុប'),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.error,
                    side: BorderSide(
                      color: colors.error,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // =====================================================
  // ADDRESS INFORMATION ROW
  // =====================================================

  Widget _infoRow({
    required IconData icon,
    required String text,
    bool important = false,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 19,
          color: colors.primary,
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: important
                  ? colors.onSurface
                  : colors.onSurfaceVariant,
              fontSize: 14,
              fontWeight:
                  important ? FontWeight.w700 : FontWeight.w500,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  // =====================================================
  // EMPTY STATE
  // =====================================================

  Widget _buildEmptyState() {
    final colors = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: constraints.maxHeight,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          color: colors.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.location_off_outlined,
                          size: 55,
                          color: colors.onPrimaryContainer,
                        ),
                      ),

                      const SizedBox(height: 22),

                      Text(
                        _tr(
                          'No shipping addresses yet',
                          'មិនទាន់មានអាសយដ្ឋានដឹកជញ្ជូនទេ',
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
                        _tr(
                          'Tap Add Address to create one.',
                          'ចុចបន្ថែមអាសយដ្ឋានដើម្បីបង្កើតថ្មី។',
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
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
            Icon(
              Icons.error_outline_rounded,
              size: 55,
              color: colors.error,
            ),
            const SizedBox(height: 18),
            Text(
              _tr(
                'Unable to load addresses',
                'មិនអាចផ្ទុកអាសយដ្ឋានបាន',
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 19,
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
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _loadAddresses,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(
                _tr('Try Again', 'ព្យាយាមម្តងទៀត'),
              ),
            ),
          ],
        ),
      ),
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
            : const Color(0xFFFFF7F7);

        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            backgroundColor: backgroundColor,
            foregroundColor: colors.onSurface,
            elevation: 0,
            centerTitle: true,
            title: Text(
              _tr(
                'Shipping Address',
                'អាសយដ្ឋានដឹកជញ្ជូន',
              ),
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          // ADD ADDRESS BUTTON
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _busyId != null
                ? null
                : () => _openAddressForm(),
            backgroundColor: colors.primary,
            foregroundColor: colors.onPrimary,
            icon: const Icon(Icons.add_rounded),
            label: Text(
              _tr(
                'Add Address',
                'បន្ថែមអាសយដ្ឋាន',
              ),
              style: const TextStyle(
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
                  : RefreshIndicator(
                      onRefresh: _loadAddresses,
                      child: _addresses.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              physics:
                                  const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                16,
                                16,
                                110,
                              ),
                              itemCount: _addresses.length,
                              itemBuilder: (context, index) {
                                return _buildAddressCard(
                                  _addresses[index],
                                );
                              },
                            ),
                    ),
        );
      },
    );
  }
}