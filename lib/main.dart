import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import "core/storage/token_storage.dart";
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/reg_contacts_screen.dart';
import 'features/auth/screens/reg_profile_screen.dart';
import 'features/auth/screens/reg_permissions_screen.dart';
import 'features/auth/screens/splash_screen.dart';
import 'features/auth/services/auth_service.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/dashboard/screens/active_alert_screen.dart';
import 'services/alert_service.dart';
import 'services/offline_sos_service.dart';
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
      home: const _StartupGate(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Startup gate — decides where to route the user on app launch.
// If a token exists and there's an active alert, go straight to it.
// ─────────────────────────────────────────────────────────────────────────
class _StartupGate extends StatefulWidget {
  const _StartupGate();

  @override
  State<_StartupGate> createState() => _StartupGateState();
}


class _StartupGateState extends State<_StartupGate> {
  bool _checking = true;
  Map<String, dynamic>? _activeAlert;
  List<Map<String, String>> _contacts = [];

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _replayPendingSosIfAny() async {
    final pending = await OfflineSosService.readPendingSos();
    if (pending == null) return;

    final token = await TokenStorage.read();
    if (token == null) return;

    try {
      debugPrint('📍 Replaying queued SOS…');
      await AlertService.triggerSOS(
        triggerType: pending['triggerType'] as String? ?? 'manual_hold',
        location: pending['location'] as Map<String, dynamic>?,
      );
      await OfflineSosService.clearPendingSos();
      debugPrint('📍 Queued SOS replayed successfully.');
    } catch (e) {
      debugPrint('📍 Replay failed — will retry later: $e');
    }
  }

  Future<void> _check() async {
    try {
      final token = await TokenStorage.read();
      if (token == null) {
        // Not logged in — AuthFlow will show splash/login.
        if (mounted) setState(() => _checking = false);
        return;
      }

      // Fetch contacts so we can hand them to the alert screen's callbacks.
      final contactsRes = await ApiClient.request('/contacts')
          .catchError((_) => <String, dynamic>{'contacts': []});
      final contacts = contactsRes['contacts'] is List
          ? (contactsRes['contacts'] as List)
                .map<Map<String, String>>(
                  (c) => {
                    'name': '${c['name'] ?? ''}',
                    'phone': '${c['phone'] ?? ''}',
                    'relationship': '${c['relationship'] ?? ''}',
                  },
                )
                .toList()
          : <Map<String, String>>[];

      // Fetch any active alert.
      final res = await AlertService.fetchActiveAlert().catchError(
        (_) => <String, dynamic>{'alert': null},
      );
      final alert = res['alert'];

      if (alert is Map && _isRecent(alert)) {
        if (mounted) {
          setState(() {
            _activeAlert = Map<String, dynamic>.from(alert);
            _contacts = contacts;
            _checking = false;
          });
        }
        return;
      }
      await _replayPendingSosIfAny();
      if (mounted) {
        setState(() {
          _contacts = contacts;
          _checking = false;
        });
      }
    } catch (e) {
      debugPrint('Startup alert check failed: $e');
      if (mounted) setState(() => _checking = false);
    }
  }

  /// Alert triggered within the last 12 hours → still relevant (matches React).
  bool _isRecent(Map alert) {
    final raw = alert['triggeredAt'];
    if (raw is! String) return false;
    final started = DateTime.tryParse(raw);
    if (started == null) return false;
    return DateTime.now().difference(started).inHours < 12;
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Active alert → jump straight to the alert screen.
    if (_activeAlert != null) {
      return ActiveAlertScreen(
        alert: _activeAlert!,
        position: null,
        address: '',
        recording: false,
        chunksSent: 0,
        onResolve: () {
          // Return to the dashboard after resolve.
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => _buildDashboard(context, _contacts),
            ),
          );
        },
      );
    }

    // No active alert → normal auth flow (splash/login).
    // We route through AuthFlow but seed it with the fetched contacts so the
    // login path doesn't need to re-fetch them.
    return AuthFlow(initialContacts: _contacts);
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Auth flow — unchanged, except it now accepts initial contacts.
// ─────────────────────────────────────────────────────────────────────────
class AuthFlow extends StatefulWidget {
  const AuthFlow({super.key, this.initialContacts});

  final List<Map<String, String>>? initialContacts;

  @override
  State<AuthFlow> createState() => _AuthFlowState();
}

class _AuthFlowState extends State<AuthFlow> {
  Map<String, String>? _profileData;
  List<Map<String, String>>? _contactsData;

  bool _busy = false;
  String? _error;

  Future<void> _handleLogin(String phone, String password) async {
    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      await AuthService.login(phone: phone, password: password);

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
        MaterialPageRoute(builder: (_) => _buildDashboard(context, contacts)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('LOGIN FAILED: $e')));
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _finishRegistration() async {
    if (_profileData == null || _contactsData == null) return;

    setState(() => _busy = true);

    try {
      final res = await AuthService.register(
        profile: _profileData!,
        contacts: _contactsData!,
      );

      if (!mounted) return;
      debugPrint('REGISTER RESPONSE: $res');

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => _buildDashboard(context, _contactsData!),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('REGISTRATION FAILED: $e')));
      debugPrint('REGISTER ERROR: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
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

// ─────────────────────────────────────────────────────────────────────────
// Shared dashboard builder — avoids copy-paste between login & register.
// ─────────────────────────────────────────────────────────────────────────
Widget _buildDashboard(
  BuildContext context,
  List<Map<String, String>> contacts,
) {
  return DashboardScreen(
    contacts: contacts,
    onSettings: () => debugPrint('Settings clicked'),
    onHistory: () => debugPrint('History clicked'),
    onLogout: () async {
      await AuthService.logout();
      if (!context.mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SafeTrackApp()),
        (route) => false,
      );
    },
    onTriggerSOS: (triggerType) {
      debugPrint('SOS triggered: $triggerType');
    },
    onOfflineSms: () => debugPrint('Offline SMS clicked'),
    onStartCheckin: (seconds) {
      debugPrint('Check-in started: $seconds seconds');
    },
  );
}
