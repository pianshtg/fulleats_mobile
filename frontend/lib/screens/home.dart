// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
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
  List<Restaurant> restaurants = [
    Restaurant(
      name: 'Pizza Pengkolan',
      location: 'Jl. Hiha',
      menu: {
        'Margherita Pizza': 129900,
        'Pepperoni Pizza': 149900,
        'Caesar Salad': 89900,
        'Garlic Bread': 59900,
      },
      imageUrl: 'https://via.placeholder.com/150',
    ),
    Restaurant(
      name: 'Burger Bangor',
      location: 'Jl. Haha',
      menu: {
        'Classic Burger': 109900,
        'Cheeseburger': 119900,
        'Fries': 49900,
        'Milkshake': 69900,
      },
      imageUrl: 'https://via.placeholder.com/150',
    ),
    Restaurant(
      name: 'Sushi Susha',
      location: 'Jl. Hihi',
      menu: {
        'California Roll': 89900,
        'Salmon Nigiri': 129900,
        'Miso Soup': 49900,
        'Green Tea': 29900,
      },
      imageUrl: 'https://via.placeholder.com/150',
    ),
  ];

  List<Restaurant> filteredRestaurants = [];

  @override
  void initState() {
    super.initState();
    filteredRestaurants = restaurants;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('FullEats'), backgroundColor: Colors.orange),
      body: Column(
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
          // Restaurant Cards List
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: filteredRestaurants.length,
              itemBuilder: (context, index) {
                final restaurant = filteredRestaurants[index];
                return RestaurantCard(
                  restaurant: restaurant,
                  cart: widget.cart,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
