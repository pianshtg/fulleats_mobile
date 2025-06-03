import 'package:flutter/material.dart';
import 'package:frontend/models/cart_item.dart';
import 'package:frontend/models/restaurant.dart';
import 'package:frontend/screens/login.dart';
import 'package:frontend/utils/authservice.dart';

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
  final AuthService _authService = AuthService();

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

  bool _isUserLoggedIn() {
    final accessToken = _authService.getAccessToken();
    final refreshToken = _authService.getRefreshToken();

    // User is logged in if either access token or refresh token exists
    return (accessToken != null && accessToken.isNotEmpty) ||
        (refreshToken != null && refreshToken.isNotEmpty);
  }

  void _handleCheckout() {
    if (_isUserLoggedIn()) {
      // User is logged in, proceed with checkout
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order placed successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {
        widget.cart.clear();
      });
    } else {
      // User is not logged in, show login required message
      Navigator.of(context).pop(); // Close cart dialog first
      _showLoginRequiredDialog();
    }
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.login, color: Colors.orange),
              SizedBox(width: 8),
              Text('Login Required'),
            ],
          ),
          content: Text(
            'You need to log in to place an order. Would you like to go to the login page?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _navigateToLogin();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: Text('Go to Login'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToLogin() async {
    // Navigate to login page and wait for result
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => LoginPage(
              onLoginSuccess: () {
                // After successful login, pop back to this page
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Successfully logged in! You can now checkout.',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
      ),
    );

    // Alternative: If you prefer to use named routes
    // final result = await Navigator.pushNamed(context, '/login');

    // Check if login was successful (if using Navigator.pop with result)
    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully logged in! You can now checkout.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.restaurant.name),
        backgroundColor: Colors.orange,
        actions: [
          // Optional: Add login status indicator
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child:
                  _isUserLoggedIn()
                      ? Icon(Icons.account_circle, color: Colors.white)
                      : Icon(
                        Icons.account_circle_outlined,
                        color: Colors.white70,
                      ),
            ),
          ),
        ],
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
              onPressed: _handleCheckout,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: Text('Checkout'),
            ),
          ],
        );
      },
    );
  }
}
