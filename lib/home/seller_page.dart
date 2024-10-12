import 'package:capstone/login/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart'; // Import Firebase Realtime Database
import 'package:capstone/components/navbar.dart'; // Import the Navbar

class SellerHomePage extends StatefulWidget {
  @override
  _SellerHomePageState createState() => _SellerHomePageState();
}

class _SellerHomePageState extends State<SellerHomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  bool _isLoading = true;
  bool _isApproved = false;
  DatabaseReference?
      _userProfileRef; // Reference for the user's profile in Firebase

  // Function to log out the user
  Future<void> _logout(BuildContext context) async {
    await _auth.signOut();
    // Navigate back to the LoginScreen after logout
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  void initState() {
    super.initState();
    _checkApprovalStatus(); // Check approval status when the page loads
  }

  @override
  void dispose() {
    // Unsubscribe from the Firebase listener when the widget is disposed
    _userProfileRef?.onValue.drain();
    super.dispose();
  }

  // Fetch the seller's approval status from Firebase
  Future<void> _checkApprovalStatus() async {
    User? user = _auth.currentUser;
    if (user != null) {
      // Set reference to the seller's profile in Firebase
      _userProfileRef =
          _database.child('users').child(user.uid).child('userprofiles');

      // Set an initial listener for changes in the seller_approval field
      _userProfileRef!.onValue.listen((event) {
        if (event.snapshot.exists) {
          Map<dynamic, dynamic> userData =
              event.snapshot.value as Map<dynamic, dynamic>;
          setState(() {
            // Set the approval status based on the Firebase snapshot
            _isApproved = userData['seller_approval'] == true;
            _isLoading = false; // Data is loaded
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    // If the user is not logged in, return to login screen
    if (user == null) {
      return const LoginScreen();
    }

    String userId = user.uid;
    String userType = "Seller"; // Assume this user is a Seller

    return Scaffold(
      body: _isLoading
          ? const Center(
              child:
                  CircularProgressIndicator()) // Show loading indicator while fetching data
          : Column(
              children: [
                // Disable or hide the Navbar if not approved
                if (_isApproved)
                  Navbar(
                      userId: userId,
                      userType: userType), // Show Navbar only if approved

                // Display a message if seller_approval is false
                Expanded(
                  child: Stack(
                    children: [
                      // Seller dashboard content
                      const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Welcome, Seller!',
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      // If not approved, display the "NOT APPROVED" message and hide the Navbar
                      if (!_isApproved)
                        Positioned.fill(
                          child: Container(
                            color: Colors.black
                                .withOpacity(0.7), // Semi-transparent overlay
                            child: const Center(
                              child: Text(
                                'YOU\'RE NOT APPROVED YET',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
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
