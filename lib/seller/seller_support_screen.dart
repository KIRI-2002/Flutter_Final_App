import 'package:flutter/material.dart';

import '../services/commerce_api.dart';
import '../services/app_preferences.dart';

// =====================================================
// SELLER HELP & SUPPORT SCREEN
// Dark Mode + English / Khmer Support
// Laravel API Integration Preserved
// =====================================================

class SellerSupportScreen extends StatefulWidget {
  const SellerSupportScreen({super.key});

  @override
  State<SellerSupportScreen> createState() =>
      _SellerSupportScreenState();
}

class _SellerSupportScreenState extends State<SellerSupportScreen> {
  final _formKey = GlobalKey<FormState>();

  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  List<Map<String, dynamic>> _tickets = [];

  bool _loading = true;
  bool _sending = false;

  String? _error;

  // =====================================================
  // TRANSLATION HELPER
  // =====================================================

  String tr(String english, String khmer) {
    return AppPreferences.instance.translate(
      english,
      khmer,
    );
  }

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  // =====================================================
  // LOAD SUPPORT TICKETS FROM LARAVEL
  // =====================================================

  Future<void> _loadTickets() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final tickets =
          await CommerceApi.instance.sellerSupportTickets();

      if (!mounted) return;

      setState(() {
        _tickets = tickets;
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
  // SEND SUPPORT TICKET TO LARAVEL
  // =====================================================

  Future<void> _sendTicket() async {
    if (_sending || !_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _sending = true;
    });

    try {
      await CommerceApi.instance.createSellerSupportTicket(
        subject: _subjectController.text.trim(),
        message: _messageController.text.trim(),
      );

      if (!mounted) return;

      _subjectController.clear();
      _messageController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr(
              'Support request sent successfully',
              'បានផ្ញើសំណើជំនួយដោយជោគជ័យ',
            ),
          ),
        ),
      );

      await _loadTickets();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${tr(
              'Could not send request',
              'មិនអាចផ្ញើសំណើបាន',
            )}: $error',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _sending = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // =====================================================
  // THEME-AWARE INPUT DECORATION
  // =====================================================

