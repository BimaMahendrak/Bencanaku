import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../controller/loginController.dart';

class ProfileController {
  final TextEditingController namaLengkapController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final String baseUrl = 'https://monitoringweb.decoratics.id/api/bencana/pengguna';

  // Ambil data user untuk edit
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final loginController = LoginController();
      final userData = await loginController.getUserData();
      
      if (userData != null && userData['id'] != null) {
        final response = await http.get(
          Uri.parse('$baseUrl/${userData['id']}'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        );

        print('Get User Data Response: ${response.statusCode}');
        print('Response Body: ${response.body}');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return data; // Langsung return response tanpa 'data' wrapper
        }
      }
      
      return userData; // Fallback ke session data
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Update profile
  Future<bool> updateProfile(BuildContext context, GlobalKey<FormState> formKey, ValueNotifier<bool> isLoading) async {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    isLoading.value = true;

    try {
      final loginController = LoginController();
      final currentUserData = await loginController.getUserData();
      
      if (currentUserData == null || currentUserData['id'] == null) {
        throw Exception('User data not found');
      }

      final userId = currentUserData['id'];
      
      // Prepare request data sesuai dengan validation Laravel
      Map<String, dynamic> requestData = {};

      // Hanya kirim field yang diubah (sesuai dengan 'sometimes' di Laravel)
      if (namaLengkapController.text.isNotEmpty) {
        requestData['nama_lengkap'] = namaLengkapController.text;
      }

      if (usernameController.text.isNotEmpty) {
        requestData['username'] = usernameController.text;
      }

      // Tambahkan password jika diisi
      if (passwordController.text.isNotEmpty) {
        requestData['password'] = passwordController.text;
      }

      print('Update Profile Request Data: $requestData');

      // Update via PUT
      final response = await http.put(
        Uri.parse('$baseUrl/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestData),
      );

      print('Update Profile Response: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final updatedUserData = jsonDecode(response.body);

        // Update session dengan data terbaru
        await loginController.saveLoginSession(
          token: 'updated_token_${DateTime.now().millisecondsSinceEpoch}',
          username: updatedUserData['username'],
          userData: updatedUserData,
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile berhasil diupdate!'),
              backgroundColor: Colors.green,
            ),
          );
        }

        return true;
      } else if (response.statusCode == 422) {
        // Handle Laravel validation errors
        final errorData = jsonDecode(response.body);
        String errorMessage = 'Gagal update profile';
        
        if (errorData['errors'] != null) {
          final errors = errorData['errors'] as Map<String, dynamic>;
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            errorMessage = firstError.first.toString();
          }
        } else if (errorData['message'] != null) {
          errorMessage = errorData['message'];
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }

        return false;
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error ${response.statusCode}: Server error'),
              backgroundColor: Colors.red,
            ),
          );
        }

        return false;
      }
    } catch (e) {
      print('Update Profile Error: $e');
      
      if (context.mounted) {
        String errorMessage = 'Tidak dapat terhubung ke server';
        
        if (e.toString().contains('SocketException')) {
          errorMessage = 'Tidak ada koneksi internet';
        } else if (e.toString().contains('TimeoutException')) {
          errorMessage = 'Koneksi timeout';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Validasi password (minimal 3 karakter sesuai Laravel validation)
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return null; // Password optional
    if (value.length < 3) return 'Password minimal 3 karakter';
    return null;
  }

  // Validasi nama lengkap
  String? validateNamaLengkap(String? value) {
    if (value == null || value.isEmpty) return 'Nama lengkap harus diisi';
    if (value.length < 2) return 'Nama lengkap minimal 2 karakter';
    return null;
  }

  // Validasi username
  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) return 'Username harus diisi';
    if (value.length < 3) return 'Username minimal 3 karakter';
    return null;
  }

  void dispose() {
    namaLengkapController.dispose();
    usernameController.dispose();
    passwordController.dispose();
  }
}