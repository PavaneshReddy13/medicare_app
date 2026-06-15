import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

final smsServiceProvider = Provider<SmsService>((ref) => SmsService());

class SmsService {
  final String _twilioAccountSid = 'mock_sid';
  final String _twilioAuthToken = 'mock_token';
  final String _twilioFromNumber = '+1234567890';

  Future<void> sendSMS(String phone, String message) async {
    final url = Uri.parse('https://api.twilio.com/2010-04-01/Accounts/$_twilioAccountSid/Messages.json');
    
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Basic ${base64Encode(utf8.encode('$_twilioAccountSid:$_twilioAuthToken'))}',
      },
      body: {
        'From': _twilioFromNumber,
        'To': phone,
        'Body': message,
      },
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to send SMS fallback protocol via Twilio pipeline: ${response.body}');
    }
  }
}
