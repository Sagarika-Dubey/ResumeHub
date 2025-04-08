import 'package:flutter/material.dart';
import 'LoginScreen.dart';
import 'RegestrationScreen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background design elements
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.4,
              width: MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [Color(0xFF2979FF), Color(0xFF75A7FF)],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(180),
                ),
              ),
            ),
          ),

          // Bottom decorative shape
          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              height: 200,
              width: 200,
              decoration: const BoxDecoration(
                color: Color(0xFFE3F2FD),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(200),
                ),
              ),
            ),
          ),

          // Decorative circles
          Positioned(
            top: MediaQuery.of(context).size.height * 0.3,
            left: 20,
            child: Container(
              height: 60,
              width: 60,
              decoration: const BoxDecoration(
                color: Color(0xFFBBDEFB),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.25,
            right: 40,
            child: Container(
              height: 40,
              width: 40,
              decoration: const BoxDecoration(
                color: Color(0xFF90CAF9),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),

                  // App name with logo
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.description_outlined,
                          color: Color(0xFF2979FF),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        " RESUME HUB",
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 60),

                  // Welcome message
                  Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: const Text(
                      "Create Your Professional Resume",
                      style: TextStyle(
                        color: Color(0xFF333333),
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Subtitle
                  Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: const Text(
                      "Join our community and build standout resumes that help you land your dream job.",
                      style: TextStyle(
                        color: Color(0xFF666666),
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Login button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2979FF),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      "LOG IN",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Sign up button
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignupScreen()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2979FF),
                      side: const BorderSide(color: Color(0xFF2979FF), width: 1.5),
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "SIGN UP",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}