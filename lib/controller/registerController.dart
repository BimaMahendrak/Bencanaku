import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';

class RegisterController {
  final TextEditingController namaLengkapController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> handleRegister(BuildContext context, GlobalKey<FormState> formKey, ValueNotifier<bool> isLoading) async {
    if (formKey.currentState!.validate()) {
      isLoading.value = true;

      try {
        // API request
        final response = await http.post(
          Uri.parse('https://monitoringweb.decoratics.id/api/bencana/pengguna'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'nama_lengkap': namaLengkapController.text,
            'username': usernameController.text,
            'password': passwordController.text,
          }),
        );

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registrasi berhasil!'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigasi ke halaman login
          context.go('/login');
        } else if (response.statusCode == 422) {
          final data = jsonDecode(response.body);
          String errorMessage = 'Terjadi kesalahan validasi';

          if (data['errors'] != null) {
            // Ambil pesan error pertama
            final errors = data['errors'] as Map<String, dynamic>;
            if (errors.isNotEmpty) {
              final firstError = errors.values.first;
              if (firstError is List && firstError.isNotEmpty) {
                errorMessage = firstError.first.toString();
              }
            }
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Terjadi kesalahan pada server'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak dapat terhubung ke server'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        isLoading.value = false;
      }
    }
  }

  void dispose() {
    namaLengkapController.dispose();
    usernameController.dispose();
    passwordController.dispose();
  }
}