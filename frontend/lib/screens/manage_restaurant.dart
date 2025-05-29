import 'package:flutter/material.dart';
import 'package:frontend/models/item.dart';

class ManageRestaurantScreen extends StatefulWidget {
  const ManageRestaurantScreen({super.key});

  @override
  _ManageRestaurantScreenState createState() => _ManageRestaurantScreenState();
}

class _ManageRestaurantScreenState extends State<ManageRestaurantScreen> {
  List<Item> menuItems = [
    Item(name: 'Burger', price: 99900),
    Item(name: 'Pizza', price: 129900),
    Item(name: 'Salad', price: 79900),
  ];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

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
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Please enter a valid price')));
      }
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

  void _deleteMenuItem(int index) {
    setState(() {
      menuItems.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Restaurant'),
        backgroundColor: Colors.orange,
      ),
      body: Column(
        children: [
          // Add Menu Item Prompt
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
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
      ),
    );
  }
}
