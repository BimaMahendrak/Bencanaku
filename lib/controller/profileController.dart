import 'dart:convert';
import 'dart:io'; // Untuk file handling
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart'; // Tambahkan dependency image_picker
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
          
          // Update session dengan data terbaru dari server
          await loginController.saveLoginSession(
            token: 'current_token_${DateTime.now().millisecondsSinceEpoch}',
            username: data['username'],
            userData: data,
          );
          
          return data;
        }
      }
      
      return userData; // Fallback ke session data
    } catch (e) {
      print('Error getting user data: $e');
      final loginController = LoginController();
      return await loginController.getUserData(); // Return session data jika error
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

  /// Upload foto ke server
  Future<bool> uploadPhoto(BuildContext context, ValueNotifier<bool> isLoading) async {
    final picker = ImagePicker();

    try {
      // Pilih foto dari galeri
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak ada foto yang dipilih'),
            backgroundColor: Colors.orange,
          ),
        );
        return false;
      }

      isLoading.value = true;

      final loginController = LoginController();
      final currentUserData = await loginController.getUserData();

      if (currentUserData == null || currentUserData['id'] == null) {
        throw Exception('User data tidak ditemukan');
      }

      final userId = currentUserData['id'];
      final file = File(pickedFile.path);

      // Update endpoint sesuai dengan Laravel routes
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://monitoringweb.decoratics.id/api/bencana/pengguna/$userId/upload-photo'), // Update endpoint
      );

      request.files.add(await http.MultipartFile.fromPath('photo', file.path));
      request.headers.addAll({
        'Accept': 'application/json',
        'Content-Type': 'multipart/form-data',
      });

      print('Upload Photo URL: https://monitoringweb.decoratics.id/api/bencana/pengguna/$userId/upload-photo');
      print('File path: ${file.path}');

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('Upload Photo Response: ${response.statusCode}');
      print('Response Body: $responseBody');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(responseBody);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto berhasil diupload'),
            backgroundColor: Colors.green,
          ),
        );

        return true;
      } else {
        final responseData = jsonDecode(responseBody);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['error'] ?? responseData['message'] ?? 'Upload gagal'),
            backgroundColor: Colors.red,
          ),
        );

        return false;
      }
    } catch (e) {
      print('Error uploading photo: $e');

      String errorMessage = 'Error upload foto';
      
      if (e.toString().contains('SocketException')) {
        errorMessage = 'Tidak ada koneksi internet';
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = 'Upload timeout, coba lagi';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );

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