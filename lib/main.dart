import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/reg_contacts_screen.dart';
import 'features/auth/screens/reg_profile_screen.dart';
import 'features/auth/screens/reg_permissions_screen.dart';
import 'features/auth/screens/splash_screen.dart';
import 'features/auth/services/auth_service.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'core/api/api_client.dart';

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

  Future<void> _handleLogin(String phone, String password) async {
    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final res = await AuthService.login(phone: phone, password: password);

      final contactsRes = await ApiClient.request('/contacts');

      final contacts = contactsRes['contacts'] is List
          ? (contactsRes['contacts'] as List)
                .map<Map<String, String>>(
                  (contact) => {
                    'name': '${contact['name'] ?? ''}',
                    'phone': '${contact['phone'] ?? ''}',
                    'relationship': '${contact['relationship'] ?? ''}',
                  },
                )
                .toList()
          : <Map<String, String>>[];

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => DashboardScreen(
            contacts: contacts,
            onSettings: () {
              debugPrint('Settings clicked');
            },
            onHistory: () {
              debugPrint('History clicked');
            },
            onLogout: () async {
              await AuthService.logout();

              if (!mounted) return;

              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) =>
                      SplashScreen(onLogin: () {}, onRegister: () {}),
                ),
                (route) => false,
              );
            },
            onTriggerSOS: (triggerType) {
              debugPrint('SOS TRIGGERED');
            },
            onOfflineSms: () {
              debugPrint('Offline SMS clicked');
            },
            onStartCheckin: (seconds) {
              debugPrint('Check-in started: $seconds seconds');
            },
          ),
        ),
      );
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
    if (_profileData == null || _contactsData == null) {
      return;
    }

    setState(() {
      _busy = true;
    });

    try {
      final res = await AuthService.register(
        profile: _profileData!,
        contacts: _contactsData!,
      );

      if (!mounted) return;

      debugPrint('REGISTER RESPONSE: $res');

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => DashboardScreen(
            contacts: _contactsData!,
            onSettings: () {
              debugPrint('Settings clicked');
            },
            onHistory: () {
              debugPrint('History clicked');
            },
            onLogout: () async {
              await AuthService.logout();

              if (!mounted) return;

              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) =>
                      SplashScreen(onLogin: () {}, onRegister: () {}),
                ),
                (route) => false,
              );
            },
            onTriggerSOS: (triggerType) {
              debugPrint('SOS triggered');
            },
            onStartCheckin: (seconds) {
              debugPrint('Check-in started: $seconds seconds');
            },
            onOfflineSms: () {
              debugPrint('Offline SMS clicked');
            },
          ),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('REGISTRATION FAILED: $e')));

      debugPrint('REGISTER ERROR: $e');
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
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
