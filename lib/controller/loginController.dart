import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';

class LoginController {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // variables untuk session sementara
  static bool _isLoggedIn = false;
  static String? _username;
  static Map<String, dynamic>? _userData;
  static String? _authToken;
  static DateTime? _loginTime;

  // Session management (in-memory sementara)
  Future<void> saveLoginSession({
    required String token,
    required String username,
    required Map<String, dynamic> userData,
  }) async {
    _isLoggedIn = true;
    _username = username;
    _userData = userData;
    _authToken = token;
    _loginTime = DateTime.now();
    
    print('Session disimpan dalam memori: $_username');
  }

  Future<bool> isLoggedIn() async {
    return _isLoggedIn;
  }

  Future<String?> getAuthToken() async {
    return _authToken;
  }

  Future<String?> getUsername() async {
    return _username;
  }

  Future<Map<String, dynamic>?> getUserData() async {
    return _userData;
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _username = null;
    _userData = null;
    _authToken = null;
    _loginTime = null;
    
    print('Session cleared from memory');
  }

  Future<bool> isSessionValid() async {
    if (_loginTime == null) return false;
    
    final currentTime = DateTime.now();
    final difference = currentTime.difference(_loginTime!).inDays;
    
    // Session berlaku selama 7 hari
    return difference < 7;
  }

  Future<void> handleLogin(BuildContext context, GlobalKey<FormState> formKey, ValueNotifier<bool> isLoading) async {
    if (formKey.currentState!.validate()) {
      isLoading.value = true;

      try {
        // Debug: print request data
        final requestData = {
          'username': usernameController.text,
          'password': passwordController.text,
        };
        
        print('=== DEBUG LOGIN ===');
        print('Request URL: https://monitoringweb.decoratics.id/api/bencana/auth/login');
        print('Request Data: $requestData');
        print('==================');

        // API request dengan timeout
        final response = await http.post(
          Uri.parse('https://monitoringweb.decoratics.id/api/bencana/auth/login'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(requestData),
        ).timeout(
          const Duration(seconds: 30), // Timeout 30 detik
        );

        print('Response Status: ${response.statusCode}');
        print('Response Body: ${response.body}');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          print('Parsed Data: $data');

          // Simpan session login (in-memory)
          await saveLoginSession(
            token: 'token_${DateTime.now().millisecondsSinceEpoch}', // Generate dummy token
            username: usernameController.text,
            userData: data, // Gunakan seluruh response data
          );

          print('Session saved successfully');

          // Login berhasil
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Login berhasil!'),
                backgroundColor: Colors.green,
              ),
            );

            // Clear form
            usernameController.clear();
            passwordController.clear();

            // Navigasi ke halaman utama
            context.go('/home');
          }
        } else if (response.statusCode == 401) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Username atau password salah'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error ${response.statusCode}: ${response.body}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        print('=== LOGIN ERROR ===');
        print('Error Type: ${e.runtimeType}');
        print('Error Message: $e');
        print('==================');
        
        if (context.mounted) {
          String errorMessage = 'Tidak dapat terhubung ke server';
          
          // Lebih spesifik error message
          if (e.toString().contains('TimeoutException')) {
            errorMessage = 'Koneksi timeout, periksa internet Anda';
          } else if (e.toString().contains('SocketException')) {
            errorMessage = 'Tidak ada koneksi internet';
          } else if (e.toString().contains('HandshakeException')) {
            errorMessage = 'Masalah sertifikat SSL';
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } finally {
        isLoading.value = false;
      }
    }
  }

  Future<void> handleLogout(BuildContext context) async {
    try {
      await logout();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logout berhasil!'),
            backgroundColor: Colors.green,
          ),
        );
        
        context.go('/login');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Terjadi kesalahan saat logout'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
  }
}