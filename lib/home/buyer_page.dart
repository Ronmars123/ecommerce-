import 'package:capstone/components/navbar.dart';
import 'package:capstone/login/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BuyerHomePage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Function to log out the user
  Future<void> _logout(BuildContext context) async {
    await _auth.signOut();
    // Navigate back to the LoginScreen after logout
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser; // Get the current user

    if (user == null) {
      // If no user is signed in, redirect to the login screen
      return LoginScreen();
    }

    // Extract the userId from the logged-in user
    String userId = user.uid;

    // Set the user type for this page (as "Buyer")
    String userType = "Buyer"; // You can change this based on your logic

    return Scaffold(
      body: Column(
        children: [
          // Pass both userId and userType to the Navbar
          Navbar(userId: userId, userType: userType), // Pass userType here
          const Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome, Buyer!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
