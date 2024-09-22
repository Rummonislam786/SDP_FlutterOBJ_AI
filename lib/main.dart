import 'package:Attendance_System/FaceDetectionScreen.dart';
import 'package:flutter/material.dart';
import 'package:Attendance_System/dashboard.dart';
import 'package:Attendance_System/signup.dart';
import 'package:Attendance_System/signin.dart';
import 'package:Attendance_System/signuporsigninscreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: SigninOrSignupScreen(),
    );
  }
}
