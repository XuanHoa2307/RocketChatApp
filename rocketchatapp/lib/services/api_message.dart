import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiServiceMessage {
  final String baseUrl = 'http://10.10.10.20:3000/api/v1';
  //final String baseUrl = 'https://open.rocket.chat/api/v1';


  

  Future<List<dynamic>> getMessagesWithAuth(
    String authToken, String userId, String roomId, int offset) async {
  final response = await http.get(
    Uri.parse('$baseUrl/channels.messages?roomId=$roomId&count=100&offset=$offset'),
    headers: {
      'X-Auth-Token': authToken,
      'X-User-Id': userId,
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['messages'];
  } else {
    throw Exception('Failed to fetch messages');
  }
}


  Future<void> sendMessageWithAuth(String authToken, String userId, String roomId, String text) async {
    final response = await http.post(
      Uri.parse('$baseUrl/chat.sendMessage'),
      headers: {
        'Content-Type': 'application/json',
        'X-Auth-Token': authToken,
        'X-User-Id': userId,
      },
      body: jsonEncode({
        'message': {'rid': roomId, 'msg': text},
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to send message');
    }
  }


  Future<List<dynamic>> syncMessages({
  required String authToken,
  required String userId,
  required String roomId,
  required String lastUpdate,
  int offset = 0,
  int count = 50,
  }) async {
    final Uri url = Uri.parse('$baseUrl/chat.syncMessages').replace(queryParameters: {
      'roomId': roomId,
      'offset': offset.toString(),
      'count': count.toString(),
      'lastUpdate': lastUpdate,
    });

    final headers = {
      'X-Auth-Token': authToken,
      'X-User-Id': userId,
      'Content-Type': 'application/json',
    };

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['result']['updated']; // Trả về danh sách tin nhắn mới
    } else {
      throw Exception('Failed to sync messages: ${response.body}');
    }
  }

}