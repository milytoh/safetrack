import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class CheckinActiveScreen extends StatefulWidget {
  const CheckinActiveScreen({
    super.key,
    required this.expiresAt,
    required this.onCheckIn,
    required this.onExpire,
  });

  final DateTime expiresAt;
  final VoidCallback onCheckIn;
  final VoidCallback onExpire;

  @override
  State<CheckinActiveScreen> createState() => _CheckinActiveScreenState();
}

class _CheckinActiveScreenState extends State<CheckinActiveScreen> {
  Timer? _timer;

  Duration _remaining = Duration.zero;

  bool _expired = false;

  @override
  void initState() {
    super.initState();

    _updateRemaining();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateRemaining(),
    );
  }

  void _updateRemaining() {
    final remaining = widget.expiresAt.difference(DateTime.now());

    if (remaining <= Duration.zero) {
      _timer?.cancel();

      if (!_expired) {
        _expired = true;

        if (mounted) {
          setState(() {
            _remaining = Duration.zero;
          });
        }

        widget.onExpire();
      }

      return;
    }

    if (!mounted) return;

    setState(() {
      _remaining = remaining;
    });
  }

  String _formatTime() {
    final totalSeconds = _remaining.inSeconds;

    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }

    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Center(
                child: Text(
                  'Check-in Timer Running',
                  style: AppTextStyles.navTitle.copyWith(
                    color: AppColors.tealDeep,
                  ),
                ),
              ),
            ),

            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.teal, width: 3),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _formatTime(),
                              style: AppTextStyles.headingMedium.copyWith(
                                color: AppColors.tealDeep,
                                fontSize: 28,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'REMAINING',
                              style: AppTextStyles.caption.copyWith(
                                fontSize: 10,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      Text(
                        "If you don't check in before this "
                        "reaches zero, SafeTrack will automatically "
                        "send your location, an audio recording, "
                        "and an alert to your contacts.",
                        textAlign: TextAlign.center,
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: widget.onCheckIn,
                  child: const Text("✓ I'm Safe — Check In Now"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
