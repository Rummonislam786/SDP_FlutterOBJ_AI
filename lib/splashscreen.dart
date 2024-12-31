import 'dart:async';

import 'package:Attendance_System/signinorsignupscreen.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeAndScaleController;
  late AnimationController _logoShakeController;
  late AnimationController _titleShakeController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _logoShakeAnimation;
  late Animation<Offset> _titleShakeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize Fade and Scale Animation Controller
    _fadeAndScaleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Initialize Logo Shake Animation Controller
    _logoShakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000), // Slow vertical shake
    )..repeat(reverse: true);

    // Initialize Title Shake Animation Controller
    _titleShakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000), // Slow horizontal shake
    )..repeat(reverse: true);

    // Define Fade Animation
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeAndScaleController,
        curve: Curves.easeIn,
      ),
    );

    // Define Scale Animation
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeAndScaleController,
        curve: Curves.elasticOut,
      ),
    );

    // Define Vertical Shake Animation for Logo
    _logoShakeAnimation = Tween<Offset>(
      begin: const Offset(0.0, -0.02), // Slightly up
      end: const Offset(0.0, 0.02), // Slightly down
    ).animate(
      CurvedAnimation(
        parent: _logoShakeController,
        curve: Curves.easeInOut,
      ),
    );

    // Define Horizontal Shake Animation for Title
    _titleShakeAnimation = Tween<Offset>(
      begin: const Offset(-0.02, 0.0), // Slightly left
      end: const Offset(0.02, 0.0), // Slightly right
    ).animate(
      CurvedAnimation(
        parent: _titleShakeController,
        curve: Curves.easeInOut,
      ),
    );

    // Start Fade and Scale Animations
    _fadeAndScaleController.forward();

    // Navigate to Home Screen after 3 seconds
    Timer(const Duration(seconds: 3), () {
      _logoShakeController.stop();
      _titleShakeController.stop();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const SigninOrSignupScreen()),
      );
    });
  }

  @override
  void dispose() {
    _fadeAndScaleController.dispose();
    _logoShakeController.dispose();
    _titleShakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Centered Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Shaking Logo
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _logoShakeAnimation,
                      child: Image.asset(
                        'assets/notepad.png', // Add your logo in assets folder
                        width: 120,
                        height: 120,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Shaking Title
                SlideTransition(
                  position: _titleShakeAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      'NoteMate',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey.shade900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