  InputDecoration _decoration(String label) {
    final colors = Theme.of(context).colorScheme;

    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: colors.onSurfaceVariant,
      ),
      filled: true,
      fillColor: colors.surfaceContainerHigh,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 15,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: colors.outlineVariant,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: colors.primary,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: colors.error,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: colors.error,
          width: 1.5,
        ),
      ),
    );
  }

  // =====================================================
  // TRANSLATE SUPPORT STATUS
  // =====================================================

  String _translateStatus(String status) {
    switch (status.toLowerCase().trim()) {
      case 'open':
        return tr(
          'Open',
          'កំពុងបើក',
        );

      case 'closed':
        return tr(
          'Closed',
          'បានបិទ',
        );

      case 'pending':
        return tr(
          'Pending',
          'កំពុងរង់ចាំ',
        );

      case 'resolved':
        return tr(
          'Resolved',
          'បានដោះស្រាយ',
        );

      default:
        return status;
    }
  }

  // =====================================================
  // BUILD SUPPORT TICKET CARD
  // =====================================================

  Widget _buildTicket(Map<String, dynamic> ticket) {
    final colors = Theme.of(context).colorScheme;
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final subject =
        ticket['subject']?.toString() ?? '';

    final message =
        ticket['message']?.toString() ?? '';

    final status =
        ticket['status']?.toString() ?? 'open';

    final reply =
        ticket['admin_reply']?.toString() ?? '';

    final date =
        ticket['created_at']?.toString() ?? '';

    final isClosed =
        status.toLowerCase().trim() == 'closed';

    final statusBackground = isClosed
        ? colors.surfaceContainerHighest
        : isDark
            ? const Color(0xFF174B36)
            : const Color(0xFFD7F1E8);

    final statusText = isClosed
        ? colors.onSurfaceVariant
        : isDark
            ? const Color(0xFF9CE8BC)
            : const Color(0xFF176B47);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: colors.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =====================================================
            // TICKET SUBJECT AND STATUS
            // =====================================================

            Row(
              children: [
                Expanded(
                  child: Text(
                    subject,
                    style: TextStyle(
                      color: colors.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusBackground,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _translateStatus(status),
                    style: TextStyle(
                      color: statusText,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            // =====================================================
            // DATE
            // =====================================================

            if (date.isNotEmpty) ...[
              const SizedBox(height: 6),

              Text(
                date,
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
            ],

            const SizedBox(height: 16),

            // =====================================================
            // SELLER MESSAGE
            // =====================================================

            Row(
              children: [
                Icon(
                  Icons.message_outlined,
                  color: colors.primary,
                  size: 18,
                ),

                const SizedBox(width: 7),

                Text(
                  tr(
                    'Your message',
                    'សាររបស់អ្នក',
                  ),
                  style: TextStyle(
                    color: colors.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              message,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 13,
                height: 1.5,
              ),
            ),

            const Divider(height: 28),

            // =====================================================
            // ADMIN REPLY
            // =====================================================

            Row(
              children: [
                Icon(
                  Icons.support_agent_outlined,
                  color: colors.primary,
                  size: 18,
                ),

                const SizedBox(width: 7),

                Text(
                  tr(
                    'Admin reply',
                    'ការឆ្លើយតបពីអ្នកគ្រប់គ្រង',
                  ),
                  style: TextStyle(
                    color: colors.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                reply.trim().isEmpty
                    ? tr(
                        'Waiting for Admin response...',
                        'កំពុងរង់ចាំការឆ្លើយតបពីអ្នកគ្រប់គ្រង...',
                      )
                    : reply,
                style: TextStyle(
                  color: colors.onPrimaryContainer,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // MAIN SUPPORT SCREEN
  // =====================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,

      appBar: AppBar(
        title: Text(
          tr(
            'Help & Support',
            'ជំនួយ និងការគាំទ្រ',
          ),
        ),
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
      ),

      body: RefreshIndicator(
        onRefresh: _loadTickets,
        child: ListView(
          keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(16),
          children: [
            // =====================================================
            // SUPPORT HEADER
            // =====================================================

            Center(
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.support_agent,
                  size: 48,
                  color: colors.onPrimaryContainer,
                ),
              ),
            ),

            const SizedBox(height: 16),

            Text(
              tr(
                'Seller Help & Support',
                'ជំនួយ និងការគាំទ្រសម្រាប់អ្នកលក់',
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              tr(
                'Need help with your store, products, or orders? Send a message to Admin.',
                'ត្រូវការជំនួយអំពីហាង ផលិតផល ឬការបញ្ជាទិញរបស់អ្នកមែនទេ? សូមផ្ញើសារទៅអ្នកគ្រប់គ្រង។',
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontSize: 13,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 24),

            // =====================================================
            // CREATE SUPPORT REQUEST FORM
            // =====================================================

            Card(
              color: colors.surfaceContainerHigh,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.edit_note_outlined,
                            color: colors.primary,
                          ),

                          const SizedBox(width: 8),

                          Expanded(
                            child: Text(
                              tr(
                                'Create Support Request',
                                'បង្កើតសំណើជំនួយ',
                              ),
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: colors.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // =====================================================
                      // SUBJECT FIELD
                      // =====================================================

                      TextFormField(
                        controller: _subjectController,
                        enabled: !_sending,
                        maxLength: 150,
                        textInputAction: TextInputAction.next,
                        style: TextStyle(
                          color: colors.onSurface,
                        ),
                        decoration: _decoration(
                          tr(
                            'Subject',
                            'ប្រធានបទ',
                          ),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return tr(
                              'Please enter a subject',
                              'សូមបញ្ចូលប្រធានបទ',
                            );
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      // =====================================================
                      // MESSAGE FIELD
                      // =====================================================

                      TextFormField(
                        controller: _messageController,
                        enabled: !_sending,
                        maxLines: 5,
                        maxLength: 5000,
                        style: TextStyle(
                          color: colors.onSurface,
                        ),
                        decoration: _decoration(
                          tr(
                            'Describe your problem',
                            'ពិពណ៌នាអំពីបញ្ហារបស់អ្នក',
                          ),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return tr(
                              'Please enter your message',
                              'សូមបញ្ចូលសាររបស់អ្នក',
                            );
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // =====================================================
                      // SEND BUTTON
                      // =====================================================

                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: colors.primary,
                            foregroundColor: colors.onPrimary,
                            padding: const EdgeInsets.all(15),
                          ),
                          onPressed:
                              _sending ? null : _sendTicket,
                          icon: _sending
                              ? SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: colors.onPrimary,
                                  ),
                                )
                              : const Icon(
                                  Icons.send_outlined,
                                ),
                          label: Text(
                            _sending
                                ? tr(
                                    'Sending...',
                                    'កំពុងផ្ញើ...',
                                  )
                                : tr(
                                    'Send Request',
                                    'ផ្ញើសំណើ',
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // =====================================================
            // MY SUPPORT REQUESTS HEADER
            // =====================================================

            Row(
              children: [
                Expanded(
                  child: Text(
                    tr(
                      'My Support Requests',
                      'សំណើជំនួយរបស់ខ្ញុំ',
                    ),
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface,
                    ),
                  ),
                ),

                IconButton(
                  tooltip: tr(
                    'Refresh',
                    'ផ្ទុកឡើងវិញ',
                  ),
                  onPressed:
                      _loading ? null : _loadTickets,
                  icon: Icon(
                    Icons.refresh,
                    color: colors.primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // =====================================================
            // LOADING SUPPORT REQUESTS
            // =====================================================

            if (_loading)
              const Padding(
                padding: EdgeInsets.all(30),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )

            // =====================================================
            // ERROR LOADING SUPPORT REQUESTS
            // =====================================================

            else if (_error != null)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: colors.error,
                      size: 42,
                    ),

                    const SizedBox(height: 12),

                    Text(
                      '${tr(
                        'Could not load support requests',
                        'មិនអាចផ្ទុកសំណើជំនួយបាន',
                      )}:\n$_error',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextButton.icon(
                      onPressed: _loadTickets,
                      icon: const Icon(Icons.refresh),
                      label: Text(
                        tr(
                          'Try Again',
                          'ព្យាយាមម្តងទៀត',
                        ),
                      ),
                    ),
                  ],
                ),
              )

            // =====================================================
            // EMPTY SUPPORT REQUESTS
            // =====================================================

            else if (_tickets.isEmpty)
              Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 48,
                      color: colors.onSurfaceVariant,
                    ),

                    const SizedBox(height: 12),

                    Text(
                      tr(
                        'You have no support requests yet.',
                        'អ្នកមិនទាន់មានសំណើជំនួយនៅឡើយទេ។',
                      ),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              )

            // =====================================================
            // SUPPORT TICKET LIST
            // =====================================================

            else
              ..._tickets.map(_buildTicket),
          ],
        ),
      ),
    );
  }
}