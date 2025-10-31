import 'package:bencanaku/router/appRouter.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'services/notificationService.dart'; // Tambahkan import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inisialisasi locale data untuk Bahasa Indonesia
  await initializeDateFormatting('id_ID', null);
  
  // Inisialisasi Awesome Notifications
  await NotificationService.initialize();
  
  // Setup listeners untuk handle notifikasi yang diklik
  NotificationService.setupListeners();
  
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
      locale: const Locale('id', 'ID'),
    );
  }
}