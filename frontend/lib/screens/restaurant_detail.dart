import 'package:flutter/material.dart';
import 'package:frontend/models/cart_item.dart';
import 'package:frontend/models/restaurant.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final Restaurant restaurant;
  final List<CartItem> cart;

  const RestaurantDetailScreen({
    super.key,
    required this.restaurant,
    required this.cart,
  });

  @override
  _RestaurantDetailScreenState createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  void _addToCart(String itemName, double price) {
    setState(() {
      // Check if item already exists in cart
      final existingIndex = widget.cart.indexWhere(
        (item) => item.name == itemName,
      );
      if (existingIndex != -1) {
        widget.cart[existingIndex].quantity++;
      } else {
        widget.cart.add(CartItem(name: itemName, price: price));
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$itemName added to cart'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  double get _cartTotal {
    return widget.cart.fold(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.restaurant.name),
        backgroundColor: Colors.orange,
      ),
      body: Column(
        children: [
          // Restaurant Header
          Container(
            padding: EdgeInsets.all(16.0),
            color: Colors.grey[100],
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.orange[100],
                  ),
                  child: Icon(Icons.restaurant, size: 40, color: Colors.orange),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.restaurant.name,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 16, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(
                            widget.restaurant.location,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Menu Items
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16.0),
              itemCount: widget.restaurant.menu.length,
              itemBuilder: (context, index) {
                final itemName = widget.restaurant.menu.keys.elementAt(index);
                final itemPrice = widget.restaurant.menu[itemName]!;

                return Card(
                  margin: EdgeInsets.only(bottom: 12.0),
                  child: ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.orange[50],
                      ),
                      child: Icon(Icons.fastfood, color: Colors.orange),
                    ),
                    title: Text(
                      itemName,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'Rp. ${itemPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: IconButton(
                      onPressed: () => _addToCart(itemName, itemPrice),
                      icon: Icon(Icons.add_shopping_cart),
                      color: Colors.orange,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton:
          widget.cart.isNotEmpty
              ? FloatingActionButton.extended(
                onPressed: () {
                  _showCartDialog(context);
                },
                backgroundColor: Colors.orange,
                icon: Icon(Icons.shopping_cart),
                label: Text(
                  'Cart (${widget.cart.length}) - Rp. ${_cartTotal.toStringAsFixed(2)}',
                ),
              )
              : null,
    );
  }

  void _showCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Shopping Cart'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...widget.cart.map(
                  (item) => ListTile(
                    title: Text(item.name),
                    subtitle: Text(
                      'Rp. ${item.price.toStringAsFixed(2)} x ${item.quantity}',
                    ),
                    trailing: Text(
                      'Rp. ${(item.price * item.quantity).toStringAsFixed(2)}',
                    ),
                  ),
                ),
                Divider(),
                ListTile(
                  title: Text(
                    'Total',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Text(
                    'Rp. ${_cartTotal.toStringAsFixed(2)}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                // Checkout functionality would go here
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Order placed successfully!')),
                );
                widget.cart.clear();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: Text('Checkout'),
            ),
          ],
        );
      },
    );
  }
}
