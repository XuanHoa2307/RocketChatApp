import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'http://10.10.10.20:3000/api/v1';
  //final String baseUrl = 'https://open.rocket.chat/api/v1';

  Future<List<dynamic>> fetchRooms(String authToken, String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/rooms.get'),
      headers: {
        'X-Auth-Token': authToken,
        'X-User-Id': userId,
      },
    );

    //print('Status Code: ${response.statusCode}');
    //print('Response Headers: ${response.headers}');
    //print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['update']; // Trả về danh sách các phòng
    } else {
      throw Exception('Failed to fetch rooms');
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


// END
}
