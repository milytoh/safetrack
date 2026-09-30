import '../core/api/api_client.dart';

class AlertService {
  static Future<Map<String, dynamic>> triggerSOS({
    required String triggerType,
    Map<String, dynamic>? location,
  }) async {
    final body = <String, dynamic>{'triggerType': triggerType};

    if (location != null) {
      body['location'] = location;
    }

    return await ApiClient.request(
      '/alerts/trigger',
      method: 'POST',
      body: body,
    );
  }
}
