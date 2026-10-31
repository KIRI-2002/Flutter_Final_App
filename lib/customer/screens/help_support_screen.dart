import 'package:flutter/material.dart';
import 'package:y3s1_final/services/commerce_api.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  static const Color purple = Color(0xFF6C4DD3);

  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  List<Map<String, dynamic>> _tickets = [];
  bool _loading = true;
  bool _sending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadTickets() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final tickets =
          await CommerceApi.instance.customerSupportTickets();

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

  Future<void> _sendMessage() async {
    if (!_formKey.currentState!.validate() || _sending) return;

    setState(() {
      _sending = true;
    });

    try {
      await CommerceApi.instance.createSupportTicket(
        subject: _subjectController.text.trim(),
        message: _messageController.text.trim(),
      );

      if (!mounted) return;

      _subjectController.clear();
      _messageController.clear();

      FocusScope.of(context).unfocus();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Support request sent successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      await _loadTickets();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to send request: $error'),
          backgroundColor: Colors.red,
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

  Widget _faqItem(String question, String answer) {
    return Card(
      color: Colors.white,
      elevation: 0,
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(answer),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ticketCard(Map<String, dynamic> ticket) {
    final status = ticket['status']?.toString() ?? 'open';
    final reply = ticket['admin_reply']?.toString();

    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ticket['subject']?.toString() ?? 'Support Request',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 6),
            Text(ticket['message']?.toString() ?? ''),
            const SizedBox(height: 10),
            Text(
              'Status: ${status.toUpperCase()}',
              style: const TextStyle(
                color: purple,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (reply != null && reply.isNotEmpty) ...[
              const Divider(height: 24),
              const Text(
                'Support Reply',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(reply),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FB),
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF201B3D),
      ),
      body: RefreshIndicator(
        onRefresh: _loadTickets,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _faqItem(
              'How do I place an order?',
              'Add products to your cart, open Checkout, '
                  'select your shipping address, and confirm your order.',
            ),
            _faqItem(
              'How can I track my order?',
              'Open My Orders to see the current order status.',
            ),
            _faqItem(
              'How can I pay?',
              'Cash on Delivery is currently supported. '
                  'Pay when your order arrives.',
            ),
            _faqItem(
              'How can I change my shipping address?',
              'Open Shipping Address in your profile to '
                  'manage your saved addresses.',
            ),
            const SizedBox(height: 28),
            const Text(
              'Contact Support',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _subjectController,
                    maxLength: 150,
                    decoration: const InputDecoration(
                      labelText: 'Subject',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a subject';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _messageController,
                    maxLines: 5,
                    maxLength: 5000,
                    decoration: const InputDecoration(
                      labelText: 'Your Message',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your message';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _sending ? null : _sendMessage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                      ),
                      icon: const Icon(Icons.send_outlined),
                      label: Text(
                        _sending ? 'Sending...' : 'Send Message',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'My Support Requests',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_error != null)
              Column(
                children: [
                  Text('Unable to load requests: $_error'),
                  TextButton(
                    onPressed: _loadTickets,
                    child: const Text('Retry'),
                  ),
                ],
              )
            else if (_tickets.isEmpty)
              const Text('You have not sent any support requests yet.')
            else
              ..._tickets.map(_ticketCard),
          ],
        ),
      ),
    );
  }
}