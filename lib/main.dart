import 'package:bencanaku/router/appRouter.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // Tambahkan import ini

void main() async {
  // Pastikan Flutter binding sudah initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inisialisasi locale data untuk Bahasa Indonesia
  await initializeDateFormatting('id_ID', null);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Bencanaku',
      routerConfig: appRouter,
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      // Set default locale ke Indonesia
      locale: const Locale('id', 'ID'),
    );
  }
}