import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'https://open.rocket.chat/api/v1';
  //final String authToken = 'I-CWAM7P7MjFQsmsUfIRiyFl028gtspPxNnbuZWE2_P';
  //final String userId = 'SjEJmXKKHydjLtAH7';

  
  Future<Map<String, dynamic>> loginWithGoogle(String accessToken) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'serviceName': 'google',
        'accessToken': accessToken, 
        "idToken": "",
        'expiresIn': 200,
        'scope': 'https://www.googleapis.com/auth/contacts.readonly',
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'authToken': data['data']['authToken'],
        'userId': data['data']['userId'],
        'username': data['data']['me']['username'],
      };
    } else {
      throw Exception('Failed to login with Google');
    }
  }

  Future<List<dynamic>> getMessagesWithAuth(String authToken, String userId, String roomId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/channels.messages?roomId=$roomId&count=200'),
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

  Future<List<dynamic>> fetchRooms(String authToken, String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/rooms.get'),
      headers: {
        'X-Auth-Token': authToken,
        'X-User-Id': userId,
      },
    );

    print('Status Code: ${response.statusCode}');
    print('Response Headers: ${response.headers}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['update']; // Trả về danh sách các phòng
    } else {
      throw Exception('Failed to fetch rooms');
    }
  }



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
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['channel']; // Trả về thông tin channel
    } else {
      throw Exception('Failed to create channel');
    }
  }

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

/*
Future<bool> isUserJoinedChannel(String authToken, String userId, String roomId) async {
  final response = await http.get(
    Uri.parse('$baseUrl/channels.list.joined'),
    headers: {
      'X-Auth-Token': authToken,
      'X-User-Id': userId,
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final channels = data['channels'] as List<dynamic>;
    return channels.any((channel) => channel['_id'] == roomId);
  } else {
    throw Exception('Failed to fetch joined channels');
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

  if (response.statusCode != 200) {
    throw Exception('Failed to join channel');
  }
}
*/

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
