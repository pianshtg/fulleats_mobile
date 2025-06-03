import 'package:flutter/material.dart';
import 'package:frontend/utils/authservice.dart';
import 'package:frontend/screens/login.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  Map<String, dynamic>? _userData;
  String? _errorMessage;

  static const String baseUrl = 'http://10.0.2.2:3030/api/user';

  @override
  void initState() {
    super.initState();
    _checkAuthAndFetchProfile();
  }

  bool _isUserLoggedIn() {
    final accessToken = _authService.getAccessToken();
    final refreshToken = _authService.getRefreshToken();

    // Debug prints to check token values
    print('=== TOKEN DEBUG ===');
    print('Access Token: $accessToken');
    print('Refresh Token: $refreshToken');
    print(
      'Access Token is null/empty: ${accessToken == null || accessToken.isEmpty}',
    );
    print(
      'Refresh Token is null/empty: ${refreshToken == null || refreshToken.isEmpty}',
    );

    // User is logged in only if BOTH access token AND refresh token exist
    final isLoggedIn =
        (accessToken != null && accessToken.isNotEmpty) &&
        (refreshToken != null && refreshToken.isNotEmpty);

    print('User is logged in: $isLoggedIn');
    print('==================');

    return isLoggedIn;
  }

  void _checkAuthAndFetchProfile() {
    if (_isUserLoggedIn()) {
      _fetchUserProfile();
    } else {
      // If not logged in, ensure we show the not logged in view
      setState(() {
        _userData = null;
        _errorMessage = null;
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchUserProfile() async {
    // Double check that both tokens exist before making the API call
    final accessToken = _authService.getAccessToken();
    final refreshToken = _authService.getRefreshToken();

    if (accessToken == null ||
        accessToken.isEmpty ||
        refreshToken == null ||
        refreshToken.isEmpty) {
      setState(() {
        _userData = null;
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
      print('Sending API request...');
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
          'X-Refresh-Token': refreshToken,
          'X-Client-Type': 'mobile',
        },
      );

      final responseData = json.decode(response.body);

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          _userData = responseData['user'];
          _isLoading = false;
        });
      } else if (response.statusCode == 401) {
        // Token expired or invalid
        _authService.clearTokens();
        setState(() {
          _userData = null;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = responseData['message'] ?? 'Failed to load profile';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error. Please check your connection.';
        _isLoading = false;
      });
      print('Profile fetch error: $e');
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
                _fetchUserProfile(); // Fetch profile after successful login
              },
            ),
      ),
    );

    // Check if login was successful (if using Navigator.pop with result)
    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully logged in!'),
          backgroundColor: Colors.green,
        ),
      );
      _fetchUserProfile();
    }
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _authService.clearTokens();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Logged out successfully'),
                    backgroundColor: Colors.orange,
                  ),
                );
                setState(() {
                  _userData = null;
                });
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  void _refreshProfile() {
    if (_isUserLoggedIn()) {
      _fetchUserProfile();
    } else {
      setState(() {
        _userData = null;
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
            Icon(Icons.person_outline, size: 80, color: Colors.grey[400]),
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
              'Please log in to view your profile and access personalized features',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _refreshProfile),
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
                    Text('Loading profile...'),
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
                      onPressed: _refreshProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                      child: Text('Retry'),
                    ),
                  ],
                ),
              )
              : _userData != null
              ? Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Profile Header
                    Container(
                      padding: EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.orange,
                            child: Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            _userData?['name'] ??
                                _userData?['username'] ??
                                'User',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            _userData?['email'] ?? 'No email available',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                          if (_userData?['phone'] != null) ...[
                            SizedBox(height: 4),
                            Text(
                              _userData!['phone'],
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                    // Profile Options
                    _buildProfileOption(Icons.history, 'Order History'),
                    _buildProfileOption(Icons.favorite, 'Favorites'),
                    _buildProfileOption(Icons.settings, 'Settings'),
                    _buildProfileOption(Icons.help, 'Help & Support'),
                    _buildProfileOption(
                      Icons.logout,
                      'Logout',
                      onTap: _handleLogout,
                    ),
                  ],
                ),
              )
              : _buildNotLoggedInView(),
    );
  }

  Widget _buildProfileOption(
    IconData icon,
    String title, {
    VoidCallback? onTap,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: Icon(icon, color: Colors.orange),
        title: Text(title),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap:
            onTap ??
            () {
              // Handle option tap
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('$title clicked')));
            },
      ),
    );
  }
}
