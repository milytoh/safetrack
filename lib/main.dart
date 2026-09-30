import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/reg_contacts_screen.dart';
import 'features/auth/screens/reg_profile_screen.dart';
import 'features/auth/screens/reg_permissions_screen.dart';
import 'features/auth/screens/splash_screen.dart';
import 'features/auth/services/auth_service.dart';

void main() {
  runApp(const SafeTrackApp());
}

class SafeTrackApp extends StatelessWidget {
  const SafeTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SafeTrack',
      theme: AppTheme.light,
      home: const AuthFlow(),
    );
  }
}

class AuthFlow extends StatefulWidget {
  const AuthFlow({super.key});

  @override
  State<AuthFlow> createState() => _AuthFlowState();
}

class _AuthFlowState extends State<AuthFlow> {
  // Temporary data during registration
  Map<String, String>? _profileData;
  List<Map<String, String>>? _contactsData;

  bool _busy = false;
  String? _error;

  // ─────────────────────────────────────────────
  // LOGIN
  // ─────────────────────────────────────────────
  // Future<void> _handleLogin(String phone, String password) async {
  //   setState(() {
  //     _busy = true;
  //     _error = null;
  //   });

  //   try {
  //     print(phone);
  //     final res = await AuthService.login(phone: phone, password: password);

  //     // TODO: Later we will check if user is verified and go to OTP if needed
  //     // For now go to a temporary success screen
  //     if (!mounted) return;

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Welcome back, ${res['user']?['name'] ?? 'User'}'),
  //       ),
  //     );

  //     // Temporary: just show success. We will add Dashboard later.
  //     debugPrint('Login success: $res');
  //   } catch (e) {
  //     setState(() {
  //       _error = e.toString();
  //     });
  //   } finally {
  //     if (mounted) {
  //       setState(() => _busy = false);
  //     }
  //   }
  // }

  Future<void> _handleLogin(String phone, String password) async {
    // ScaffoldMessenger.of(context).showSnackBar(
    //   const SnackBar(
    //     content: Text('Login button is working — calling backend...'),
    //   ),
    // );

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final res = await AuthService.login(phone: phone, password: password);

      if (!mounted) return;

      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(
      //       'Login API successful: ${res['user']?['name'] ?? 'User'}',
      //     ),
      //   ),
      // );

      debugPrint('LOGIN RESPONSE: $res');
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('LOGIN FAILED: $e')));

      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  // ─────────────────────────────────────────────
  // REGISTER
  // ─────────────────────────────────────────────
  Future<void> _finishRegistration() async {
    if (_profileData == null || _contactsData == null) return;

    setState(() => _busy = true);

    try {
      final res = await AuthService.register(
        profile: _profileData!,
        contacts: _contactsData!,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created — check your phone for the OTP code'),
        ),
      );

      debugPrint('Register success: $res');

      // TODO: Navigate to OTP screen next
      // For now just go back to splash
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      onLogin: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => LoginScreen(
              onBack: () => Navigator.of(context).pop(),
              onSubmit: _handleLogin,
              busy: _busy,
              error: _error,
            ),
          ),
        );
      },
      onRegister: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => RegProfileScreen(
              onBack: () => Navigator.of(context).pop(),
              onNext: (data) {
                _profileData = data;

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => RegContactsScreen(
                      onBack: () => Navigator.of(context).pop(),
                      onNext: (contacts) {
                        _contactsData = contacts;

                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => RegPermissionsScreen(
                              onBack: () => Navigator.of(context).pop(),
                              onFinish: _finishRegistration,
                              busy: _busy,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
