import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiServicePostChannel {
  final String baseUrl = 'http://10.10.10.20:3000/api/v1';
  //final String baseUrl = 'https://open.rocket.chat/api/v1';


Future<Map<String, dynamic>> createChannel(
    String authToken, String userId, String channelName) async {
  final response = await http.post(
    Uri.parse('$baseUrl/channels.create'),
    headers: {
      'Content-Type': 'application/json',
      'X-Auth-Token': authToken,
      'X-User-Id': userId,
    },
    body: jsonEncode({
      'name': channelName,
      'members': [], // Có thể thêm user vào nếu cần
      'readOnly': false,
      'customFields': {'type': 'default'},
      'extraData': {
        'broadcast': false,
        'encrypted': false,
      },
    }),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body)['channel']; // Trả về thông tin channel
  } else {
    print('Error Response: ${response.body}');
    throw Exception('Failed to create channel');
  }
}
  

  Future<void> joinChannel(String authToken, String userId, String roomId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/channels.join'),
      headers: {
        'Content-Type': 'application/json',
        'X-Auth-Token': authToken,
        'X-User-Id': userId,
      },
      body: jsonEncode({
        'roomId': roomId,
      }),
    );

    if (response.statusCode == 200) {
      print('Successfully joined the channel!');
    } else {
      throw Exception('Failed to join channel');
    }
  }


}