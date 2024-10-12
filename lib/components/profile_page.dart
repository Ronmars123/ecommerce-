import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart'; // For logout functionality
import 'package:capstone/login/login.dart'; // For navigating back to login screen

class ProfilePage extends StatefulWidget {
  final String userId; // Pass the user ID to the page

  const ProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance; // FirebaseAuth instance
  Map<String, dynamic>? _userProfile; // Store user data
  File? _image; // Store the selected image
  final ImagePicker _picker = ImagePicker();
  String? _profileImageUrl; // Store the profile image URL

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      // Retrieve user profile from Firebase Realtime Database
      DatabaseEvent event =
          await _database.child('users/${widget.userId}/userprofiles').once();
      setState(() {
        _userProfile = event.snapshot.value as Map<String, dynamic>?;
        _profileImageUrl =
            _userProfile?['profile_image'] ?? ''; // Get profile image URL
      });
    } catch (e) {
      debugPrint("Error fetching user profile: $e");
    }
  }

  Future<void> _selectImage() async {
    // Pick image from gallery or camera
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
      await _uploadImage();
    }
  }

  Future<void> _uploadImage() async {
    try {
      if (_image == null) return;

      // Upload image to Firebase Storage
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${widget.userId}.jpg'); // Use userId to name the file
      await ref.putFile(_image!);

      // Get the download URL for the uploaded image
      final imageUrl = await ref.getDownloadURL();

      // Update profile image URL in Firebase Realtime Database
      await _database
          .child('users/${widget.userId}/userprofiles')
          .update({'profile_image': imageUrl});

      setState(() {
        _profileImageUrl = imageUrl; // Update the profile image URL
      });

      debugPrint('Image uploaded successfully. URL: $imageUrl');
    } catch (e) {
      debugPrint('Error uploading image: $e');
    }
  }

  // Logout function
  Future<void> _logout(BuildContext context) async {
    await _auth.signOut(); // Firebase sign-out
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => LoginScreen()), // Navigate to login
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_userProfile == null) {
      // Show loading indicator while data is being fetched
      return const Center(child: CircularProgressIndicator());
    }

    // Destructure user profile data
    String firstName = _userProfile?['first_name'] ?? 'First Name';
    String middleName = _userProfile?['middle_name'] ?? 'Middle Name';
    String lastName = _userProfile?['last_name'] ?? 'Last Name';
    String email = _userProfile?['email'] ?? 'Email';
    String address = _userProfile?['address'] ?? 'Address';
    String contactNumber = _userProfile?['contact_number'] ?? 'Contact Number';
    String city = _userProfile?['city'] ?? 'City';
    String userType = _userProfile?['user_type'] ?? 'User Type';

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      contentPadding: const EdgeInsets.all(16.0),
      content: SizedBox(
        width: 300, // Smaller width for the dialog
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Close Icon Button at the top-right
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close),
                color: Colors.red[900], // Dark red color for the close icon
                iconSize: 20, // Make the icon smaller
                onPressed: () {
                  Navigator.pop(context); // Close the modal
                },
              ),
            ),
            // Profile Image with Camera Icon
            Stack(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: _profileImageUrl != null &&
                          _profileImageUrl!.isNotEmpty
                      ? NetworkImage(_profileImageUrl!)
                      : const AssetImage('assets/profile.jpg') as ImageProvider,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: InkWell(
                    onTap: _selectImage, // Select image on click
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Full Name (First, Middle, Last)
            Text(
              '$firstName $middleName $lastName',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Display user type
            Text(
              userType,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),

            // City
            Text(
              city,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),

            // Email
            Text(
              email,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),

            // Contact Number
            Text(
              contactNumber,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // Address
            Text(
              address,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Logout Button (instead of Close)
            ElevatedButton(
              onPressed: () => _logout(context), // Logout the user
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                backgroundColor: Colors.red[900],
              ),
              child: const Text(
                'Logout',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
