import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart'; // Import dots indicator package
import 'navbar.dart';

class ShopPage extends StatefulWidget {
  final String userId;
  final String userType;

  ShopPage({required this.userId, required this.userType});

  @override
  _ShopPageState createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  int _currentCarouselIndex = 0; // Track current carousel page index

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Navbar(userId: widget.userId, userType: widget.userType), // Navbar
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildCarousel(),
                  const SizedBox(height: 10),
                  _buildDotsIndicator(), // Add the dots indicator here
                  const SizedBox(height: 20),
                  _buildCategoryIcons(), // Add category icons section
                  const SizedBox(height: 20),
                  _buildPopularProducts(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarousel() {
    final List<String> imageList = [
      'img/image1.jpg',
      'img/image2.jpg',
      'img/image3.jpg',
    ];

    return CarouselSlider(
      options: CarouselOptions(
        height: 300, // Increased the height to make it bigger
        autoPlay: true,
        enlargeCenterPage: true,
        aspectRatio: 16 / 9,
        autoPlayInterval:
            const Duration(seconds: 5), // Slowed down the autoplay
        autoPlayAnimationDuration:
            const Duration(milliseconds: 1000), // Slower transition
        autoPlayCurve: Curves.easeInOut, // Smoother transition curve
        pauseAutoPlayOnTouch: true,
        viewportFraction: 0.90,
        onPageChanged: (index, reason) {
          setState(() {
            _currentCarouselIndex = index;
          });
        },
      ),
      items: imageList.map((imagePath) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.symmetric(horizontal: 5.0),
              decoration: BoxDecoration(
                color: Colors.red[900],
              ),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
              ),
            );
          },
        );
      }).toList(),
    );
  }

  // Dots Indicator widget
  Widget _buildDotsIndicator() {
    return DotsIndicator(
      dotsCount: 3, // Number of images in the carousel
      position:
          _currentCarouselIndex, // Ensure smoothness by converting to double
      decorator: DotsDecorator(
        activeColor: Colors.red[900], // Active dot color
        size: const Size.square(9.0),
        activeSize: const Size(18.0, 9.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        spacing: const EdgeInsets.symmetric(
            horizontal: 4.0), // Adds smooth spacing between dots
      ),
    );
  }

  // Category Icons widget
  Widget _buildCategoryIcons() {
    final List<Map<String, String>> categories = [
      {'icon': 'assets/fashion.png', 'label': '50% Off Fashion'},
      {'icon': 'assets/shopee_mall.png', 'label': 'Shopee Mall'},
      {'icon': 'assets/choice.png', 'label': 'Shopee Choice'},
      {'icon': 'assets/beauty.png', 'label': 'Shopee Beauty'},
      {'icon': 'assets/delivery.png', 'label': 'On-time Delivery'},
      // Removed 5 additional items
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: categories.map((category) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              category['icon']!,
              height: 40, // Adjust icon size as needed
            ),
            const SizedBox(height: 8),
            Text(
              category['label']!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildPopularProducts(BuildContext context) {
    final List<Map<String, String>> products = [
      {
        'name': 'Fancy Product',
        'price': '\$40.00 - \$80.00',
        'image': 'https://via.placeholder.com/450x300'
      },
      {
        'name': 'Special Item',
        'price': '\$18.00',
        'discount': '\$20.00',
        'rating': '4.5',
        'image': 'https://via.placeholder.com/450x300'
      },
      {
        'name': 'Sale Item',
        'price': '\$25.00',
        'discount': '\$50.00',
        'image': 'https://via.placeholder.com/450x300'
      },
      {
        'name': 'Popular Item',
        'price': '\$40.00',
        'rating': '5',
        'image': 'https://via.placeholder.com/450x300'
      },
      {
        'name': 'Sale Item',
        'price': '\$25.00',
        'discount': '\$50.00',
        'image': 'https://via.placeholder.com/450x300'
      },
      {
        'name': 'Fancy Product',
        'price': '\$120.00 - \$280.00',
        'image': 'https://via.placeholder.com/450x300'
      },
      {
        'name': 'Special Item',
        'price': '\$18.00',
        'discount': '\$20.00',
        'rating': '4.5',
        'image': 'https://via.placeholder.com/450x300'
      },
      {
        'name': 'Popular Item',
        'price': '\$40.00',
        'rating': '5',
        'image': 'https://via.placeholder.com/450x300'
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 4;
        double screenWidth = constraints.maxWidth;

        if (screenWidth <= 600) {
          crossAxisCount = 2;
        } else if (screenWidth <= 1200) {
          crossAxisCount = 3;
        }

        // Adjust childAspectRatio based on screen width
        double childAspectRatio = 0.75;
        if (screenWidth <= 600) {
          childAspectRatio = 0.7; // Adjust for smaller screens
        } else if (screenWidth <= 1200) {
          childAspectRatio = 0.8; // Adjust for medium screens
        } else {
          childAspectRatio = 1; // More square-like for larger screens
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: childAspectRatio, // Apply aspect ratio adjustment
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            return _buildProductCard(products[index]);
          },
        );
      },
    );
  }

  Widget _buildProductCard(Map<String, String> product) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(255, 136, 0, 0).withOpacity(0.1),
            spreadRadius: 4,
            blurRadius: 50,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center, // Center-align content
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              image: DecorationImage(
                image: NetworkImage(product['image']!),
                fit: BoxFit.cover, // Make sure the image fits well in the box
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center, // Center the text
              children: [
                Text(
                  product['name']!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center, // Center the text
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center, // Center the row
                  children: [
                    Text(
                      product['price']!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    if (product.containsKey('discount'))
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          product['discount']!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ),
                  ],
                ),
                if (product.containsKey('rating'))
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment
                          .center, // Center the stars and rating
                      children: [
                        Icon(Icons.star, color: Colors.yellow[700], size: 18),
                        const SizedBox(width: 4),
                        Text(
                          product['rating']!,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red[900],
                  ),
                  child: const Text('Add to cart'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
