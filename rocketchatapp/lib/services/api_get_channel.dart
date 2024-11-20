import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiServiceGetChannel {
  final String baseUrl = 'http://10.10.10.20:3000/api/v1';
  //final String baseUrl = 'https://open.rocket.chat/api/v1';

  Future<List<dynamic>> fetchChannels(String authToken, String userId) async {
      final response = await http.get(
        Uri.parse('$baseUrl/channels.list'),
        headers: {
          'X-Auth-Token': authToken,
          'X-User-Id': userId,
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['channels']; // Danh sách channels
      } else {
        throw Exception('Failed to fetch channels');
      }
    }

    Future<Map<String, dynamic>> getChannelInformation(
      String authToken, String userId, String channelId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/channels.info?roomId=$channelId'),
      headers: {
        'X-Auth-Token': authToken,
        'X-User-Id': userId,
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['channel'];
    } else {
      throw Exception('Failed to fetch channel information');
    }
  }


    Future<Map<String, dynamic>> getListChannels(String authToken, String userId) async {
    final url = Uri.parse('$baseUrl/channels.list'); // Thay URL API thực tế
    final headers = {
      'X-Auth-Token': authToken,
      'X-User-Id': userId,
      'Content-Type': 'application/json',
    };

    final response = await http.get(url, headers: headers); // Gửi request GET
    if (response.statusCode == 200) {
      return json.decode(response.body); // Trả về dữ liệu JSON
    } else {
      throw Exception('Failed to fetch channels');
    }
  }


  Future<List<dynamic>> getJoinedChannels(String authToken, String userId) async {
      final response = await http.get(
        Uri.parse('$baseUrl/channels.list.joined'),
        headers: {
          'X-Auth-Token': authToken,
          'X-User-Id': userId,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['channels'] ?? [];
      } else {
        throw Exception('Failed to fetch joined channels');
      }
    }

}