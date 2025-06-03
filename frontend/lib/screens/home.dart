// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/models/cart_item.dart';
import 'package:frontend/models/restaurant.dart';
import 'package:frontend/widgets/restaurant_card.dart';

class HomeScreen extends StatefulWidget {
  final List<CartItem> cart;

  const HomeScreen({super.key, required this.cart});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Restaurant> restaurants = [];
  List<Restaurant> filteredRestaurants = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchRestaurants();
  }

  Future<void> _fetchRestaurants() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final response = await http.get(
        Uri.parse('http://10.0.2.2:3030/api/restaurant/all'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> restaurantsList = responseData['restaurants'];

        setState(() {
          restaurants =
              restaurantsList.map((restaurantData) {
                // Convert menu from JSON to Map<String, double>
                Map<String, double> menu = {};
                if (restaurantData['menu'] != null) {
                  final menuData =
                      restaurantData['menu'] is String
                          ? json.decode(restaurantData['menu'])
                          : restaurantData['menu'];

                  menuData.forEach((key, value) {
                    menu[key] =
                        (value is int) ? value.toDouble() : value.toDouble();
                  });
                }

                return Restaurant(
                  name: restaurantData['name'] ?? '',
                  location: restaurantData['location'] ?? '',
                  menu: menu,
                  imageUrl:
                      restaurantData['image_url'] ??
                      'https://via.placeholder.com/150',
                );
              }).toList();

          filteredRestaurants = restaurants;
          isLoading = false;
        });
      } else if (response.statusCode == 409) {
        setState(() {
          restaurants = [];
          filteredRestaurants = [];
          isLoading = false;
          errorMessage = 'No restaurants found.';
        });
      } else {
        throw Exception('Failed to load restaurants');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        errorMessage =
            'Failed to load restaurants. Please check your connection.';
      });
      print('Error fetching restaurants: $error');
    }
  }

  void _filterRestaurants(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredRestaurants = restaurants;
      } else {
        filteredRestaurants =
            restaurants
                .where(
                  (restaurant) =>
                      restaurant.name.toLowerCase().contains(
                        query.toLowerCase(),
                      ) ||
                      restaurant.location.toLowerCase().contains(
                        query.toLowerCase(),
                      ),
                )
                .toList();
      }
    });
  }

  Future<void> _refreshRestaurants() async {
    await _fetchRestaurants();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FullEats'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _refreshRestaurants),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshRestaurants,
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                onChanged: _filterRestaurants,
                decoration: InputDecoration(
                  hintText: 'Search restaurants...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
            ),
            // Content Area
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
            ),
            SizedBox(height: 16),
            Text(
              'Loading restaurants...',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              errorMessage!,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchRestaurants,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (filteredRestaurants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              _searchController.text.isEmpty
                  ? 'No restaurants available'
                  : 'No restaurants found for "${_searchController.text}"',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: filteredRestaurants.length,
      itemBuilder: (context, index) {
        final restaurant = filteredRestaurants[index];
        return RestaurantCard(restaurant: restaurant, cart: widget.cart);
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
