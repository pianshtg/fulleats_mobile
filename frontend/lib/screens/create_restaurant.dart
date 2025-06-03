import 'package:flutter/material.dart';
import 'package:frontend/models/item.dart';
import 'package:frontend/utils/authservice.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CreateRestaurantScreen extends StatefulWidget {
  const CreateRestaurantScreen({super.key});

  @override
  _CreateRestaurantScreenState createState() => _CreateRestaurantScreenState();
}

class _CreateRestaurantScreenState extends State<CreateRestaurantScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  // Restaurant info controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  // Menu item controllers
  final TextEditingController _menuItemNameController = TextEditingController();
  final TextEditingController _menuItemPriceController =
      TextEditingController();

  List<Item> menuItems = [];
  bool _isLoading = false;

  static const String baseUrl = 'http://10.0.2.2:3030/api/restaurant';

  void _addMenuItem() {
    if (_menuItemNameController.text.isNotEmpty &&
        _menuItemPriceController.text.isNotEmpty) {
      try {
        double price = double.parse(_menuItemPriceController.text);
        if (price <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Price must be greater than 0')),
          );
          return;
        }

        // Check if item already exists
        bool itemExists = menuItems.any(
          (item) =>
              item.name.toLowerCase() ==
              _menuItemNameController.text.toLowerCase(),
        );

        if (itemExists) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Menu item already exists')));
          return;
        }

        setState(() {
          menuItems.add(
            Item(name: _menuItemNameController.text.trim(), price: price),
          );
        });

        _menuItemNameController.clear();
        _menuItemPriceController.clear();
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Please enter a valid price')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all menu item fields')),
      );
    }
  }

  void _showAddMenuItemDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Menu Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _menuItemNameController,
                decoration: InputDecoration(
                  labelText: 'Item Name',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., Margherita Pizza',
                ),
                textCapitalization: TextCapitalization.words,
              ),
              SizedBox(height: 16),
              TextField(
                controller: _menuItemPriceController,
                decoration: InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(),
                  prefixText: 'Rp. ',
                  hintText: '50000',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _menuItemNameController.clear();
                _menuItemPriceController.clear();
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _addMenuItem,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _deleteMenuItem(int index) {
    setState(() {
      menuItems.removeAt(index);
    });
  }

  Future<void> _createRestaurant() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (menuItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please add at least one menu item'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final accessToken = _authService.getAccessToken();
    final refreshToken = _authService.getRefreshToken();
    if (accessToken == null ||
        accessToken.isEmpty ||
        refreshToken == null ||
        refreshToken.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Authentication error. Please log in again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Convert menu items to JSON object format
      Map<String, double> menuMap = {};
      for (var item in menuItems) {
        menuMap[item.name] = item.price;
      }

      final requestBody = {
        'name': _nameController.text.trim(),
        'location': _locationController.text.trim(),
        'menu': menuMap,
        'image_url': 'https://via.placeholder.com/150', // Default placeholder
      };

      print('Creating restaurant with data: ${json.encode(requestBody)}');

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
          'X-Refresh-Token': '$refreshToken',
          'X-Client-Type': 'mobile',
        },
        body: json.encode(requestBody),
      );

      print('Create restaurant response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Success
        Navigator.of(context).pop(true); // Return true to indicate success
      } else {
        final responseData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              responseData['message'] ?? 'Failed to create restaurant',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error creating restaurant: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Network error. Please check your connection.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Restaurant'),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Restaurant Info Section
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Restaurant Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[700],
                        ),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Restaurant Name *',
                          border: OutlineInputBorder(),
                          hintText: 'e.g., Pizza Palace',
                          prefixIcon: Icon(
                            Icons.restaurant,
                            color: Colors.orange,
                          ),
                        ),
                        textCapitalization: TextCapitalization.words,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter restaurant name';
                          }
                          if (value.trim().length < 3) {
                            return 'Restaurant name must be at least 3 characters';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _locationController,
                        decoration: InputDecoration(
                          labelText: 'Location *',
                          border: OutlineInputBorder(),
                          hintText: 'e.g., Jl. Sudirman No. 123',
                          prefixIcon: Icon(
                            Icons.location_on,
                            color: Colors.orange,
                          ),
                        ),
                        textCapitalization: TextCapitalization.words,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter restaurant location';
                          }
                          if (value.trim().length < 5) {
                            return 'Location must be at least 5 characters';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Menu Section
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Menu Items',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[700],
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _showAddMenuItemDialog,
                            icon: Icon(Icons.add),
                            label: Text('Add Item'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),

                      if (menuItems.isEmpty)
                        Container(
                          padding: EdgeInsets.all(32.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.restaurant_menu,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No menu items added yet',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Add at least one menu item to continue',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Column(
                          children:
                              menuItems.asMap().entries.map((entry) {
                                int index = entry.key;
                                Item item = entry.value;

                                return Card(
                                  margin: EdgeInsets.only(bottom: 8.0),
                                  color: Colors.orange[50],
                                  child: ListTile(
                                    leading: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.orange[200],
                                      ),
                                      child: Icon(
                                        Icons.fastfood,
                                        color: Colors.orange[700],
                                        size: 20,
                                      ),
                                    ),
                                    title: Text(
                                      item.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'Rp. ${item.price.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        color: Colors.green[700],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    trailing: IconButton(
                                      onPressed: () => _deleteMenuItem(index),
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 32),

              // Create Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createRestaurant,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child:
                      _isLoading
                          ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('Creating Restaurant...'),
                            ],
                          )
                          : Text('Create Restaurant'),
                ),
              ),

              SizedBox(height: 16),

              // Info note
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You can always edit your restaurant details and menu items later from the manage restaurant page.',
                        style: TextStyle(color: Colors.blue[700], fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _menuItemNameController.dispose();
    _menuItemPriceController.dispose();
    super.dispose();
  }
}
