import 'package:flutter/material.dart';

import 'package:y3s1_final/services/app_preferences.dart';

// =====================================================
// TRANSLATION HELPER
// =====================================================

String _tr(String english, String khmer) {
  return AppPreferences.instance.translate(english, khmer);
}

// =====================================================
// PAYMENT METHOD SCREEN
// =====================================================

class PaymentMethodScreen extends StatelessWidget {
  const PaymentMethodScreen({super.key});

  static const Color _purple = Color(0xFF6C4DD3);
  static const Color _lightBackground = Color(0xFFF8F7FB);

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
            : _lightBackground;

        final cardColor = colors.surface;

        final primaryColor = isDark
            ? colors.primary
            : _purple;

        return Scaffold(
          backgroundColor: backgroundColor,

          // =====================================================
          // APP BAR
          // =====================================================

          appBar: AppBar(
            backgroundColor: backgroundColor,
            foregroundColor: colors.onSurface,
            elevation: 0,
            centerTitle: true,
            title: Text(
              _tr(
                'Payment Method',
                'វិធីសាស្ត្រទូទាត់ប្រាក់',
              ),
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          // =====================================================
          // BODY
          // =====================================================

          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                20,
                22,
                20,
                30,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // =====================================================
                  // HEADER
                  // =====================================================

                  Text(
                    _tr(
                      'Available Payment Methods',
                      'វិធីសាស្ត្រទូទាត់ប្រាក់ដែលមាន',
                    ),
                    style: TextStyle(
                      color: colors.onSurface,
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 9),

                  Text(
                    _tr(
                      'Choose how you want to pay for your orders.',
                      'ជ្រើសរើសវិធីដែលអ្នកចង់ទូទាត់ប្រាក់សម្រាប់ការបញ្ជាទិញ។',
                    ),
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // =====================================================
                  // PAYMENT SECTION
                  // =====================================================

                  Text(
                    _tr(
                      'PAYMENT OPTIONS',
                      'ជម្រើសទូទាត់ប្រាក់',
                    ),
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),

                  const SizedBox(height: 13),

                  // =====================================================
                  // CASH ON DELIVERY CARD
                  // =====================================================

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: primaryColor,
                        width: 1.7,
                      ),
                      boxShadow: isDark
                          ? []
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(
                                  alpha: 0.05,
                                ),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // PAYMENT ICON
                            Container(
                              width: 55,
                              height: 55,
                              decoration: BoxDecoration(
                                color: colors.primaryContainer,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                Icons.payments_outlined,
                                color: colors.onPrimaryContainer,
                                size: 30,
                              ),
                            ),

                            const SizedBox(width: 14),

                            // PAYMENT INFORMATION
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _tr(
                                      'Cash on Delivery',
                                      'បង់ប្រាក់ពេលទទួលទំនិញ',
                                    ),
                                    style: TextStyle(
                                      color: colors.onSurface,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      height: 1.4,
                                    ),
                                  ),

                                  const SizedBox(height: 5),

                                  Text(
                                    _tr(
                                      'Pay when your order arrives.',
                                      'បង់ប្រាក់នៅពេលទំនិញមកដល់។',
                                    ),
                                    style: TextStyle(
                                      color: colors.onSurfaceVariant,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 8),

                            // SELECTED INDICATOR
                            Icon(
                              Icons.check_circle_rounded,
                              color: primaryColor,
                              size: 27,
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // SELECTED BADGE
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 13,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: colors.primaryContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified_rounded,
                                size: 16,
                                color: colors.onPrimaryContainer,
                              ),

                              const SizedBox(width: 7),

                              Text(
                                _tr(
                                  'Currently Available',
                                  'អាចប្រើប្រាស់បាន',
                                ),
                                style: TextStyle(
                                  color: colors.onPrimaryContainer,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // =====================================================
                  // HOW IT WORKS
                  // =====================================================

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: colors.outlineVariant,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              color: colors.primary,
                              size: 23,
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: Text(
                                _tr(
                                  'How it works',
                                  'របៀបប្រើប្រាស់',
                                ),
                                style: TextStyle(
                                  color: colors.onSurface,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        _step(
                          context,
                          '1',
                          _tr(
                            'Place your order.',
                            'ធ្វើការបញ្ជាទិញរបស់អ្នក។',
                          ),
                        ),

                        const SizedBox(height: 12),

                        _step(
                          context,
                          '2',
                          _tr(
                            'Wait for your order to arrive.',
                            'រង់ចាំទំនិញរបស់អ្នកមកដល់។',
                          ),
                        ),

                        const SizedBox(height: 12),

                        _step(
                          context,
                          '3',
                          _tr(
                            'Pay the delivery person.',
                            'បង់ប្រាក់ទៅអ្នកដឹកជញ្ជូន។',
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // =====================================================
                  // FUTURE PAYMENT NOTICE
                  // =====================================================

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colors.outlineVariant,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.lightbulb_outline_rounded,
                          color: colors.primary,
                          size: 23,
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                _tr(
                                  'Coming Soon',
                                  'នឹងមានក្នុងពេលឆាប់ៗនេះ',
                                ),
                                style: TextStyle(
                                  color: colors.onSurface,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),

                              const SizedBox(height: 6),

                              Text(
                                _tr(
                                  'Online payment options will be available in a future update.',
                                  'ជម្រើសទូទាត់ប្រាក់តាមអនឡាញនឹងមាននៅក្នុងការអាប់ដេតនាពេលអនាគត។',
                                ),
                                style: TextStyle(
                                  color: colors.onSurfaceVariant,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

  // =====================================================
  // PAYMENT STEP WIDGET
  // =====================================================

  Widget _step(
    BuildContext context,
    String number,
    String description,
  ) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 29,
          height: 29,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: TextStyle(
              color: colors.onPrimaryContainer,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              description,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}