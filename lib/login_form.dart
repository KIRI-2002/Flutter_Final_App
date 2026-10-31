import 'package:flutter/material.dart';
import 'package:y3s1_final/register_form.dart';
import 'package:y3s1_final/services/commerce_api.dart';

const _primary = Color.fromARGB(255, 30, 37, 87);
const _ink = Color(0xFF1F2430);
const _muted = Color(0xFF6B7280);
const _fieldBg = Color(0xFFF4F5F7);

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();

  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  bool _obscure = true;
  bool _loggingIn = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_loggingIn) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _loggingIn = true;
    });

    try {
      await CommerceApi.instance.login(_emailCtrl.text.trim(), _passCtrl.text);

      // DEBUG: Check which role Laravel returns.
      debugPrint('LOGIN ROLE: ${CommerceApi.instance.role}');
      debugPrint('LOGIN USER: ${CommerceApi.instance.currentUser}');

      if (!mounted) return;

      final role = CommerceApi.instance.role?.trim().toLowerCase();

      final token = CommerceApi.instance.token;

      if (token == null || token.isEmpty) {
        throw Exception('Login failed: Authentication token is missing.');
      }

      if (role == 'customer') {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/customer',
          (route) => false,
        );
      } else if (role == 'seller') {
        Navigator.pushNamedAndRemoveUntil(context, '/seller', (route) => false);
      } else {
        throw Exception('Unknown account role: $role');
      }
    } catch (e) {
      if (!mounted) return;

      String message = e.toString();

      if (message.startsWith('Exception: ')) {
        message = message.substring(11);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loggingIn = false;
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
            // HEADER
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.shopping_bag_outlined,
                      color: _primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Login account',
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

            // WHITE LOGIN CARD
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
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // EMAIL
                        _field(
                          controller: _emailCtrl,
                          label: 'Email',
                          icon: Icons.mail_outline_rounded,
                          type: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Enter your email';
                            }

                            if (!RegExp(
                              r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                            ).hasMatch(value.trim())) {
                              return 'Invalid email';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // PHONE NUMBER - OPTIONAL
                        _field(
                          controller: _phoneCtrl,
                          label: 'Phone (Optional)',
                          icon: Icons.phone_outlined,
                          type: TextInputType.phone,
                          validator: (value) {
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // PASSWORD
                        _field(
                          controller: _passCtrl,
                          label: 'Password',
                          icon: Icons.lock_outline_rounded,
                          obscure: _obscure,
                          action: TextInputAction.done,
                          suffix: IconButton(
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: _muted,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscure = !_obscure;
                              });
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter your password';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 24),

                        // LOGIN BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _loggingIn ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child:
                                _loggingIn
                                    ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                    : const Text(
                                      'Login',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // TERMS AND CONDITIONS
                        const Text.rich(
                          TextSpan(
                            text: 'By signing up, you agree to our ',
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
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 28),

                        // SIGN UP
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Do not have an account?',
                              style: TextStyle(color: _muted, fontSize: 14),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const RegisterForm(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Sign up',
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

  // REUSABLE INPUT FIELD
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
    OutlineInputBorder border(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color, width: width),
      );
    }

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
          vertical: 18,
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
