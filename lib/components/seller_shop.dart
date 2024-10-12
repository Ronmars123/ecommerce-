import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class SellerShopPage extends StatelessWidget {
  final String userId;

  SellerShopPage({required this.userId});

  final DatabaseReference _databaseRef =
      FirebaseDatabase.instance.ref().child('shops');
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Shop'),
        backgroundColor: Colors.red[900],
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddProductModal(context);
            },
          ),
        ],
      ),
      body: _buildProductList(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red[900],
        onPressed: () {
          _showAddProductModal(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // Fetch products from Firebase and display them in a list
  Widget _buildProductList() {
    return StreamBuilder(
      stream: _databaseRef.child(userId).child('products').onValue,
      builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
        if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
          Map<dynamic, dynamic> productMap =
              snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

          if (productMap.isEmpty) {
            return const Center(
              child: Text('No products available'),
            );
          }

          List<Map<String, dynamic>> products = [];
          productMap.forEach((key, value) {
            products.add({
              'id': key,
              'name': value['name'],
              'price': value['price'],
              'description': value['description'],
              'quantity': value['quantity'],
              'imageUrl':
                  value['imageUrl'], // Image URL added to the product data
              'product_deliver': value['product_deliver'],
              'product_received': value['product_received'],
            });
          });

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: products.length,
            itemBuilder: (context, index) {
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                elevation: 5,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: InkWell(
                  onTap: () {
                    // Show product description dialog when the product is tapped
                    _showProductDescriptionDialog(context, products[index]);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Display product image if available
                        Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: products[index]['imageUrl'] != null &&
                                  products[index]['imageUrl'] != ''
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.network(
                                    products[index]['imageUrl'],
                                    height: 80,
                                    width: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.error,
                                        color: Colors.red,
                                        size: 40,
                                      );
                                    },
                                  ),
                                )
                              : const Icon(
                                  Icons.shopping_bag,
                                  size: 40,
                                  color: Colors.red,
                                ),
                        ),
                        const SizedBox(width: 16.0),
                        // Product details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                products[index]['name'] ?? '',
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                products[index]['description'] ?? '',
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.attach_money,
                                    size: 18.0,
                                    color: Colors.green,
                                  ),
                                  Text(
                                    products[index]['price'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 16.0),
                                  const Icon(
                                    Icons.shopping_cart,
                                    size: 18.0,
                                    color: Colors.orange,
                                  ),
                                  Text(
                                    'Qty: ${products[index]['quantity'] ?? ''}',
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8.0),
                              Row(
                                children: [
                                  Text(
                                    'Delivered: ${products[index]['product_deliver'] == true ? "Yes" : "No"}',
                                    style: const TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(width: 16.0),
                                  Text(
                                    'Received: ${products[index]['product_received'] == true ? "Yes" : "No"}',
                                    style: const TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Center-aligned edit button
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                _showEditProductModal(context, products[index]);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading products'));
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  // Show product description in a dialog
  void _showProductDescriptionDialog(
      BuildContext context, Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(product['name'] ?? 'Product Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Description: ${product['description']}'),
              const SizedBox(height: 8),
              Text('Price: \$${product['price']}'),
              const SizedBox(height: 8),
              Text('Quantity: ${product['quantity']}'),
              const SizedBox(height: 8),
              Text(
                  'Delivered: ${product['product_deliver'] == true ? "Yes" : "No"}'),
              const SizedBox(height: 8),
              Text(
                  'Received: ${product['product_received'] == true ? "Yes" : "No"}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // Modal to add a new product with image upload
  void _showAddProductModal(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    TextEditingController priceController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    TextEditingController quantityController = TextEditingController();
    File? _imageFile;

    Future<void> _pickImage() async {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      }
    }

    Future<String?> _uploadImage(File imageFile) async {
      try {
        String fileName =
            'products/${DateTime.now().millisecondsSinceEpoch}.png';
        Reference ref = _storage.ref().child(fileName);
        UploadTask uploadTask = ref.putFile(imageFile);
        TaskSnapshot snapshot = await uploadTask;
        return await snapshot.ref.getDownloadURL();
      } catch (e) {
        print('Error uploading image: $e');
        return null;
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add New Product'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () async {
                      await _pickImage();
                      setState(() {});
                    },
                    child: _imageFile != null
                        ? Image.file(
                            _imageFile!,
                            height: 150,
                            width: 150,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            height: 150,
                            width: 150,
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.add_a_photo,
                              color: Colors.grey,
                              size: 50,
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration:
                        const InputDecoration(labelText: 'Product Name'),
                  ),
                  TextField(
                    controller: priceController,
                    decoration: const InputDecoration(labelText: 'Price'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                  TextField(
                    controller: quantityController,
                    decoration: const InputDecoration(labelText: 'Quantity'),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    String productName = nameController.text;
                    String productPrice = priceController.text;
                    String productDescription = descriptionController.text;
                    String productQuantity = quantityController.text;

                    if (productName.isNotEmpty && productPrice.isNotEmpty) {
                      String? imageUrl;
                      if (_imageFile != null) {
                        imageUrl = await _uploadImage(_imageFile!);
                      }

                      await _databaseRef
                          .child(userId)
                          .child('products')
                          .push()
                          .set({
                        'name': productName,
                        'price': productPrice,
                        'description': productDescription,
                        'quantity': productQuantity,
                        'imageUrl':
                            imageUrl ?? '', // Store image URL in Firebase
                        'product_deliver': false, // Set initial value to false
                        'product_received': false, // Set initial value to false
                      });
                    }

                    Navigator.of(context).pop();
                  },
                  child: const Text('Add'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Modal to edit a product
  void _showEditProductModal(
      BuildContext context, Map<String, dynamic> product) {
    TextEditingController nameController =
        TextEditingController(text: product['name']);
    TextEditingController priceController =
        TextEditingController(text: product['price']);
    TextEditingController descriptionController =
        TextEditingController(text: product['description']);
    TextEditingController quantityController =
        TextEditingController(text: product['quantity']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Product'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Product Name'),
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                String updatedName = nameController.text;
                String updatedPrice = priceController.text;
                String updatedDescription = descriptionController.text;
                String updatedQuantity = quantityController.text;

                if (updatedName.isNotEmpty && updatedPrice.isNotEmpty) {
                  await _databaseRef
                      .child(userId)
                      .child('products')
                      .child(product['id']!)
                      .update({
                    'name': updatedName,
                    'price': updatedPrice,
                    'description': updatedDescription,
                    'quantity': updatedQuantity,
                  });
                }

                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
