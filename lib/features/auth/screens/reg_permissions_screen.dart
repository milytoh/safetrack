import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../widgets/auth_shell.dart';
import '../widgets/screen.dart';

class RegPermissionsScreen extends StatefulWidget {
  const RegPermissionsScreen({
    super.key,
    required this.onBack,
    required this.onFinish,
    this.busy = false,
  });

  final VoidCallback onBack;
  final VoidCallback onFinish;
  final bool busy;

  @override
  State<RegPermissionsScreen> createState() => _RegPermissionsScreenState();
}

class _RegPermissionsScreenState extends State<RegPermissionsScreen> {
  String _locStatus = 'Not granted';
  String _micStatus = 'Not granted';

  bool _requesting = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final locationStatus = await Permission.location.status;
    final microphoneStatus = await Permission.microphone.status;

    if (!mounted) return;

    setState(() {
      _locStatus = _statusText(locationStatus);
      _micStatus = _statusText(microphoneStatus);
    });
  }

  String _statusText(PermissionStatus status) {
    if (status.isGranted) {
      return 'Granted';
    }

    if (status.isPermanentlyDenied) {
      return 'Denied';
    }

    return 'Not granted';
  }

  Future<void> _grantPermissions() async {
    setState(() {
      _requesting = true;
    });

    final locationStatus = await Permission.location.request();

    if (!mounted) return;

    setState(() {
      _locStatus = _statusText(locationStatus);
    });

    final microphoneStatus = await Permission.microphone.request();

    if (!mounted) return;

    setState(() {
      _micStatus = _statusText(microphoneStatus);
      _requesting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      child: AppScreen(
        child: Column(
          children: [
            _TopBar(onBack: widget.onBack),

            const _Steps(),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'App permissions',
                    style: AppTextStyles.headingSmall.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'SafeTrack will ask your phone for these now. '
                    'You\'ll see native prompts — please tap Allow.',
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            _PermissionCard(locStatus: _locStatus, micStatus: _micStatus),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'SMS and voice calls to your contacts are sent from our '
                  'server, not your phone — no extra permission needed for '
                  'that part.',
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ),
            ),

            const Spacer(),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: widget.busy || _requesting
                      ? null
                      : _grantPermissions,
                  child: _requesting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primaryForeground,
                          ),
                        )
                      : const Text('Grant Permissions & Finish'),
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
  const _TopBar({required this.onBack});

  final VoidCallback onBack;

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
              child: OutlinedButton(
                onPressed: onBack,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text('← Back', style: AppTextStyles.caption),
              ),
            ),
          ),

          const Expanded(
            child: Center(
              child: Text('Permissions', style: AppTextStyles.navTitle),
            ),
          ),

          const SizedBox(
            width: 64,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text('3 of 3', style: AppTextStyles.caption),
            ),
          ),
        ],
      ),
    );
  }
}

class _Steps extends StatelessWidget {
  const _Steps();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _stepBar(AppColors.secondary),
          const SizedBox(width: 6),
          _stepBar(AppColors.secondary),
          const SizedBox(width: 6),
          _stepBar(AppColors.primary),
        ],
      ),
    );
  }

  Widget _stepBar(Color color) {
    return Container(
      width: 28,
      height: 4,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  const _PermissionCard({required this.locStatus, required this.micStatus});

  final String locStatus;
  final String micStatus;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _PermissionRow(
            icon: Icons.location_on_outlined,
            title: 'Location',
            subtitle: 'Real-time GPS during SOS',
            status: locStatus,
          ),
          _PermissionRow(
            icon: Icons.mic_none_outlined,
            title: 'Microphone',
            subtitle: 'Audio recording during emergency',
            status: micStatus,
            showDivider: false,
          ),
        ],
      ),
    );
  }
}

class _PermissionRow extends StatelessWidget {
  const _PermissionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.status,
    this.showDivider = true,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String status;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final bool denied = status == 'Denied';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(bottom: BorderSide(color: AppColors.border))
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: AppColors.tealSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: AppColors.tealDeep),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyMedium),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),

          _StatusBadge(text: status, denied: denied),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.text, required this.denied});

  final String text;
  final bool denied;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: denied ? AppColors.primarySoft : AppColors.tealSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: denied ? AppColors.primary : AppColors.tealDeep,
        ),
      ),
    );
  }
}
