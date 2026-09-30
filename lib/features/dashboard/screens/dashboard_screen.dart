import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'checkin_active_screen.dart';

import '../../../services/alert_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.contacts,
    required this.onSettings,
    required this.onHistory,
    required this.onLogout,
    required this.onTriggerSOS,
    required this.onStartCheckin,
    required this.onOfflineSms,
  });

  final List<Map<String, String>> contacts;

  final VoidCallback onSettings;
  final VoidCallback onHistory;
  final VoidCallback onLogout;
  final void Function(String triggerType) onTriggerSOS;
  final VoidCallback onOfflineSms;

  final void Function(int seconds) onStartCheckin;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  int hours = 0;
  int minutes = 1;
  int seconds = 0;

  final TextEditingController _hoursController = TextEditingController(
    text: '0',
  );

  final TextEditingController _minutesController = TextEditingController(
    text: '1',
  );

  final TextEditingController _secondsController = TextEditingController(
    text: '0',
  );

  Future<void> _triggerSOS(String triggerType) async {
    try {
      final location = _currentPosition == null
          ? null
          : {
              'lat': _currentPosition!.latitude,
              'lng': _currentPosition!.longitude,
              'accuracy': _currentPosition!.accuracy,
            };

      debugPrint('Sending SOS...');
      debugPrint('Trigger type: $triggerType');
      debugPrint('Location: $location');

      final res = await AlertService.triggerSOS(
        triggerType: triggerType,
        location: location,
      );

      debugPrint('SOS RESPONSE: $res');
    } catch (e) {
      debugPrint('SOS ERROR: $e');
    }
  }

  Position? _currentPosition;
  bool gpsActive = false;
  bool shakeArmed = true;
  bool silentTapArmed = true;
  bool voiceArmed = true;
  bool offlineSos = false;

  bool _holdingSOS = false;
  double _sosProgress = 0.0;

  Timer? _sosTimer;
  DateTime? _sosPressStart;

  static const int _holdDurationMs = 3000;
  late AnimationController _sosAnimationController;

  void _startCheckin(int totalSeconds) {
    if (totalSeconds <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a check-in duration.')),
      );

      return;
    }

    final expiresAt = DateTime.now().add(Duration(seconds: totalSeconds));

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CheckinActiveScreen(
          expiresAt: expiresAt,
          onCheckIn: () {
            Navigator.of(context).pop();

            debugPrint('User checked in safely');
          },
          onExpire: () {
            // Navigator.of(context).pop();

            debugPrint('CHECK-IN EXPIRED — trigger emergency alert');
          },
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _sosAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        if (!mounted) return;

        setState(() {
          gpsActive = false;
        });

        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!mounted) return;

        setState(() {
          gpsActive = false;
        });

        return;
      }

      final position = await Geolocator.getCurrentPosition();

      if (!mounted) return;

      setState(() {
        _currentPosition = position;
        gpsActive = true;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        gpsActive = false;
      });
    }
  }

  void _startSOSHold() {
    _sosTimer?.cancel();

    _sosPressStart = DateTime.now();

    setState(() {
      _holdingSOS = true;
      _sosProgress = 0.0;
    });

    _sosAnimationController.repeat();

    _sosTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted || _sosPressStart == null) {
        timer.cancel();
        return;
      }

      final elapsed = DateTime.now().difference(_sosPressStart!).inMilliseconds;

      final progress = (elapsed / _holdDurationMs).clamp(0.0, 1.0);

      setState(() {
        _sosProgress = progress;
      });

      if (progress >= 1.0) {
        timer.cancel();
        _sosTimer = null;

        setState(() {
          _holdingSOS = false;
          _sosProgress = 0.0;
        });

        _sosPressStart = null;

        await _triggerSOS('manual_hold');
      }
    });
  }

  void _endSOSHold() {
    if (_sosPressStart == null) return;

    final duration = DateTime.now().difference(_sosPressStart!).inMilliseconds;

    _sosTimer?.cancel();
    _sosTimer = null;
    _sosPressStart = null;

    if (!mounted) return;

    setState(() {
      _holdingSOS = false;
      _sosProgress = 0.0;
    });

    _sosAnimationController.stop();
    _sosAnimationController.reset();

    // Short tap = silent tap trigger
    if (duration > 0 && duration < 300) {
      debugPrint('Silent tap detected');
    }
  }

  void _cancelSOSHold() {
    _sosTimer?.cancel();
    _sosTimer = null;
    _sosPressStart = null;

    if (!mounted) return;

    setState(() {
      _holdingSOS = false;
      _sosProgress = 0.0;
    });

    _sosAnimationController.stop();
    _sosAnimationController.reset();
  }

  @override
  void dispose() {
    _sosTimer?.cancel();

    _hoursController.dispose();
    _minutesController.dispose();
    _secondsController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _statusChips(),
                    if (offlineSos) _offlineSosNotice(),
                    if (offlineSos) _offlineSmsButton(),
                    _sosSection(),

                    _checkinSection(),

                    _statsSection(),

                    _contactsSection(),

                    const SizedBox(height: 8),

                    _bottomActions(),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(
              Icons.shield_outlined,
              size: 20,
              color: AppColors.primary,
            ),
          ),

          const Spacer(),

          Text(
            'SafeTrack',
            style: AppTextStyles.navTitle.copyWith(fontSize: 18),
          ),

          const Spacer(),

          TextButton(
            onPressed: widget.onSettings,
            child: Text(
              'Settings',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChips() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          if (shakeArmed) _chip('📳 Shake-to-activate armed', active: true),

          if (silentTapArmed) _chip('👆 Silent tap armed', active: true),

          if (voiceArmed) _chip('🎙️ Voice activation listening', active: true),
        ],
      ),
    );
  }

  Widget _offlineSosNotice() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primaryMid),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Offline mode — SOS queued for automatic retry',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'SafeTrack saved your alert locally and will retry '
              'automatically as soon as you reconnect.',
              style: AppTextStyles.caption.copyWith(fontSize: 12, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String text, {required bool active}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: active ? AppColors.tealSoft : AppColors.surface2,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          fontSize: 11,
          color: active ? AppColors.tealDeep : AppColors.mutedForeground,
        ),
      ),
    );
  }

  Widget _offlineSmsButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: GestureDetector(
        onTap: widget.onOfflineSms,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Text.rich(
            TextSpan(
              text: 'No internet? ',
              style: AppTextStyles.caption.copyWith(fontSize: 12),
              children: [
                TextSpan(
                  text: 'Text contacts directly',
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.foreground,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sosSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(
        children: [
          Center(
            child: Text(
              'Hold for 3 seconds to send emergency alert',
              style: AppTextStyles.caption.copyWith(fontSize: 12),
            ),
          ),

          const SizedBox(height: 12),

          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (_) => _startSOSHold(),
            onTapUp: (_) => _endSOSHold(),
            onTapCancel: _cancelSOSHold,
            child: Container(
              width: 148,
              height: 148,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primarySoft,
                border: Border.all(color: AppColors.primaryMid, width: 2.5),
              ),
              child: Center(
                child: AnimatedBuilder(
                  animation: _sosAnimationController,
                  builder: (context, child) {
                    final pingScale =
                        1.0 + (_sosAnimationController.value * 0.35);

                    final pingOpacity =
                        1.0 - (_sosAnimationController.value * 0.75);

                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        // Ping animation
                        if (_holdingSOS)
                          Transform.scale(
                            scale: pingScale,
                            child: Container(
                              width: 104,
                              height: 104,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primary.withValues(
                                    alpha: pingOpacity,
                                  ),
                                  width: 3,
                                ),
                              ),
                            ),
                          ),

                        // Original SOS button
                        Container(
                          width: 104,
                          height: 104,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(
                                  alpha: 0.20,
                                ),
                                blurRadius: 18,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'SOS',
                                style: AppTextStyles.headingMedium.copyWith(
                                  color: AppColors.primaryForeground,
                                  fontSize: 28,
                                  letterSpacing: 0,
                                ),
                              ),
                              Text(
                                'HOLD',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.primaryForeground.withValues(
                                    alpha: 0.75,
                                  ),
                                  fontSize: 9,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // SOS hold progress
          AnimatedOpacity(
            opacity: _holdingSOS ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 150),
            child: Container(
              width: 148,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.surface2,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: _sosProgress,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Release to cancel',
            style: AppTextStyles.caption.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _checkinSection() {
    return _sectionCard(
      title: 'Or start a check-in timer',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Doing something risky? Start a timer — if you don\'t '
            'check in before it ends, SafeTrack sends the alert '
            'automatically.',
            style: AppTextStyles.caption.copyWith(fontSize: 12, height: 1.5),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              _timeField('Hours', hours, 23, (value) {
                setState(() => hours = value);
              }, _hoursController),

              const SizedBox(width: 8),

              _timeField('Minutes', minutes, 59, (value) {
                setState(() => minutes = value);
              }, _minutesController),

              const SizedBox(width: 8),

              _timeField('Seconds', seconds, 59, (value) {
                setState(() => seconds = value);
              }, _secondsController),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              _quickTime('1 min', 0, 1, 0),
              const SizedBox(width: 6),
              _quickTime('5 min', 0, 5, 0),
              const SizedBox(width: 6),
              _quickTime('15 min', 0, 15, 0),
              const SizedBox(width: 6),
              _quickTime('1 hr', 1, 0, 0),
            ],
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                final total = hours * 3600 + minutes * 60 + seconds;

                _startCheckin(total);
              },
              child: const Text('Start Check-in Timer'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statsSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface2,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.contacts.length}',
                    style: AppTextStyles.headingMedium.copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Trusted contacts',
                    style: AppTextStyles.caption.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface2,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '●',
                    style: AppTextStyles.headingMedium.copyWith(
                      fontSize: 22,
                      color: gpsActive ? AppColors.teal : AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    gpsActive ? 'GPS active' : 'GPS off',
                    style: AppTextStyles.caption.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactsSection() {
    return _sectionCard(
      title: 'Trusted contacts',
      child: widget.contacts.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text('No contacts yet', style: AppTextStyles.caption),
              ),
            )
          : Column(
              children: widget.contacts.map((contact) {
                final name = contact['name'] ?? 'Unknown';
                final relationship = contact['relationship'] ?? '';
                final phone = contact['phone'] ?? '';

                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppColors.border)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: const BoxDecoration(
                          color: AppColors.tealSoft,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person_outline,
                          size: 19,
                          color: AppColors.tealDeep,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: AppTextStyles.bodyMedium),
                            const SizedBox(height: 3),
                            Text(
                              '$relationship • $phone',
                              style: AppTextStyles.caption.copyWith(
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _bottomActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: widget.onHistory,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Alert history', style: AppTextStyles.bodyMedium),
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: widget.onLogout,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(90, 48),
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Log out',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.bodyBold),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _timeField(
    String label,
    int value,
    int max,
    ValueChanged<int> onChanged,
    TextEditingController controller,
  ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 6),

          TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            ),
            onChanged: (text) {
              final parsed = int.tryParse(text) ?? 0;
              final next = parsed.clamp(0, max);

              onChanged(next);
            },
          ),
        ],
      ),
    );
  }

  Widget _quickTime(String label, int h, int m, int s) {
    return Expanded(
      child: OutlinedButton(
        onPressed: () {
          setState(() {
            hours = h;
            minutes = m;
            seconds = s;

            _hoursController.text = h.toString();
            _minutesController.text = m.toString();
            _secondsController.text = s.toString();
          });
        },
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.foreground,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
