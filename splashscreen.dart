import 'package:flutter/material.dart';
import 'loginscreen.dart'; // Adjust the path as needed

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0EAF1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6699CC), // Matching the AppBar color from theme
        elevation: 0,
        title: const Text(
          'WELCOME',
          style: TextStyle(
            color: Colors.black,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Padding to move the image down
          Padding(
            padding: const EdgeInsets.only(top: 50), // Adjust this value to move the image down
            child: ClipOval(
              child: Image.asset(
                'assets/image1.png', // Path to your image in the assets folder
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Alzheimer's Disease text
          Center(
            child: const Text(
              'ALZHEIMER\'S DISEASE',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const Spacer(), // Pushes the button to the bottom

          // Get Started button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6699CC), // Matching the AppBar color
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 5,
              ),
              child: const Text(
                'GET STARTED',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Ensure text color contrasts well with button
                ),
              ),
            ),
          ),
          const SizedBox(height: 40), // Add some space at the bottom
        ],
      ),
    );
  }
}