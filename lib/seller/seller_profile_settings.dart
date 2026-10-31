import 'package:flutter/material.dart';

import '../services/commerce_api.dart';
import '../services/app_preferences.dart';

// =====================================================
// COMMON HELPERS
// =====================================================

String _tr(String english, String khmer) {
  return AppPreferences.instance.translate(english, khmer);
}

void _message(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(text)),
  );
}

InputDecoration _field(BuildContext context, String label) {
  final colors = Theme.of(context).colorScheme;

  return InputDecoration(
    labelText: label,
    labelStyle: TextStyle(color: colors.onSurfaceVariant),
    filled: true,
    fillColor: colors.surfaceContainerHigh,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 14,
      vertical: 15,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: colors.outlineVariant),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: colors.primary,
        width: 1.5,
      ),
    ),
  );
}

String? _required(String? value) {
  if (value == null || value.trim().isEmpty) {
    return _tr('Required field', 'សូមបំពេញព័ត៌មាននេះ');
  }
  return null;
}

Widget _notice(BuildContext context, String text) {
  final colors = Theme.of(context).colorScheme;

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: colors.primaryContainer,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.info_outline,
          color: colors.onPrimaryContainer,
          size: 20,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: colors.onPrimaryContainer,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ),
      ],
    ),
  );
}

// =====================================================
// SELLER PAYOUT SCREEN
// =====================================================

class SellerPayoutScreen extends StatefulWidget {
  const SellerPayoutScreen({super.key});

  @override
  State<SellerPayoutScreen> createState() =>
      _SellerPayoutScreenState();
}

class _SellerPayoutScreenState extends State<SellerPayoutScreen> {
  final _form = GlobalKey<FormState>();

  final _holder = TextEditingController();
  final _bank = TextEditingController();
  final _number = TextEditingController();

  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  // =====================================================
  // LOAD PAYOUT DETAILS FROM LARAVEL
  // =====================================================

  Future<void> _load() async {
    try {
      final data =
          await CommerceApi.instance.sellerPayoutAccount();

      if (!mounted) return;

      _holder.text =
          data?['account_holder']?.toString() ?? '';

      _bank.text =
          data?['bank_name']?.toString() ?? '';

      _number.text =
          data?['account_number']?.toString() ?? '';
    } catch (error) {
      if (!mounted) return;

      _message(
        context,
        '${_tr(
          'Could not load payout details',
          'មិនអាចផ្ទុកព័ត៌មានទទួលប្រាក់បាន',
        )}: $error',
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
  // SAVE PAYOUT DETAILS TO LARAVEL
  // =====================================================

  Future<void> _save() async {
    if (_saving || !_form.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _saving = true;
    });

    try {
      await CommerceApi.instance.saveSellerPayoutAccount(
        accountHolder: _holder.text.trim(),
        bankName: _bank.text.trim(),
        accountNumber: _number.text.trim(),
      );

      if (!mounted) return;

      _message(
        context,
        _tr(
          'Payout details saved',
          'បានរក្សាទុកព័ត៌មានទទួលប្រាក់',
        ),
      );
    } catch (error) {
      if (!mounted) return;

      _message(
        context,
        '${_tr(
          'Could not save',
          'មិនអាចរក្សាទុកបាន',
        )}: $error',
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _holder.dispose();
    _bank.dispose();
    _number.dispose();
    super.dispose();
  }

