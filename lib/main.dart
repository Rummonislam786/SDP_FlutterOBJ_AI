import 'package:Attendance_System/signinorsignupscreen.dart';
import 'package:Attendance_System/splashscreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/auth.dart';
import '/login.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const NoteMateApp(),
    ),
  );
}

class NoteMateApp extends StatelessWidget {
  const NoteMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Note Mate',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SplashScreen(),
    );
  }
}
