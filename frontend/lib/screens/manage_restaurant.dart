import 'package:flutter/material.dart';
import 'package:frontend/models/item.dart';
import 'package:frontend/utils/authservice.dart';
import 'package:frontend/screens/login.dart';
import 'package:frontend/screens/create_restaurant.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ManageRestaurantScreen extends StatefulWidget {
  const ManageRestaurantScreen({super.key});

  @override
  _ManageRestaurantScreenState createState() => _ManageRestaurantScreenState();
}

class _ManageRestaurantScreenState extends State<ManageRestaurantScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  Map<String, dynamic>? _restaurantData;
  String? _errorMessage;
  List<Item> menuItems = [];

  static const String baseUrl = 'http://172.20.10.3:3030/api/restaurant';

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkAuthAndFetchRestaurant();
  }

  bool _isUserLoggedIn() {
    final accessToken = _authService.getAccessToken();
    final refreshToken = _authService.getRefreshToken();

    print('=== RESTAURANT AUTH DEBUG ===');
    print('Access Token: $accessToken');
    print('Refresh Token: $refreshToken');

    final isLoggedIn =
        (accessToken != null && accessToken.isNotEmpty) &&
        (refreshToken != null && refreshToken.isNotEmpty);

    print('User is logged in: $isLoggedIn');
    print('=============================');

    return isLoggedIn;
  }

  void _checkAuthAndFetchRestaurant() {
    if (_isUserLoggedIn()) {
      _fetchUserRestaurant();
    } else {
      setState(() {
        _restaurantData = null;
        _errorMessage = null;
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchUserRestaurant() async {
    final accessToken = _authService.getAccessToken();
    final refreshToken = _authService.getRefreshToken();

    if (accessToken == null ||
        accessToken.isEmpty ||
        refreshToken == null ||
        refreshToken.isEmpty) {
      setState(() {
        _restaurantData = null;
        _errorMessage = null;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('Fetching restaurant data...');
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
          'X-Refresh-Token': '$refreshToken',
          'X-Client-Type': 'mobile',
        },
      );

      print('Restaurant Response Status Code: ${response.statusCode}');
      print('Restaurant Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          _restaurantData = responseData['restaurant'];
          _loadMenuItems();
          _isLoading = false;
        });
      } else if (response.statusCode == 404) {
        // No restaurant found for user
        setState(() {
          _restaurantData = null;
          _isLoading = false;
        });
      } else if (response.statusCode == 401) {
        // Token expired or invalid
        _authService.clearTokens();
        setState(() {
          _restaurantData = null;
          _isLoading = false;
        });
      } else {
        final responseData = json.decode(response.body);
        setState(() {
          _errorMessage =
              responseData['message'] ?? 'Failed to load restaurant';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error. Please check your connection.';
        _isLoading = false;
      });
      print('Restaurant fetch error: $e');
    }
  }

  void _loadMenuItems() {
    if (_restaurantData != null && _restaurantData!['menu'] != null) {
      try {
        final menuData =
            _restaurantData!['menu'] is String
                ? json.decode(_restaurantData!['menu'])
                : _restaurantData!['menu'];

        setState(() {
          menuItems =
              menuData.entries.map<Item>((entry) {
                return Item(
                  name: entry.key,
                  price:
                      (entry.value is int)
                          ? entry.value.toDouble()
                          : entry.value.toDouble(),
                );
              }).toList();
        });
      } catch (e) {
        print('Error loading menu items: $e');
        setState(() {
          menuItems = [];
        });
      }
    }
  }

  void _navigateToLogin() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => LoginPage(
              onLoginSuccess: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Successfully logged in!'),
                    backgroundColor: Colors.green,
                  ),
                );
                _fetchUserRestaurant();
              },
            ),
      ),
    );

    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully logged in!'),
          backgroundColor: Colors.green,
        ),
      );
      _fetchUserRestaurant();
    }
  }

  void _navigateToCreateRestaurant() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateRestaurantScreen()),
    );

    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Restaurant created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      _fetchUserRestaurant();
    }
  }

  void _addMenuItem() {
    if (_nameController.text.isNotEmpty && _priceController.text.isNotEmpty) {
      try {
        double price = double.parse(_priceController.text);
        setState(() {
          menuItems.add(Item(name: _nameController.text, price: price));
        });
        _nameController.clear();
        _priceController.clear();
        Navigator.of(context).pop();
        _updateRestaurantMenu();
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Please enter a valid price')));
      }
    }
  }

  void _deleteMenuItem(int index) {
    setState(() {
      menuItems.removeAt(index);
    });
    _updateRestaurantMenu();
  }

  Future<void> _updateRestaurantMenu() async {
    final accessToken = _authService.getAccessToken();
    final refreshToken = _authService.getRefreshToken();
    if (accessToken == null || refreshToken == null || _restaurantData == null)
      return;

    try {
      Map<String, double> menuMap = {};
      for (var item in menuItems) {
        menuMap[item.name] = item.price;
      }

      final response = await http.put(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
          'X-Refresh-Token': '$refreshToken',
          'X-Client-Type': 'mobile',
        },
        body: json.encode({'menu': menuMap}),
      );

      if (response.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update menu'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error updating menu: $e');
    }
  }

  void _showAddItemDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Menu Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Item Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(),
                  prefixText: 'Rp. ',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
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

  void _refreshRestaurant() {
    if (_isUserLoggedIn()) {
      _fetchUserRestaurant();
    } else {
      setState(() {
        _restaurantData = null;
        _errorMessage = null;
      });
    }
  }

  Widget _buildNotLoggedInView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu, size: 80, color: Colors.grey[400]),
            SizedBox(height: 24),
            Text(
              'You haven\'t logged in as a user',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text(
              'Please log in to manage your restaurant and menu items',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _navigateToLogin,
              icon: Icon(Icons.login),
              label: Text('Log In'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoRestaurantView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.store, size: 80, color: Colors.grey[400]),
            SizedBox(height: 24),
            Text(
              'You don\'t have a restaurant yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text(
              'Create your restaurant to start managing menu items and accept orders',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _navigateToCreateRestaurant,
              icon: Icon(Icons.add_business),
              label: Text('Create Restaurant'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantManagement() {
    return Column(
      children: [
        // Restaurant Info Header
        Container(
          padding: EdgeInsets.all(16.0),
          color: Colors.orange[50],
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.orange,
                child: Icon(Icons.restaurant, color: Colors.white, size: 30),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _restaurantData?['name'] ?? 'Restaurant Name',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _restaurantData?['location'] ?? 'Location',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Menu Management
        Container(
          padding: EdgeInsets.all(16.0),
          color: Colors.orange[50],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Menu Items Management',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: _showAddItemDialog,
                icon: Icon(Icons.add),
                label: Text('Add Item'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              ),
            ],
          ),
        ),
        // Menu Items List
        Expanded(
          child:
              menuItems.isEmpty
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.restaurant_menu,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No menu items yet',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tap the Add Item button to get started',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                  : ListView.builder(
                    padding: EdgeInsets.all(16.0),
                    itemCount: menuItems.length,
                    itemBuilder: (context, index) {
                      final item = menuItems[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 12.0),
                        child: ListTile(
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.orange[100],
                            ),
                            child: Icon(Icons.fastfood, color: Colors.orange),
                          ),
                          title: Text(
                            item.name,
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            'Rp. ${item.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          trailing: IconButton(
                            onPressed: () => _deleteMenuItem(index),
                            icon: Icon(Icons.delete),
                            color: Colors.red,
                          ),
                        ),
                      );
                    },
                  ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Restaurant'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _refreshRestaurant),
        ],
      ),
      body:
          _isLoading
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.orange),
                    SizedBox(height: 16),
                    Text('Loading restaurant...'),
                  ],
                ),
              )
              : _errorMessage != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red),
                    SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refreshRestaurant,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                      child: Text('Retry'),
                    ),
                  ],
                ),
              )
              : !_isUserLoggedIn()
              ? _buildNotLoggedInView()
              : _restaurantData == null
              ? _buildNoRestaurantView()
              : _buildRestaurantManagement(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}
