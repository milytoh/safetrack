import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';

import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/reg_contacts_screen.dart';
import 'features/auth/screens/reg_profile_screen.dart';
import 'features/auth/screens/splash_screen.dart';
import 'features/auth/screens/reg_permissions_screen.dart';

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
      home: Builder(
        builder: (context) {
          return SplashScreen(
            onLogin: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      LoginScreen(onBack: () => Navigator.of(context).pop()),
                ),
              );
            },

            onRegister: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => RegProfileScreen(
                    onBack: () => Navigator.of(context).pop(),

                    onNext: (data) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => RegContactsScreen(
                            onBack: () => Navigator.of(context).pop(),
                            onNext: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => RegPermissionsScreen(
                                    onBack: () => Navigator.of(context).pop(),
                                    onFinish: () {
                                      // Actual permissions will be handled here next.
                                    },
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
        },
      ),
    );
  }
}
