import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../widgets/auth_shell.dart';
import '../widgets/screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key, this.onRegister, this.onLogin});

  final VoidCallback? onRegister;
  final VoidCallback? onLogin;

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      child: AppScreen(
        child: Column(
          children: [
            // ─────────────────────────────────────
            // Main content
            // ─────────────────────────────────────

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 120),

                    // Location icon
                    Container(
                      width: 88,
                      height: 88,
                      decoration: const BoxDecoration(
                        color: AppColors.primarySoft,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.location_on_outlined,
                        size: 44,
                        color: AppColors.primary,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // SafeTrack logo
                    RichText(
                      text: TextSpan(
                        style: AppTextStyles.headingLarge.copyWith(
                          fontSize: 38,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1.5,
                        ),
                        children: const [
                          TextSpan(text: 'Safe'),
                          TextSpan(
                            text: 'Track',
                            style: TextStyle(color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Description
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 280),
                      child: Text(
                        'Hold the SOS button, start a check-in timer, '
                        'or trigger silently — your live GPS, an audio '
                        'recording, and an SMS + voice call go to everyone '
                        'you trust.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 13,
                          height: 1.7,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // ─────────────────────────────────────
            // Bottom actions
            // ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: Column(
                children: [
                  _PrimaryButton(text: 'Create Account', onPressed: onRegister),
                  const SizedBox(height: 12),
                  _GhostButton(text: 'Log In', onPressed: onLogin),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Primary button
// ─────────────────────────────────────────────

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.text, this.onPressed});

  final String text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(onPressed: onPressed, child: Text(text)),
    );
  }
}

// ─────────────────────────────────────────────
// Ghost button
// ─────────────────────────────────────────────

class _GhostButton extends StatelessWidget {
  const _GhostButton({required this.text, this.onPressed});

  final String text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.foreground,
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(text, style: AppTextStyles.bodyBold),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Google button
// ─────────────────────────────────────────────