  // =====================================================
  // PAYOUT SCREEN UI
  // =====================================================

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _tr(
            'Payout account',
            'គណនីទទួលប្រាក់',
          ),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Form(
              key: _form,
              child: ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.all(18),
                children: [
                  _notice(
                    context,
                    _tr(
                      'For demonstration only. Do not enter real banking details. Payments and withdrawals are not enabled.',
                      'សម្រាប់ការបង្ហាញសាកល្បងប៉ុណ្ណោះ។ សូមកុំបញ្ចូលព័ត៌មានធនាគារពិតប្រាកដ។ មុខងារទូទាត់ និងដកប្រាក់មិនទាន់ដំណើរការទេ។',
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    _tr(
                      'Account information',
                      'ព័ត៌មានគណនី',
                    ),
                    style: TextStyle(
                      color: colors.onSurface,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _holder,
                    enabled: !_saving,
                    decoration: _field(
                      context,
                      _tr(
                        'Account holder',
                        'ឈ្មោះម្ចាស់គណនី',
                      ),
                    ),
                    validator: _required,
                    textInputAction: TextInputAction.next,
                  ),

                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _bank,
                    enabled: !_saving,
                    decoration: _field(
                      context,
                      _tr(
                        'Bank name',
                        'ឈ្មោះធនាគារ',
                      ),
                    ),
                    validator: _required,
                    textInputAction: TextInputAction.next,
                  ),

                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _number,
                    enabled: !_saving,
                    decoration: _field(
                      context,
                      _tr(
                        'Account number (demo only)',
                        'លេខគណនី (សម្រាប់សាកល្បង)',
                      ),
                    ),
                    validator: _required,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                  ),

                  const SizedBox(height: 24),

                  FilledButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: _saving
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colors.onPrimary,
                            ),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(
                      _saving
                          ? _tr(
                              'Saving...',
                              'កំពុងរក្សាទុក...',
                            )
                          : _tr(
                              'Save payout details',
                              'រក្សាទុកព័ត៌មានទទួលប្រាក់',
                            ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: colors.onPrimary,
                      minimumSize: const Size(
                        double.infinity,
                        52,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// =====================================================
// SELLER SHIPPING SCREEN
// =====================================================

class SellerShippingScreen extends StatefulWidget {
  const SellerShippingScreen({super.key});

  @override
  State<SellerShippingScreen> createState() =>
      _SellerShippingScreenState();
}

class _SellerShippingScreenState
    extends State<SellerShippingScreen> {
  final _form = GlobalKey<FormState>();

  final _address = TextEditingController();
  final _courier = TextEditingController();
  final _fee = TextEditingController(text: '0');
  final _days = TextEditingController(text: '3');

  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  // =====================================================
  // LOAD SHIPPING SETTINGS FROM LARAVEL
  // =====================================================

  Future<void> _load() async {
    try {
      final data =
          await CommerceApi.instance.sellerShippingSettings();

      if (!mounted) return;

      if (data != null) {
        _address.text =
            data['pickup_address']?.toString() ?? '';

        _courier.text =
            data['courier_name']?.toString() ?? '';

        _fee.text =
            data['shipping_fee']?.toString() ?? '0';

        _days.text =
            data['estimated_days']?.toString() ?? '3';
      }
    } catch (error) {
      if (!mounted) return;

      _message(
        context,
        '${_tr(
          'Could not load shipping settings',
          'មិនអាចផ្ទុកការកំណត់ដឹកជញ្ជូនបាន',
        )}: $error',
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
  // SAVE SHIPPING SETTINGS TO LARAVEL
  // =====================================================

  Future<void> _save() async {
    if (_saving || !_form.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _saving = true;
    });

    try {
      await CommerceApi.instance.saveSellerShippingSettings(
        pickupAddress: _address.text.trim(),
        courierName: _courier.text.trim(),
        shippingFee: double.parse(_fee.text.trim()),
        estimatedDays: int.parse(_days.text.trim()),
      );

      if (!mounted) return;

      _message(
        context,
        _tr(
          'Shipping settings saved',
          'បានរក្សាទុកការកំណត់ដឹកជញ្ជូន',
        ),
      );
    } catch (error) {
      if (!mounted) return;

      _message(
        context,
        '${_tr(
          'Could not save',
          'មិនអាចរក្សាទុកបាន',
        )}: $error',
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _address.dispose();
    _courier.dispose();
    _fee.dispose();
    _days.dispose();
    super.dispose();
  }

  // =====================================================
  // SHIPPING SCREEN UI
  // =====================================================

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _tr(
            'Shipping & delivery',
            'ការដឹកជញ្ជូន',
          ),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Form(
              key: _form,
              child: ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.all(18),
                children: [
                  _notice(
                    context,
                    _tr(
                      'Set your preferred shipping details. These settings do not automatically change checkout fees.',
                      'កំណត់ព័ត៌មានដឹកជញ្ជូនរបស់អ្នក។ ការកំណត់ទាំងនេះមិនផ្លាស់ប្តូរថ្លៃដឹកជញ្ជូននៅពេលទូទាត់ដោយស្វ័យប្រវត្តិទេ។',
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    _tr(
                      'Shipping information',
                      'ព័ត៌មានដឹកជញ្ជូន',
                    ),
                    style: TextStyle(
                      color: colors.onSurface,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _address,
                    enabled: !_saving,
                    maxLines: 2,
                    decoration: _field(
                      context,
                      _tr(
                        'Pickup address',
                        'អាសយដ្ឋានទទួលទំនិញ',
                      ),
                    ),
                    validator: _required,
                  ),

                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _courier,
                    enabled: !_saving,
                    decoration: _field(
                      context,
                      _tr(
                        'Courier name (optional)',
                        'ឈ្មោះអ្នកដឹកជញ្ជូន (មិនបាច់បំពេញក៏បាន)',
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _fee,
                    enabled: !_saving,
                    keyboardType:
                        const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: _field(
                      context,
                      _tr(
                        'Shipping fee (USD)',
                        'ថ្លៃដឹកជញ្ជូន (ដុល្លារ)',
                      ),
                    ),
                    validator: (value) {
                      final number =
                          double.tryParse(value?.trim() ?? '');

                      if (number == null ||
                          !number.isFinite ||
                          number < 0) {
                        return _tr(
                          'Enter a valid non-negative fee',
                          'សូមបញ្ចូលថ្លៃដឹកជញ្ជូនត្រឹមត្រូវ',
                        );
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _days,
                    enabled: !_saving,
                    keyboardType: TextInputType.number,
                    decoration: _field(
                      context,
                      _tr(
                        'Estimated delivery days',
                        'ចំនួនថ្ងៃដឹកជញ្ជូនប៉ាន់ស្មាន',
                      ),
                    ),
                    validator: (value) {
                      final number =
                          int.tryParse(value?.trim() ?? '');

                      if (number == null ||
                          number < 1 ||
                          number > 365) {
                        return _tr(
                          'Enter 1 to 365 days',
                          'សូមបញ្ចូលចន្លោះពី ១ ដល់ ៣៦៥ ថ្ងៃ',
                        );
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  FilledButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: _saving
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colors.onPrimary,
                            ),
                          )
                        : const Icon(
                            Icons.local_shipping_outlined,
                          ),
                    label: Text(
                      _saving
                          ? _tr(
                              'Saving...',
                              'កំពុងរក្សាទុក...',
                            )
                          : _tr(
                              'Save shipping settings',
                              'រក្សាទុកការកំណត់ដឹកជញ្ជូន',
                            ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: colors.onPrimary,
                      minimumSize: const Size(
                        double.infinity,
                        52,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// =====================================================
// SELLER CUSTOMER REVIEWS SCREEN
// =====================================================

class SellerReviewsScreen extends StatefulWidget {
  const SellerReviewsScreen({super.key});

  @override
  State<SellerReviewsScreen> createState() =>
      _SellerReviewsScreenState();
}

class _SellerReviewsScreenState
    extends State<SellerReviewsScreen> {
  bool _loading = true;
  String? _error;

  List<Map<String, dynamic>> _reviews = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  // =====================================================
  // LOAD REVIEWS FROM LARAVEL
  // =====================================================

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final reviews =
          await CommerceApi.instance.sellerReviews();

      if (!mounted) return;

      setState(() {
        _reviews = reviews;
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
  // REPLY TO CUSTOMER REVIEW
  // =====================================================

  Future<void> _reply(Map<String, dynamic> review) async {
    final controller = TextEditingController(
      text: review['seller_reply']?.toString() ?? '',
    );

    final response = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            _tr(
              'Reply to review',
              'ឆ្លើយតបការវាយតម្លៃ',
            ),
          ),
          content: TextField(
            controller: controller,
            maxLines: 4,
            maxLength: 2000,
            decoration: _field(
              dialogContext,
              _tr(
                'Your reply',
                'ការឆ្លើយតបរបស់អ្នក',
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(
                _tr(
                  'Cancel',
                  'បោះបង់',
                ),
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  controller.text.trim(),
                );
              },
              child: Text(
                _tr(
                  'Send',
                  'ផ្ញើ',
                ),
              ),
            ),
          ],
        );
      },
    );

    // Dispose after the dialog has finished closing.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.dispose();
    });

    if (!mounted ||
        response == null ||
        response.isEmpty) {
      return;
    }

    try {
      final id = int.parse(review['id'].toString());

      await CommerceApi.instance.replyToSellerReview(
        id,
        response,
      );

      if (!mounted) return;

      _message(
        context,
        _tr(
          'Reply saved',
          'បានរក្សាទុកការឆ្លើយតប',
        ),
      );

      await _load();
    } catch (error) {
      if (!mounted) return;

      _message(
        context,
        '${_tr(
          'Could not reply',
          'មិនអាចឆ្លើយតបបាន',
        )}: $error',
      );
    }
  }

  // =====================================================
  // REVIEW CARD
  // =====================================================

  Widget _reviewCard(Map<String, dynamic> review) {
    final colors = Theme.of(context).colorScheme;

    final rating =
        int.tryParse(review['rating']?.toString() ?? '') ?? 0;

    final safeRating = rating.clamp(0, 5).toInt();

    final reply =
        review['seller_reply']?.toString() ?? '';

    final comment =
        review['comment']?.toString() ?? '';

    final product =
        review['product_name']?.toString() ??
        _tr('Product', 'ផលិតផល');

    final customer =
        review['customer_name']?.toString() ??
        _tr('Customer', 'អតិថិជន');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: colors.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product,
              style: TextStyle(
                color: colors.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              '${_tr('By', 'ដោយ')} $customer',
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              '${'★' * safeRating}${'☆' * (5 - safeRating)}',
              style: const TextStyle(
                color: Colors.orange,
                fontSize: 20,
              ),
            ),

            if (comment.isNotEmpty) ...[
              const SizedBox(height: 10),

              Text(
                comment,
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],

            if (reply.isNotEmpty) ...[
              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_tr('Your reply', 'ការឆ្លើយតបរបស់អ្នក')}: $reply',
                  style: TextStyle(
                    color: colors.onPrimaryContainer,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 8),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _reply(review),
                icon: Icon(
                  reply.isEmpty
                      ? Icons.reply_outlined
                      : Icons.edit_outlined,
                  size: 18,
                ),
                label: Text(
                  reply.isEmpty
                      ? _tr(
                          'Reply',
                          'ឆ្លើយតប',
                        )
                      : _tr(
                          'Edit reply',
                          'កែប្រែការឆ្លើយតប',
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // CUSTOMER REVIEWS UI
  // =====================================================

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _tr(
            'Customer reviews',
            'ការវាយតម្លៃអតិថិជន',
          ),
        ),
        actions: [
          IconButton(
            tooltip: _tr('Refresh', 'ផ្ទុកឡើងវិញ'),
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: colors.error,
                          size: 44,
                        ),

                        const SizedBox(height: 12),

                        Text(
                          _tr(
                            'Could not load reviews',
                            'មិនអាចផ្ទុកការវាយតម្លៃបាន',
                          ),
                          style: TextStyle(
                            color: colors.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: colors.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),

                        const SizedBox(height: 14),

                        FilledButton(
                          onPressed: _load,
                          child: Text(
                            _tr(
                              'Retry',
                              'ព្យាយាមម្តងទៀត',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: _reviews.isEmpty
                      ? ListView(
                          children: [
                            const SizedBox(height: 150),

                            Icon(
                              Icons.rate_review_outlined,
                              size: 55,
                              color: colors.onSurfaceVariant,
                            ),

                            const SizedBox(height: 14),

                            Center(
                              child: Text(
                                _tr(
                                  'No customer reviews yet',
                                  'មិនទាន់មានការវាយតម្លៃពីអតិថិជនទេ',
                                ),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: colors.onSurfaceVariant,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _reviews.length,
                          itemBuilder: (context, index) {
                            return _reviewCard(
                              _reviews[index],
                            );
                          },
                        ),
                ),
    );
  }
}