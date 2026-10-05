import '../core/api/api_client.dart';

class AlertService {
  /// Existing method — unchanged.
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

  /// NEW — fetch current alert state (poll target).
  ///
  /// TODO: confirm endpoint with React parent.
  /// Common patterns: GET /alerts/:id  or  GET /alerts/:id/status
  static Future<Map<String, dynamic>> getAlertStatus(String alertId) async {
    return await ApiClient.request('/alerts/$alertId');
  }

  /// NEW — resolve / end the emergency.
  ///
  /// TODO: confirm endpoint with React parent.
  /// Common patterns: POST /alerts/:id/resolve  or  PATCH /alerts/:id
  static Future<Map<String, dynamic>> resolveAlert(String alertId) async {
    return await ApiClient.request(
      '/alerts/$alertId/resolve',
      method: 'POST',
      body: const {},
    );
  }
}
