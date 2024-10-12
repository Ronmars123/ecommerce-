import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class User {
  final String uid;
  final String firstName;
  final String lastName;
  final String middleName;
  final String userType;
  final String address;
  final String email;
  final bool sellerApproval; // Add sellerApproval field

  User({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.middleName,
    required this.userType,
    required this.address,
    required this.email,
    required this.sellerApproval, // Initialize sellerApproval
  });

  // Factory method to create a User from Firebase snapshot
  factory User.fromMap(String uid, Map<dynamic, dynamic> data) {
    return User(
      uid: uid, // Get UID from key
      firstName: data['first_name'] ?? 'N/A',
      lastName: data['last_name'] ?? 'N/A',
      middleName: data['middle_name'] ?? 'N/A',
      userType: data['user_type'] ?? 'N/A',
      address: data['address'] ?? 'N/A',
      email: data['email'] ?? 'N/A',
      sellerApproval: data['seller_approval'] ?? false, // Map sellerApproval
    );
  }
}

class UserManagementPage extends StatefulWidget {
  @override
  _UserManagementPageState createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.ref().child('users');
  List<User> _users = [];
  List<User> _filteredUsers = [];
  bool _isLoading = true;
  String _selectedFilter = 'All'; // Dropdown filter value
  String _searchQuery = ''; // Search query

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  // Fetch users from Firebase, excluding Admin users
  void _fetchUsers() async {
    _databaseReference.once().then((snapshot) {
      List<User> usersList = [];
      if (snapshot.snapshot.value != null) {
        Map<dynamic, dynamic> usersData =
            snapshot.snapshot.value as Map<dynamic, dynamic>;

        usersData.forEach((key, value) {
          User user = User.fromMap(key, value['userprofiles']); // Map user data
          if (user.userType != 'Admin') {
            usersList.add(user); // Exclude Admin users
          }
        });
      }

      setState(() {
        _users = usersList;
        _filteredUsers = usersList; // Initially show all users
        _isLoading = false;
      });
    }).catchError((error) {
      // Handle any errors here
      print('Error fetching users: $error');
    });
  }

  // Filter users based on the selected user type
  void _filterUsers(String filter) {
    setState(() {
      _selectedFilter = filter;
      _applyFilters();
    });
  }

  // Apply filters and search query
  void _applyFilters() {
    List<User> filteredList = _users;

    // Filter by user type
    if (_selectedFilter != 'All') {
      filteredList = filteredList
          .where((user) => user.userType == _selectedFilter)
          .toList();
    }

    // Apply search query filter
    if (_searchQuery.isNotEmpty) {
      filteredList = filteredList.where((user) {
        final fullName =
            '${user.firstName.toLowerCase()} ${user.middleName.toLowerCase()} ${user.lastName.toLowerCase()}';
        return fullName.contains(_searchQuery.toLowerCase());
      }).toList();
    }

    setState(() {
      _filteredUsers = filteredList;
    });
  }

  // Handle search input
  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilters();
    });
  }

  // Approve the seller by setting seller_approval to true in Firebase
  void _approveSeller(String userId) async {
    DatabaseReference userRef =
        _databaseReference.child(userId).child('userprofiles');

    // Set seller_approval to true in Firebase
    await userRef.update({
      'seller_approval': true,
    });

    // Reload the user list after approval
    _fetchUsers();
  }

  // Decline the seller by setting seller_approval to false in Firebase
  void _declineSeller(String userId) async {
    DatabaseReference userRef =
        _databaseReference.child(userId).child('userprofiles');

    // Set seller_approval to false in Firebase
    await userRef.update({
      'seller_approval': false,
    });

    // Reload the user list after decline
    _fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: Colors.red[900],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                bool isMobile = constraints.maxWidth < 600;

                return Column(
                  children: [
                    // Search bar
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Search by Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          prefixIcon: const Icon(Icons.search),
                        ),
                        onChanged: _onSearchChanged,
                      ),
                    ),

                    // Filter dropdown and label
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        children: [
                          const Text(
                            'Filter by:',
                            style: TextStyle(fontSize: 14),
                          ),
                          const SizedBox(width: 10),
                          DropdownButton<String>(
                            value: _selectedFilter,
                            items: <String>['All', 'Seller', 'Buyer']
                                .map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                _filterUsers(newValue);
                              }
                            },
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.builder(
                          itemCount: _filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = _filteredUsers[index];

                            // Highlight border color only for Sellers
                            Color? borderColor;
                            if (user.userType == 'Seller') {
                              borderColor = user.sellerApproval
                                  ? Colors.green
                                  : Colors.red;
                            }

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: borderColor != null
                                    ? BorderSide(
                                        color: borderColor,
                                        width: 2.0,
                                      )
                                    : BorderSide.none, // Apply only for sellers
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // User info (Name, Email, Address)
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${user.firstName} ${user.middleName} ${user.lastName}',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            user.email, // Display user's email
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          // Address row
                                          Row(
                                            children: [
                                              const Icon(Icons.location_on,
                                                  color: Colors.grey, size: 16),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  user.address,
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          // User Type row (only for non-admin users)
                                          if (user.userType != 'Admin')
                                            Row(
                                              children: [
                                                const Icon(Icons.person,
                                                    color: Colors.grey,
                                                    size: 16),
                                                const SizedBox(width: 6),
                                                Text(
                                                  'User Type: ${user.userType}',
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ),
                                    // Approve and Decline buttons only for sellers
                                    if (user.userType == 'Seller')
                                      Row(
                                        children: [
                                          // Approve button
                                          IconButton(
                                            icon: const Icon(
                                              Icons.check_circle,
                                              color: Colors.green,
                                            ),
                                            onPressed: () {
                                              _approveSeller(user.uid);
                                            },
                                          ),
                                          // Decline button
                                          IconButton(
                                            icon: const Icon(
                                              Icons.cancel,
                                              color: Colors.red,
                                            ),
                                            onPressed: () {
                                              _declineSeller(user.uid);
                                            },
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
