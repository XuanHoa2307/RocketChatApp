import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiServiceAuthenticate {
  final String baseUrl = 'http://10.10.10.20:3000/api/v1';
  //final String baseUrl = 'https://open.rocket.chat/api/v1';

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


}