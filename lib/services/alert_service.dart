import '../core/api/api_client.dart';

class AlertService {
  /// Trigger an SOS. Returns `{ alert: {...}, delivery: {...} }`.
  static Future<Map<String, dynamic>> triggerSOS({
    required String triggerType,
    Map<String, dynamic>? location,
  }) async {
    final body = <String, dynamic>{'triggerType': triggerType};
    if (location != null) body['location'] = location;

    return await ApiClient.request(
      '/alerts/trigger',
      method: 'POST',
      body: body,
    );
  }

  /// Push the current GPS fix to the backend (called every 10s during an alert).
  static Future<void> pushLocation({
    required String alertId,
    required double lat,
    required double lng,
    double? accuracy,
  }) async {
    await ApiClient.request(
      '/alerts/$alertId/location',
      method: 'POST',
      body: {
        'lat': lat,
        'lng': lng,
        if (accuracy != null) 'accuracy': accuracy,
      },
    );
  }

  /// End the emergency. Returns `{ alert: {...} }`.
  static Future<Map<String, dynamic>> resolveAlert(String alertId) async {
    return await ApiClient.request(
      '/alerts/$alertId/resolve',
      method: 'POST',
      body: const {},
    );
  }

  /// Fetch any alert that's still active (called on app start).
  static Future<Map<String, dynamic>> fetchActiveAlert() async {
    return await ApiClient.request('/alerts/active');
  }

  // ─── NOTE ─────────────────────────────────────────────────────────────
  // Audio upload (`POST /upload/audio/:alertId`) is multipart, so it needs
  // a separate helper on ApiClient that supports form-data. Add that when
  // you wire up audio recording.
  // ──────────────────────────────────────────────────────────────────────
}
