import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class OfflineSosService {
  static const String _queueKey = 'st_pending_sos';
  static const String _draftKey = 'st_offline_sms_draft';

  /// Google Maps URL for a position — matches React's `mapsUrl()`.
  static String? mapsUrl(Position? p) {
    if (p == null) return null;
    return 'https://maps.google.com/?q=${p.latitude.toStringAsFixed(6)},'
        '${p.longitude.toStringAsFixed(6)}';
  }

  /// Builds the SMS body — mirrors React's `buildOfflineSosText()`.
  static String buildOfflineSosText({
    required String userName,
    required Position? position,
    String? customMessage,
  }) {
    final parts = <String>[];
    parts.add('EMERGENCY: ${userName.isEmpty ? 'I' : userName} need help now.');

    final maps = mapsUrl(position);
    if (maps != null) {
      final acc = position?.accuracy;
      parts.add('Location: $maps${acc != null ? ' (±${acc.round()}m)' : ''}');
    } else {
      parts.add('Location: GPS unavailable — last known position unknown.');
    }

    if (customMessage != null && customMessage.isNotEmpty) {
      parts.add('Note: "$customMessage"');
    }

    final now = DateTime.now();
    final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour < 12 ? 'AM' : 'PM';
    final time = '$hour:$minute $period';
    parts.add('Sent offline from my phone at $time - SafeTrack');

    return parts.join(' ');
  }

  /// Builds the `sms:` URL — mirrors React's `smsHref()`.
  /// iOS uses `,` separator and `&body=`; Android uses `;` and `?body=`.
  static Uri buildSmsUri(List<String> phones, String body) {
    final isIos = Platform.isIOS || Platform.isMacOS;
    final clean = phones
        .map((p) => p.replaceAll(RegExp(r'[^\d+]'), ''))
        .where((p) => p.isNotEmpty)
        .toList();

    final numbers = clean.join(isIos ? ',' : ';');
    final separator = isIos ? '&' : '?';

    return Uri.parse(
      'sms:$numbers$separator${Uri.encodeComponent('body')}='
      '${Uri.encodeComponent(body)}',
    );
  }

  /// Sends the offline SOS via SMS. Returns true if launched, false if no phones.
  static Future<bool> sendOfflineSos({
    required List<Map<String, String>> contacts,
    required String userName,
    required Position? position,
    String? customMessage,
  }) async {
    final phones = contacts
        .map((c) => c['phone'] ?? '')
        .where((p) => p.isNotEmpty)
        .toList();

    if (phones.isEmpty) return false;

    final body = buildOfflineSosText(
      userName: userName,
      position: position,
      customMessage: customMessage,
    );

    // Save draft (mirrors React's saveOfflineSmsDraft)
    await _saveDraft(phones, body);

    // Launch SMS app
    try {
      final uri = buildSmsUri(phones, body);
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      return launched;
    } catch (e) {
      debugPrint('OfflineSosService: failed to launch SMS app → $e');
      return false;
    }
  }

  // ─── Draft (SMS content backup) ─────────────────────────────────────
  static Future<void> _saveDraft(List<String> phones, String body) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _draftKey,
        jsonEncode({
          'phones': phones,
          'body': body,
          'savedAt': DateTime.now().millisecondsSinceEpoch,
        }),
      );
    } catch (_) {}
  }

  static Future<Map<String, dynamic>?> readDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_draftKey);
      if (raw == null) return null;
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_draftKey);
    } catch (_) {}
  }

  // ─── Pending SOS queue ──────────────────────────────────────────────
  static Future<void> queuePendingSos({
    required String triggerType,
    Position? location,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _queueKey,
        jsonEncode({
          'triggerType': triggerType,
          'location': location == null
              ? null
              : {
                  'lat': location.latitude,
                  'lng': location.longitude,
                  'accuracy': location.accuracy,
                },
          'at': DateTime.now().millisecondsSinceEpoch,
        }),
      );
    } catch (_) {}
  }

  static Future<Map<String, dynamic>?> readPendingSos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_queueKey);
      if (raw == null) return null;
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearPendingSos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_queueKey);
    } catch (_) {}
  }
}
