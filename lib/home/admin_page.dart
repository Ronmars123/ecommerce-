import 'package:capstone/login/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:capstone/components/navbar.dart'; // Import the Navbar

class AdminHomePage extends StatelessWidget {
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
    // Get the current user from FirebaseAuth
    User? user = _auth.currentUser;

    // If the user is not logged in, return to login screen
    if (user == null) {
      return LoginScreen();
    }

    // Extract the userId from the logged-in user
    String userId = user.uid;

    // Set the user type to "Admin"
    String userType = "Admin"; // Set userType for Admin

    return Scaffold(
      body: Column(
        children: [
          // Include the Navbar here and pass both the userId and userType
          Navbar(
              userId: userId,
              userType: userType), // Pass both userId and userType

          // Rest of the admin dashboard body
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Welcome, Admin!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  // Logout Button
                  ElevatedButton(
                    onPressed: () =>
                        _logout(context), // Call the logout function
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, // Red button for logout
                    ),
                    child: const Text('Logout'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
