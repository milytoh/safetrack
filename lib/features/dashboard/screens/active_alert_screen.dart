import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/theme/app_colors.dart';

class ActiveAlertScreen extends StatelessWidget {
  const ActiveAlertScreen({
    super.key,
    required this.alert,
    required this.position,
    required this.elapsed,
    required this.recording,
    required this.chunksSent,
    required this.trackLink,
    required this.onResolve,
  });

  final Map<String, dynamic> alert;
  final Position? position;
  final String elapsed;
  final bool recording;
  final int chunksSent;
  final String trackLink;
  final VoidCallback onResolve;

  @override
  Widget build(BuildContext context) {
    final notifiedContacts = alert['notifiedContacts'] is List
        ? alert['notifiedContacts'] as List
        : <dynamic>[];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ============================================================
            // EMERGENCY ACTIVE HEADER
            // ============================================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
              decoration: BoxDecoration(
                color: AppColors.primary,
                border: Border(bottom: BorderSide(color: AppColors.primaryMid)),
              ),
              child: Row(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'EMERGENCY ACTIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    elapsed,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 16, bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ======================================================
                    // LIVE LOCATION PANEL
                    // ======================================================
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        height: 150,
                        decoration: BoxDecoration(
                          color: AppColors.surface2,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Grid background
                            CustomPaint(
                              painter: _GridPainter(),
                              size: Size.infinite,
                            ),

                            // Center location pin
                            Center(
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primary,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.15,
                                      ),
                                      blurRadius: 0,
                                      spreadRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Location information
                            Positioned(
                              left: 8,
                              right: 8,
                              bottom: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .scaffoldBackgroundColor
                                      .withValues(alpha: 0.92),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      position != null
                                          ? 'Live GPS location'
                                          : 'Locating…',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      position != null
                                          ? '${position!.latitude.toStringAsFixed(5)}, '
                                                '${position!.longitude.toStringAsFixed(5)}'
                                                ' · ±${position!.accuracy.round()}m · live'
                                          : 'Waiting for GPS fix…',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.color
                                            ?.withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ======================================================
                    // AUDIO STATUS
                    // ======================================================
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 11,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: recording
                                    ? AppColors.primary
                                    : Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.color,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              recording
                                  ? 'Recording audio'
                                  : 'Audio recording unavailable',
                              style: const TextStyle(fontSize: 13),
                            ),
                            const Spacer(),
                            Text(
                              '$chunksSent clips uploaded',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // ======================================================
                    // SHARED WITH CONTACTS
                    // ======================================================
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'SHARED WITH YOUR CONTACTS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _InfoCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Live tracking link',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              trackLink.isEmpty
                                  ? 'Tracking link unavailable'
                                  : trackLink,
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.color,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                OutlinedButton(
                                  onPressed: trackLink.isEmpty
                                      ? null
                                      : () async {
                                          await Clipboard.setData(
                                            ClipboardData(text: trackLink),
                                          );

                                          if (!context.mounted) return;

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Tracking link copied.',
                                                  ),
                                                ),
                                              );
                                        },
                                  child: const Text(
                                    'Copy link',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Includes your live GPS pin and audio recordings.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.color,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // ======================================================
                    // CONTACTS NOTIFIED
                    // ======================================================
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'CONTACTS NOTIFIED',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _InfoCard(
                        child: notifiedContacts.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                child: Center(
                                  child: Text(
                                    'Dispatching alerts…',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.color,
                                    ),
                                  ),
                                ),
                              )
                            : Column(
                                children: [
                                  for (
                                    int i = 0;
                                    i < notifiedContacts.length;
                                    i++
                                  )
                                    _ContactItem(
                                      contact: Map<String, dynamic>.from(
                                        notifiedContacts[i] as Map,
                                      ),
                                    ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ============================================================
            // RESOLVE BUTTON
            // ============================================================
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onResolve,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    '✓  I\'m Safe — End Emergency',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: child,
    );
  }
}

class _ContactItem extends StatelessWidget {
  const _ContactItem({required this.contact});

  final Map<String, dynamic> contact;

  @override
  Widget build(BuildContext context) {
    final smsStatus = '${contact['smsStatus'] ?? 'pending'}';
    final callStatus = '${contact['callStatus'] ?? 'pending'}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${contact['name'] ?? ''}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${contact['phone'] ?? ''}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
          _StatusBadge(label: 'SMS $smsStatus', status: smsStatus),
          const SizedBox(width: 4),
          _StatusBadge(label: 'Call $callStatus', status: callStatus),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.status});

  final String label;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: status == 'failed'
            ? Colors.red.withValues(alpha: 0.10)
            : status == 'sent'
            ? AppColors.primary.withValues(alpha: 0.10)
            : Colors.amber.withValues(alpha: 0.10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: status == 'failed'
              ? Colors.red
              : status == 'sent'
              ? AppColors.primary
              : Colors.amber.shade800,
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.05)
      ..strokeWidth = 1;

    const spacing = 24.0;

    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
