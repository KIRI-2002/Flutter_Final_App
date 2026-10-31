import 'package:flutter/material.dart';
import 'package:y3s1_final/customer/main_customer.dart';
import 'package:y3s1_final/services/commerce_api.dart';

const _primary = Color.fromARGB(255, 30, 37, 87);
const _ink = Color(0xFF1F2430);
const _muted = Color(0xFF6B7280);
const _fieldBg = Color(0xFFF4F5F7);

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;
  bool _agree = false;
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_agree) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the Terms and Conditions')),
      );
      return;
    }

    if (_loading) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _loading = true;
    });

    try {
      await CommerceApi.instance.register(
        name: _nameCtrl.text,
        email: _emailCtrl.text,
        phone: _phoneCtrl.text,
        password: _passCtrl.text,
        passwordConfirmation: _confirmCtrl.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully! Please sign in.'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainCustomer()),
        (route) => false,
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration failed: $error'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _primary,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ---------- Header ----------
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 28, 24),
              child: Row(
                children: [
                  SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Create account',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Join us and start shopping',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // ---------- White card ----------
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _field(
                          controller: _nameCtrl,
                          label: 'Full name',
                          icon: Icons.person_outline_rounded,
                          validator:
                              (v) =>
                                  (v == null || v.trim().isEmpty)
                                      ? 'Enter your name'
                                      : null,
                        ),
                        const SizedBox(height: 14),
                        _field(
                          controller: _emailCtrl,
                          label: 'Email',
                          icon: Icons.mail_outline_rounded,
                          type: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Enter your email';
                            }
                            if (!RegExp(
                              r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                            ).hasMatch(v.trim())) {
                              return 'Invalid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        _field(
                          controller: _phoneCtrl,
                          label: 'Phone number',
                          icon: Icons.phone_outlined,
                          type: TextInputType.phone,
                          validator:
                              (v) =>
                                  (v == null || v.trim().length < 8)
                                      ? 'Invalid phone number'
                                      : null,
                        ),
                        const SizedBox(height: 14),
                        _field(
                          controller: _passCtrl,
                          label: 'Password',
                          icon: Icons.lock_outline_rounded,
                          obscure: _obscure,
                          suffix: IconButton(
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: _muted,
                              size: 20,
                            ),
                            onPressed:
                                () => setState(() => _obscure = !_obscure),
                          ),
                          validator:
                              (v) =>
                                  (v == null || v.length < 6)
                                      ? 'At least 6 characters'
                                      : null,
                        ),
                        const SizedBox(height: 14),
                        _field(
                          controller: _confirmCtrl,
                          label: 'Confirm password',
                          icon: Icons.verified_user_outlined,
                          obscure: _obscure,
                          action: TextInputAction.done,
                          validator:
                              (v) =>
                                  v != _passCtrl.text
                                      ? 'Passwords do not match'
                                      : null,
                        ),
                        const SizedBox(height: 8),

                        // Terms
                        Row(
                          children: [
                            Checkbox(
                              value: _agree,
                              activeColor: _primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              onChanged:
                                  (v) => setState(() => _agree = v ?? false),
                            ),
                            const Expanded(
                              child: Text.rich(
                                TextSpan(
                                  text: 'I agree to the ',
                                  style: TextStyle(color: _muted, fontSize: 13),
                                  children: [
                                    TextSpan(
                                      text: 'Terms and Conditions',
                                      style: TextStyle(
                                        color: _primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Register button
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primary,
                              disabledBackgroundColor: _primary.withValues(
                                alpha: 0.6,
                              ),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child:
                                _loading
                                    ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                    : const Text(
                                      'Create account',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Switch to sign in
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Already have an account?',
                              style: TextStyle(color: _muted, fontSize: 14),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () => Navigator.maybePop(context),
                              child: Text(
                                'Sign in',
                                style: TextStyle(
                                  color: _primary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType type = TextInputType.text,
    TextInputAction action = TextInputAction.next,
    bool obscure = false,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: c, width: w),
    );
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: type,
      textInputAction: action,
      validator: validator,
      style: const TextStyle(color: _ink, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _muted),
        prefixIcon: Icon(icon, color: _muted, size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: _fieldBg,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),
        border: border(Colors.transparent),
        enabledBorder: border(Colors.transparent),
        focusedBorder: border(_primary, 1.5),
        errorBorder: border(Colors.redAccent),
        focusedErrorBorder: border(Colors.redAccent, 1.5),
      ),
    );
  }
}
