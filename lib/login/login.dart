import 'package:capstone/home/admin_page.dart';
import 'package:capstone/home/buyer_page.dart';
import 'package:capstone/home/edit_profile.dart';
import 'package:capstone/home/seller_page.dart';
import 'package:capstone/login/register.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _errorMessage;
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkLoginState(); // Check user session on widget initialization
  }

  Future<void> _checkLoginState() async {
    User? user = _auth.currentUser;

    if (user != null) {
      setState(() {
        _isLoading = true; // Show loading spinner while fetching user data
      });

      // Fetch user data from Firebase Realtime Database (Correct path: 'users/{uid}/userprofiles')
      DataSnapshot snapshot = await _database
          .child('users')
          .child(user.uid)
          .child('userprofiles')
          .get();

      if (snapshot.exists) {
        bool profileSetupComplete =
            snapshot.child('profile_setup_complete').value == true;

        String? userType = snapshot.child('user_type').value as String?;

        if (profileSetupComplete && userType != null) {
          if (userType == 'Seller') {
            // Navigate to SellerHomePage if user is a seller
            // ignore: use_build_context_synchronously
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => SellerHomePage()),
            );
          } else if (userType == 'Buyer') {
            // Navigate to BuyerHomePage if user is a buyer
            // ignore: use_build_context_synchronously
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => BuyerHomePage()),
            );
          } else if (userType == 'Admin') {
            // Navigate to AdminHomePage if user is an admin
            // ignore: use_build_context_synchronously
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AdminHomePage()),
            );
          }
        } else {
          // Navigate to EditProfileScreen if profile is not set up
          // ignore: use_build_context_synchronously
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => EditProfileScreen(uid: user.uid)),
          );
        }
      } else {
        setState(() {
          _errorMessage = "User data not found!";
        });
      }

      setState(() {
        _isLoading = false; // Hide spinner after fetching data
      });
    }
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true; // Show loading spinner during login process
      _errorMessage = null;
    });

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // After logging in, check the user's profile setup state
      await _checkLoginState(); // Reuse login state check after signing in
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false; // Hide spinner if an error occurs
        switch (e.code) {
          case 'invalid-email':
            _errorMessage = "The email address is badly formatted.";
            break;
          case 'user-not-found':
            _errorMessage = "No user found with this email.";
            break;
          case 'wrong-password':
            _errorMessage = "The password is incorrect.";
            break;
          case 'too-many-requests':
            _errorMessage = "Too many login attempts. Try again later.";
            break;
          default:
            _errorMessage = "Login failed. Please try again.";
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = "An error occurred. Please try again.";
        _isLoading = false;
      });
    }
  }

  void _navigateToRegister() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) =>
            RegisterScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0); // From right to left
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // Light background
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator()) // Show spinner if loading
          : _buildLoginForm(), // Show login form otherwise
    );
  }

  Widget _buildLoginForm() {
    final screenWidth = MediaQuery.of(context).size.width;
    double containerWidth = screenWidth < 600 ? screenWidth * 0.9 : 400;

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            width: containerWidth,
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 5,
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.account_circle,
                  size: screenWidth < 600 ? 80 : 100, // Smaller icon on mobile
                  color: Colors.grey[800],
                ),
                const SizedBox(height: 16),
                Text(
                  'Welcome',
                  style: TextStyle(
                    fontSize:
                        screenWidth < 600 ? 24 : 28, // Smaller text for mobile
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                _isLoading
                    ? const CircularProgressIndicator()
                    : Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFEF233C),
                              Color(0xFFD90429)
                            ], // Red Gradient
                          ),
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          onPressed: _login,
                          child: const Text(
                            'LOGIN',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text("Don't have an account?"),
                    const SizedBox(width: 5),
                    GestureDetector(
                      onTap: _navigateToRegister,
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
