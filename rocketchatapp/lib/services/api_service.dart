import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'http://10.10.10.20:3000/api/v1';
  //final String authToken = 'I-CWAM7P7MjFQsmsUfIRiyFl028gtspPxNnbuZWE2_P';
  //final String userId = 'SjEJmXKKHydjLtAH7';

  
  Future<Map<String, dynamic>> loginWithUsernamePassword(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
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
      throw Exception('Failed to login with username and password');
    }
  }


  Future<Map<String, dynamic>> logOut(String authToken, String userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: {
        'X-Auth-Token': authToken,
        'X-User-Id': userId,
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to logout');
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



/*Future<List<dynamic>> getListChannels(String authToken, String userId) async {
    final url = Uri.parse('$baseUrl/api/v1/channels.list'); // Endpoint API

    try {
      final response = await http.get(
        url,
        headers: {
          'X-Auth-Token': authToken, // Token xác thực
          'X-User-Id': userId,       // ID người dùng
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body); // Decode JSON response
        return data['channels']; // Trả về danh sách các channel
      } else {
        print('Failed to fetch channels: ${response.statusCode}');
        throw Exception('Failed to fetch channels');
      }
    } catch (e) {
      print('Error fetching channels: $e');
      rethrow;
    }
  }*/

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

    Future<void> addPermissions(
    String authToken,
    String userId,
    List<Map<String, dynamic>> permissions,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/permissions.update'),
      headers: {
        'Content-Type': 'application/json',
        'X-Auth-Token': authToken,
        'X-User-Id': userId,
      },
      body: jsonEncode({
        'permissions': permissions, // Danh sách quyền muốn thêm
      }),
    );

    if (response.statusCode == 200) {
      print('Successfully updated permissions!');
    } else {
      print('Error Response: ${response.body}');
      throw Exception('Failed to update permissions');
    }
  }




}
