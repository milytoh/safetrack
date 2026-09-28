import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../widgets/auth_shell.dart';
import '../widgets/screen.dart';

class RegProfileScreen extends StatefulWidget {
  const RegProfileScreen({super.key, this.onBack, this.onNext});

  final VoidCallback? onBack;
  final void Function(Map<String, String> data)? onNext;

  @override
  State<RegProfileScreen> createState() => _RegProfileScreenState();
}

class _RegProfileScreenState extends State<RegProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  String _error = '';

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty) {
      setState(() => _error = 'Enter your full name');
      return;
    }

    if (phone.isEmpty) {
      setState(() => _error = 'Enter your phone number');
      return;
    }

    if (email.isNotEmpty &&
        !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      setState(() {
        _error = 'Enter a valid email address, or leave it blank';
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        _error = 'Password must be at least 6 characters';
      });
      return;
    }

    setState(() => _error = '');

    widget.onNext?.call({
      'name': name,
      'phone': phone,
      'email': email,
      'password': password,
    });
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      child: AppScreen(
        child: Column(
          children: [
            _TopBar(onBack: widget.onBack),

            const _Steps(currentStep: 1),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your profile', style: AppTextStyles.headingSmall),

                    const SizedBox(height: 4),

                    Text(
                      'Used to identify you in alerts',
                      style: AppTextStyles.caption.copyWith(fontSize: 13),
                    ),

                    const SizedBox(height: 24),

                    _Label('Full name'),
                    const SizedBox(height: 7),
                    TextField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Chidi Okafor',
                      ),
                    ),

                    const SizedBox(height: 16),

                    _Label('Phone number'),
                    const SizedBox(height: 7),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        hintText: '+234 801 234 5678',
                      ),
                    ),

                    const SizedBox(height: 16),

                    _Label('Email (optional)'),
                    const SizedBox(height: 7),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: 'you@example.com',
                      ),
                    ),

                    const SizedBox(height: 7),

                    const SizedBox(height: 16),

                    _Label('Password (min 6 characters)'),
                    const SizedBox(height: 7),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 20,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),

                    if (_error.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        _error,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.error,
                          fontSize: 12,
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Continue →'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: onBack,
                child: Text(
                  '← Back',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text('Create Account', style: AppTextStyles.navTitle),
            ),
          ),
          SizedBox(
            width: 64,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                '1 of 3',
                style: AppTextStyles.caption.copyWith(fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Steps extends StatelessWidget {
  const _Steps({required this.currentStep});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          final step = index + 1;

          Color color;

          if (step < currentStep) {
            color = const Color(0xFF00A896);
          } else if (step == currentStep) {
            color = AppColors.primary;
          } else {
            color = AppColors.border;
          }

          return Container(
            width: 28,
            height: 4,
            margin: EdgeInsets.only(right: step == 3 ? 0 : 6),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.label.copyWith(
        fontSize: 12,
        color: AppColors.textSecondary,
      ),
    );
  }
}
