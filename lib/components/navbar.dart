import 'package:capstone/components/seller_shop.dart';
import 'package:capstone/components/shop.dart';
import 'package:capstone/home/buyer_page.dart';
import 'package:flutter/material.dart';
import 'profile_page.dart';
import 'user_management.dart'; // Import the user management page

class Navbar extends StatelessWidget {
  final String userId;
  final String userType; // Add userType field

  Navbar({
    required this.userId,
    required this.userType,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isLargeScreen = constraints.maxWidth > 600;

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          color: Colors.red[900],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'HANDCRAFT',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isLargeScreen)
                Row(
                  children: [
                    if (userType == 'Admin') ...[
                      _buildNavButton(
                          context, 'Users'), // Show "Users" for Admin
                    ] else ...[
                      _buildNavButton(context, 'Home'),
                      const SizedBox(width: 30),
                      _buildNavButton(context, 'Shop'),
                      const SizedBox(width: 30),
                      _buildProfileButton(
                          context, userId), // Profile button before Cart now
                      if (userType == 'Buyer') ...[
                        const SizedBox(width: 30),
                        _buildCartIconButton(
                            context), // Cart icon for Buyers only
                      ],
                    ],
                  ],
                )
              else
                PopupMenuButton<String>(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onSelected: (String value) {
                    switch (value) {
                      case 'Home':
                        _navigateWithFadeTransition(
                          context,
                          BuyerHomePage(),
                        );
                        break;
                      case 'Shop':
                        _navigateWithFadeTransition(
                          context,
                          ShopPage(
                            userType: userType,
                            userId: userId,
                          ),
                        );
                        break;
                      case 'Cart':
                        if (userType == 'Buyer') {
                          _navigateWithFadeTransitionNamed(context, '/cart');
                        }
                        break;
                      case 'Users':
                        if (userType == 'Admin') {
                          _navigateWithFadeTransition(
                            context,
                            UserManagementPage(),
                          );
                        }
                        break;
                      case 'Profile':
                        _showProfileModal(context, userId);
                        break;
                    }
                  },
                  color: Colors.red[900],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  itemBuilder: (BuildContext context) {
                    if (userType == 'Admin') {
                      return [
                        _buildPopupMenuItem('Users'), // Show "Users" for Admin
                        _buildPopupMenuItem('Profile'),
                      ];
                    } else {
                      return [
                        _buildPopupMenuItem('Home'),
                        _buildPopupMenuItem('Shop'),
                        _buildPopupMenuItem('Profile'),
                        if (userType == 'Buyer')
                          _buildPopupMenuItem(
                              'Cart'), // Cart in the menu for Buyers only
                      ];
                    }
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  // Profile button (large screens)
  Widget _buildProfileButton(BuildContext context, String userId) {
    return TextButton(
      onPressed: () {
        _showProfileModal(context, userId); // Pass the userId here
      },
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.red[900],
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Text(
        'Profile',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Cart icon button (large screens)
  Widget _buildCartIconButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.shopping_cart, color: Colors.white),
      onPressed: () {
        _navigateWithFadeTransitionNamed(context, '/cart');
      },
    );
  }

  // Helper function to show profile modal
  void _showProfileModal(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ProfilePage(userId: userId); // Pass the userId here
      },
    );
  }

  // Helper function to build navigation buttons (Home, Shop, Users)
  Widget _buildNavButton(BuildContext context, String label) {
    return TextButton(
      onPressed: () {
        switch (label) {
          case 'Home':
            _navigateWithFadeTransition(
              context,
              BuyerHomePage(),
            );
            break;
          case 'Shop':
            if (userType == 'Seller') {
              // Navigate to the seller's shop page
              _navigateWithFadeTransition(
                context,
                SellerShopPage(userId: userId),
              );
            } else {
              // Navigate to the general shop page
              _navigateWithFadeTransition(
                context,
                ShopPage(
                  userType: userType,
                  userId: userId,
                ),
              );
            }
            break;
          case 'Users':
            if (userType == 'Admin') {
              _navigateWithFadeTransition(
                context,
                UserManagementPage(),
              );
            }
            break;
        }
      },
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.red[900],
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Helper function to navigate with fade transition
  void _navigateWithFadeTransition(BuildContext context, Widget page) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final fadeIn = Tween(begin: 0.0, end: 1.0).animate(animation);
          return FadeTransition(opacity: fadeIn, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300), // Fade duration
      ),
    );
  }

  // Helper function to navigate with fade transition using named routes
  void _navigateWithFadeTransitionNamed(
      BuildContext context, String routeName) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            Container(), // Empty, required for named route
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final fadeIn = Tween(begin: 0.0, end: 1.0).animate(animation);
          return FadeTransition(opacity: fadeIn, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300), // Fade duration
        settings: RouteSettings(name: routeName),
      ),
    );
  }

  // Helper function to build dropdown menu items for small screens
  PopupMenuItem<String> _buildPopupMenuItem(String label) {
    return PopupMenuItem<String>(
      value: label,
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
