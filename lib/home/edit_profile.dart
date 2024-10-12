import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

import 'buyer_page.dart'; // Assuming this exists in your app
import 'seller_page.dart'; // Assuming this exists in your app
import 'admin_page.dart'; // Assuming this exists in your app

class EditProfileScreen extends StatefulWidget {
  final String uid; // User ID to save profile data

  const EditProfileScreen({Key? key, required this.uid}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _provinceController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _barangayController = TextEditingController();
  DateTime? _selectedBirthdate;
  int _currentStep = 0;
  String? _errorMessage;

  Future<void> _saveProfile() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      await _database
          .child('users')
          .child(widget.uid)
          .child('userprofiles')
          .update({
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'middle_name': _middleNameController.text,
        'birthdate': _birthdateController.text,
        'address': _addressController.text,
        'province': _provinceController.text,
        'city': _cityController.text,
        'barangay': _barangayController.text,
        'profile_setup_complete': true,
      });

      DataSnapshot snapshot = await _database
          .child('users')
          .child(widget.uid)
          .child('userprofiles')
          .get();
      Navigator.pop(context);

      if (snapshot.exists) {
        String? userType = snapshot.child('user_type').value as String?;

        if (userType == 'Seller') {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => SellerHomePage()));
        } else if (userType == 'Buyer') {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => BuyerHomePage()));
        } else if (userType == 'Admin') {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => AdminHomePage()));
        } else {
          setState(() {
            _errorMessage = "Unknown user type. Please contact support.";
          });
        }
      }
    } catch (e) {
      Navigator.pop(context);
      setState(() {
        _errorMessage = "Failed to save profile. Please try again.";
      });
    }
  }

  Future<void> _selectBirthdate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthdate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedBirthdate) {
      setState(() {
        _selectedBirthdate = picked;
        _birthdateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Widget _buildStep1(double buttonHeight, double buttonFontSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Name',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildTextField(
            controller: _firstNameController, labelText: 'First Name'),
        const SizedBox(height: 16),
        _buildTextField(
            controller: _middleNameController, labelText: 'Middle Name'),
        const SizedBox(height: 16),
        _buildTextField(
            controller: _lastNameController, labelText: 'Last Name'),
        const SizedBox(height: 16),
        TextField(
          controller: _birthdateController,
          decoration: InputDecoration(
            labelText: 'Birthdate',
            suffixIcon: const Icon(Icons.calendar_today),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          readOnly: true,
          onTap: () => _selectBirthdate(context),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              if (_validateStep1()) {
                setState(() {
                  _currentStep = 1;
                  _errorMessage = null;
                });
              }
            },
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, buttonHeight),
              textStyle: TextStyle(fontSize: buttonFontSize),
              backgroundColor: const Color(0xFFA00000),
            ),
            child: const Text('Next'),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2(double buttonHeight, double buttonFontSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Address',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildTextField(controller: _addressController, labelText: 'Address'),
        const SizedBox(height: 16),
        _buildTextField(controller: _provinceController, labelText: 'Province'),
        const SizedBox(height: 16),
        _buildTextField(controller: _cityController, labelText: 'City'),
        const SizedBox(height: 16),
        _buildTextField(controller: _barangayController, labelText: 'Barangay'),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _currentStep = 0;
                    _errorMessage = null;
                  });
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, buttonHeight),
                  textStyle: TextStyle(fontSize: buttonFontSize),
                  backgroundColor: const Color(0xFFA00000),
                ),
                child: const Text('Back'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, buttonHeight),
                  textStyle: TextStyle(fontSize: buttonFontSize),
                  backgroundColor: const Color(0xFFA00000),
                ),
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  bool _validateStep1() {
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _birthdateController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in all required fields.';
      });
      return false;
    }
    return true;
  }

  void _changeStep(int step) {
    if (step == 0) {
      setState(() {
        _currentStep = 0;
        _errorMessage = null;
      });
    } else if (step == 1 && _validateStep1()) {
      setState(() {
        _currentStep = 1;
        _errorMessage = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;
    final double buttonHeight = isMobile ? 50.0 : 60.0;
    final double buttonFontSize = isMobile ? 16.0 : 18.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        backgroundColor: const Color(0xFFA00000),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 32),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Center(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              _buildStepIndicator(),
              const SizedBox(height: 16),
              if (_currentStep == 0) _buildStep1(buttonHeight, buttonFontSize),
              if (_currentStep == 1) _buildStep2(buttonHeight, buttonFontSize),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStepButton('Step 1', 0),
        const SizedBox(width: 8),
        _buildStepButton('Step 2', 1),
      ],
    );
  }

  Widget _buildStepButton(String label, int step) {
    return ElevatedButton(
      onPressed: () {
        _changeStep(step);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor:
            _currentStep == step ? const Color(0xFFA00000) : Colors.grey[300],
        textStyle: TextStyle(
          color: _currentStep == step ? Colors.white : Colors.black,
        ),
      ),
      child: Text(label),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Color.fromARGB(255, 82, 0, 0)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color.fromARGB(255, 189, 0, 0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
      ),
      cursorColor: const Color(0xFFA00000),
      keyboardType: keyboardType,
    );
  }
}
