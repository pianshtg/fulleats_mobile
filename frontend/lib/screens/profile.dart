import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile'), backgroundColor: Colors.orange),
      body: Padding(
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
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'John Doe',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'john.doe@example.com',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            // Profile Options
            _buildProfileOption(Icons.history, 'Order History'),
            _buildProfileOption(Icons.favorite, 'Favorites'),
            _buildProfileOption(Icons.settings, 'Settings'),
            _buildProfileOption(Icons.help, 'Help & Support'),
            _buildProfileOption(Icons.logout, 'Logout'),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title) {
    return Card(
      margin: EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: Icon(icon, color: Colors.orange),
        title: Text(title),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // Handle option tap
        },
      ),
    );
  }
}
