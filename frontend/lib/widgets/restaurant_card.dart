import 'package:flutter/material.dart';
import 'package:frontend/models/cart_item.dart';
import 'package:frontend/models/restaurant.dart';
import 'package:frontend/screens/restaurant_detail.dart';

class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  final List<CartItem> cart;

  const RestaurantCard({
    super.key,
    required this.restaurant,
    required this.cart,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => RestaurantDetailScreen(
                    restaurant: restaurant,
                    cart: cart,
                  ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Restaurant Image
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.orange[100],
                ),
                child: Icon(Icons.restaurant, size: 30, color: Colors.orange),
              ),
              SizedBox(width: 16),
              // Restaurant Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurant.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          restaurant.location,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
