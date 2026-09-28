import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../widgets/auth_shell.dart';
import '../widgets/screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    this.onBack,
    this.onSubmit,
    this.onForgot,
    this.onGoogle,
    this.busy = false,
    this.error,
  });

  final VoidCallback? onBack;
  final void Function(String phone, String password)? onSubmit;
  final VoidCallback? onForgot;
  final VoidCallback? onGoogle;
  final bool busy;
  final String? error;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    widget.onSubmit?.call(
      _phoneController.text.trim(),
      _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      child: AppScreen(
        child: Column(
          children: [
            _LoginNav(onBack: widget.onBack),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel('Phone number'),
                    const SizedBox(height: 7),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        hintText: '+234 801 234 5678',
                      ),
                    ),

                    const SizedBox(height: 16),

                    _FieldLabel('Password'),
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
                            color: AppColors.mutedForeground,
                          ),
                        ),
                      ),
                    ),

                    if (widget.error != null &&
                        widget.error!.trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        widget.error!,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.error,
                          fontSize: 12,
                        ),
                      ),
                    ],

                    const SizedBox(height: 8),

                    TextButton(
                      onPressed: widget.onForgot,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        foregroundColor: AppColors.primary,
                      ),
                      child: const Text(
                        'Forgot password?',
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            _LoginButtons(
              busy: widget.busy,
              onSubmit: _submit,
              onGoogle: widget.onGoogle,
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginNav extends StatelessWidget {
  const _LoginNav({this.onBack});

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
                    color: AppColors.mutedForeground,
                  ),
                ),
              ),
            ),
          ),
          const Expanded(
            child: Center(child: Text('Log In', style: AppTextStyles.navTitle)),
          ),
          const SizedBox(width: 64),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppTextStyles.label);
  }
}

class _LoginButtons extends StatelessWidget {
  const _LoginButtons({
    required this.busy,
    required this.onSubmit,
    this.onGoogle,
  });

  final bool busy;
  final VoidCallback onSubmit;
  final VoidCallback? onGoogle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: busy ? null : onSubmit,
              child: busy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : const Text('Log In'),
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              const Expanded(child: Divider(color: AppColors.border)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'OR CONTINUE WITH',
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const Expanded(child: Divider(color: AppColors.border)),
            ],
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: busy ? null : onGoogle,
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.background,
                foregroundColor: AppColors.foreground,
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Continue with Google',
                style: AppTextStyles.bodyMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
