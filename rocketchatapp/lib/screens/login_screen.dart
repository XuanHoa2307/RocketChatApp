import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rocketchatapp/screens/home_screen.dart';
import 'package:rocketchatapp/services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  GoogleSignInAccount? _currentUser;
  final ApiService apiService = ApiService(); // Khởi tạo ApiService

  Future<void> _loginWithGoogle() async {
  try {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: <String>['email', 'https://www.googleapis.com/auth/contacts.readonly'],
    );

    final GoogleSignInAccount? account = await googleSignIn.signIn();

    if (account == null) {
      print('Login canceled by user');
      return;
    }

    setState(() {
      _currentUser = account; // Cập nhật trạng thái người dùng
    });

    // Lấy accessToken từ Google
    final GoogleSignInAuthentication auth = await account.authentication;
    print('AccessToken: ${auth.accessToken}');

    // Gọi API để lấy authToken và userId từ server
    final response = await apiService.loginWithGoogle(auth.accessToken!);
    print('API Response: $response');

    final authToken = response['authToken'];
    final userId = response['userId'];
    final username = response['username'];

    print('Logged in user: ${account.displayName}, ${account.email}');
    print('Navigating to ChatScreen with authToken: $authToken, userId: $userId');

    // Chuyển sang ChatScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(
          authToken: authToken,
          userId: userId,
          username: username ?? 'Unknown',
          email: account.email,
          avatarUrl: account.photoUrl ?? '',
        ),
      ),
    );
  } catch (e) {
    print('Error during Google login: $e');
  }
}

  Future<void> _logoutGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();

      setState(() {
        _currentUser = null;
      });

      print('User logged out');
    } catch (e) {
      print('Error during Google logout: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login with Google'),
        actions: _currentUser != null
            ? [
                CircleAvatar(
                  backgroundImage: NetworkImage(_currentUser!.photoUrl ?? ''),
                  radius: 15,
                ),
                const SizedBox(width: 10),
                Text(_currentUser!.displayName ?? ''),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: _logoutGoogle,
                ),
              ]
            : null,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _loginWithGoogle,
          child: const Text('Login with Google'),
        ),
      ),
    );
  }
}
