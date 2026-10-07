import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/theme/app_colors.dart';
import '../../../services/alert_service.dart';

import 'package:geocoding/geocoding.dart';

class ActiveAlertScreen extends StatefulWidget {
  const ActiveAlertScreen({
    super.key,
    required this.alert,
    required this.position,
    required this.address,
    required this.recording,
    required this.chunksSent,
    required this.onResolve,
  });

  final Map<String, dynamic> alert;
  final Position? position;
  final String address;
  final bool recording;
  final int chunksSent;
  final VoidCallback onResolve;

  @override
  State<ActiveAlertScreen> createState() => _ActiveAlertScreenState();
}

class _ActiveAlertScreenState extends State<ActiveAlertScreen> {
  // ─── Constants ────────────────────────────────────────────────────────
  static const Duration _locationPushInterval = Duration(seconds: 10);
  static const String _publicBase = 'https://safe-track-1.onrender.com';

  // ─── State ────────────────────────────────────────────────────────────
  Timer? _locationTimer;
  StreamSubscription<Position>? _positionSub;
  Position? _livePosition;
  String _address = '';

  // ─── Lifecycle ────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _livePosition = widget.position;
    _startPositionStream();
    _startLocationPush();
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _locationTimer?.cancel();
    super.dispose();
  }

  Future<void> _updateAddress(Position position) async {
    try {
      final geocoding = Geocoding();
      final placemarks = await geocoding.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty || !mounted) return;

      final place = placemarks.first;

      // Build a clean, non-duplicated address
      final street = place.street ?? '';
      final locality = place.locality ?? '';
      final admin = place.administrativeArea ?? '';
      final country = place.country ?? '';

      // If `street` already contains the locality, just use street.
      final parts = <String>[];
      if (street.isNotEmpty) {
        parts.add(street);
        // Only add locality if it's not already in street
        if (locality.isNotEmpty &&
            !street.toLowerCase().contains(locality.toLowerCase())) {
          parts.add(locality);
        }
      } else {
        if (locality.isNotEmpty) parts.add(locality);
        if (admin.isNotEmpty) parts.add(admin);
        if (country.isNotEmpty) parts.add(country);
      }

      setState(() {
        _address = parts.join(', ');
      });

      debugPrint('📍 ALERT SCREEN ADDRESS: $_address');
    } catch (e) {
      debugPrint('📍 GEOCODING FAILED: $e');
    }
  }

  // ─── Live GPS stream ──────────────────────────────────────────────────
  Future<void> _startPositionStream() async {
    debugPrint('📍 STREAM: entered _startPositionStream');
    try {
      var permission = await Geolocator.checkPermission();
      debugPrint('📍 STREAM: checkPermission → $permission');

      if (permission == LocationPermission.denied) {
        debugPrint('📍 STREAM: requesting permission…');
        permission = await Geolocator.requestPermission();
        debugPrint('📍 STREAM: after request → $permission');
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        debugPrint('📍 STREAM: giving up — denied permanently');
        return;
      }

      debugPrint('📍 STREAM: about to call getPositionStream');

      _positionSub =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 5,
            ),
          ).listen(
            (position) {
              debugPrint(
                '📍 STREAM: got position ${position.latitude}, ${position.longitude}',
              );
              if (!mounted) return;
              setState(() => _livePosition = position);
              _updateAddress(position);
            },
            onError: (e) {
              debugPrint('📍 STREAM: onError → $e');
            },
            onDone: () {
              debugPrint('📍 STREAM: onDone (stream ended)');
            },
            cancelOnError: false,
          );

      debugPrint('📍 STREAM: listener attached');
    } catch (e, stack) {
      debugPrint('📍 STREAM: threw → $e');
      debugPrint('📍 STREAM STACK: $stack');
    }
  }

  // ─── Location push (every 10s) ────────────────────────────────────────
  void _startLocationPush() {
    _locationTimer?.cancel();
    _locationTimer = Timer.periodic(
      _locationPushInterval,
      (_) => _pushLocation(),
    );
    _pushLocation();
  }

  Future<void> _pushLocation() async {
    final pos = _livePosition;
    final id = _alertId;
    if (pos == null || id == null) return;

    try {
      await AlertService.pushLocation(
        alertId: id,
        lat: pos.latitude,
        lng: pos.longitude,
        accuracy: pos.accuracy,
      );
    } catch (e) {
      debugPrint('Location push failed: $e');
    }
  }

  // ─── Resolve ──────────────────────────────────────────────────────────
  Future<void> _handleResolve() async {
    _positionSub?.cancel();
    _locationTimer?.cancel();
    widget.onResolve();

    final id = _alertId;
    if (id == null) return;

    try {
      await AlertService.resolveAlert(id);
    } catch (e) {
      debugPrint('Resolve failed (ignored): $e');
    }
  }

  // ─── Derived values ───────────────────────────────────────────────────
  String? get _alertId {
    final v = widget.alert['_id'] ?? widget.alert['id'];
    return v?.toString();
  }

  String get _trackUrl {
    final token =
        widget.alert['trackToken'] ??
        widget.alert['trackId'] ??
        widget.alert['token'];
    if (token is! String || token.isEmpty) return '$_publicBase/api/track/';
    return '$_publicBase/api/track/$token';
  }

  List<Map<String, dynamic>> get _notifiedContacts {
    final raw = widget.alert['notifiedContacts'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((c) => Map<String, dynamic>.from(c))
        .toList();
  }

  int get _sentCount {
    final delivered = widget.alert['deliveredCount'];
    if (delivered is num) return delivered.toInt();
    return _notifiedContacts
        .where((c) => c['smsStatus'] == 'sent' || c['callStatus'] == 'sent')
        .length;
  }

  int get _totalContacts => _notifiedContacts.length;

  bool get _deliveryFailed {
    if (widget.alert['deliveryFailed'] == true) return true;
    return _totalContacts > 0 && _sentCount == 0;
  }

  Duration get _elapsed {
    final raw = widget.alert['triggeredAt'];
    DateTime started;
    if (raw is String) {
      started = DateTime.tryParse(raw) ?? DateTime.now();
    } else if (raw is DateTime) {
      started = raw;
    } else {
      started = DateTime.now();
    }
    final d = DateTime.now().difference(started);
    return d.isNegative ? Duration.zero : d;
  }

  String _formatDuration(Duration d) {
    final s = d.inSeconds;
    if (s < 60) return '${s}s';
    final m = d.inMinutes;
    if (m < 60) {
      final rem = s % 60;
      return rem == 0 ? '${m}m' : '${m}m ${rem}s';
    }
    final h = d.inHours;
    final rem = m % 60;
    return rem == 0 ? '${h}h' : '${h}h ${rem}m';
  }

  // ─── Build ────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              _emergencyHeader(),
              if (_deliveryFailed) _noContactsBanner(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 12, bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _locationPanel(),
                      const SizedBox(height: 8),
                      _audioStatus(),
                      const SizedBox(height: 20),
                      _sectionLabel('LIVE TRACKING FOR CONTACTS'),
                      _trackingCard(),
                      const SizedBox(height: 20),
                      _sectionLabel(
                        _totalContacts > 0
                            ? 'CONTACTS NOTIFIED · $_sentCount/$_totalContacts SMS SENT'
                            : 'CONTACTS NOTIFIED',
                      ),
                      _contactsCard(),
                    ],
                  ),
                ),
              ),
              _resolveButton(),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────────
  Widget _emergencyHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
      decoration: BoxDecoration(
        color: AppColors.primary,
        border: Border(bottom: BorderSide(color: AppColors.primaryMid)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Row(
                children: [
                  _PulseDot(),
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
              _EverySecond(
                builder: (_) => Text(
                  _formatDuration(_elapsed),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _deliveryFailed
                ? 'Contacts could not be reached by SMS/call. Call emergency services now.'
                : 'Your contacts are being notified. Stay on this screen if you can.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ─── No contacts banner ───────────────────────────────────────────────
  Widget _noContactsBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: RichText(
        text: const TextSpan(
          style: TextStyle(fontSize: 13, color: Color(0xFF7F1D1D)),
          children: [
            TextSpan(
              text: 'No contacts reached. ',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(
              text: 'SafeTrack could not deliver SMS or calls. Call emergency services directly and use the offline SMS button if available.',
            ),
          ],
        ),
      ),
    );
  }

  // ─── Location panel ───────────────────────────────────────────────────
  Widget _locationPanel() {
    final pos = _livePosition;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'LOCATION',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.6,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _address.isNotEmpty
                  ? _address
                  : (pos != null
                        ? 'Coordinates available'
                        : 'Acquiring location…'),
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              pos == null
                  ? 'Waiting for GPS fix…'
                  : '${pos.latitude.toStringAsFixed(5)}, '
                        '${pos.longitude.toStringAsFixed(5)}'
                        ' · ±${pos.accuracy.round()}m',
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            if (pos == null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _deliveryFailed
                      ? 'GPS not available yet. Location will update when a fix arrives.'
                      : 'GPS not available yet. The alert was still sent — location will update when a fix arrives.',
                  style: TextStyle(fontSize: 12, color: Colors.amber.shade900),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─── Audio status ─────────────────────────────────────────────────────
  Widget _audioStatus() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.recording
                    ? AppColors.primary
                    : Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              widget.recording
                  ? 'Recording emergency audio'
                  : 'Audio not recording',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            Text(
              '${widget.chunksSent} clip${widget.chunksSent == 1 ? "" : "s"}',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Section label ────────────────────────────────────────────────────
  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  // ─── Tracking card ────────────────────────────────────────────────────
  Widget _trackingCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Secure tracking link',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              _trackUrl,
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                OutlinedButton(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: _trackUrl));
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tracking link copied.')),
                    );
                  },
                  child: const Text(
                    'Copy link',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Map pin and audio for people who received your alert.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Contacts card ────────────────────────────────────────────────────
  Widget _contactsCard() {
    final contacts = _notifiedContacts;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: contacts.isEmpty
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    'Dispatching alerts to your contacts…',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              )
            : Column(children: [for (final c in contacts) _contactRow(c)]),
      ),
    );
  }

  Widget _contactRow(Map<String, dynamic> c) {
    final smsStatus = '${c['smsStatus'] ?? 'pending'}';
    final callStatus = '${c['callStatus'] ?? 'pending'}';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${c['name'] ?? ''}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${c['phone'] ?? ''}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
          _statusBadge('SMS $smsStatus', smsStatus),
          const SizedBox(width: 4),
          _statusBadge('Call $callStatus', callStatus),
        ],
      ),
    );
  }

  Widget _statusBadge(String label, String status) {
    final Color bg;
    final Color fg;
    switch (status) {
      case 'sent':
        bg = AppColors.primary.withValues(alpha: 0.10);
        fg = AppColors.primary;
        break;
      case 'failed':
        bg = Colors.red.withValues(alpha: 0.10);
        fg = Colors.red;
        break;
      default:
        bg = Colors.amber.withValues(alpha: 0.10);
        fg = Colors.amber.shade800;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: bg,
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }

  // ─── Resolve button ───────────────────────────────────────────────────
  Widget _resolveButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _handleResolve,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            "✓  I'm safe — end emergency",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Helper widgets
// =============================================================================

/// Rebuilds its child every second — used for the elapsed timer.
class _EverySecond extends StatefulWidget {
  const _EverySecond({required this.builder});
  final Widget Function(BuildContext) builder;

  @override
  State<_EverySecond> createState() => _EverySecondState();
}

class _EverySecondState extends State<_EverySecond> {
  Timer? _t;
  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context);
}

/// Simple pulsing white dot.
class _PulseDot extends StatefulWidget {
  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.35, end: 1.0).animate(_c),
      child: Container(
        width: 10,
        height: 10,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
      ),
    );
  }
}
