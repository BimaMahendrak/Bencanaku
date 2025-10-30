import 'package:bencanaku/router/appRouter.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Bencanaku',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(textTheme: GoogleFonts.soraTextTheme(), primarySwatch: Colors.blue ),
      routerConfig: appRouter,
    );
  }
}