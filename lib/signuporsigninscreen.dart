import 'package:Attendance_System/signin.dart';
import 'package:Attendance_System/signup.dart';
import 'package:flutter/material.dart';

class SigninOrSignupScreen extends StatelessWidget {
  const SigninOrSignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 202, 240, 248),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Image.asset(
                "assets/logo.png",
                height: 250,
              ),
              const Text(
                "EMPLOYEE ATTENDANCE SYSTEM",
                style: TextStyle(
                    fontSize: 20,
                    fontFamily: "Courier",
                    fontWeight: FontWeight.w900),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SignInScreen()));
                },
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: const Color(0xFF00BF6D),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: const StadiumBorder(),
                ),
                child: const Text("Sign In"),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SignupScreen()));
                },
                style: ElevatedButton.styleFrom(
                    elevation: 0,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 48),
                    shape: const StadiumBorder(),
                    backgroundColor: const Color.fromARGB(255, 244, 151, 142)),
                child: const Text("Sign Up"),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
