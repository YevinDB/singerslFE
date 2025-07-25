import 'package:flutter/material.dart';
import 'package:singer_sl/models/product.dart';
import 'package:singer_sl/screens/add_product_screen.dart';
import 'package:singer_sl/screens/edit_product_screen.dart';
import 'package:singer_sl/screens/login_screen.dart';
import 'package:singer_sl/services/auth_service.dart';
import 'package:singer_sl/services/product_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProductService _productService = ProductService();
  final AuthService _authService = AuthService();
  final TextEditingController _searchController = TextEditingController();

  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _productService.searchProducts('');
      if (response.success && response.data != null) {
        setState(() {
          _products = response.data!;
          _filteredProducts = _products;
        });
      } else {
        _showSnackBar(response.message, Colors.red);
      }
    } catch (e) {
      _showSnackBar('Failed to load products', Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // void _filterProducts(String query) {
  //   setState(() {
  //     _searchQuery = query;
  //     if (query.isEmpty) {
  //       _filteredProducts = _products;
  //     } else {
  //       _filteredProducts = _products.where((product) {
  //         return product.productCode
  //                 .toLowerCase()
  //                 .contains(query.toLowerCase()) ||
  //             product.productName.toLowerCase().contains(query.toLowerCase());
  //       }).toList();
  //     }
  //   });
  // }

  Future<void> _filterProducts(String query) async {
    setState(() {
      _searchQuery = query;
      _isLoading = true;
    });

    try {
      // Use the API search with the query
      final response = await _productService.searchProducts(query);
      if (response.success && response.data != null) {
        setState(() {
          _filteredProducts = response.data!;
          // Update the main products list if it's a fresh search
          if (query.isEmpty) {
            _products = response.data!;
          }
        });
      } else {
        _showSnackBar(response.message, Colors.red);
      }
    } catch (e) {
      _showSnackBar('Failed to search products', Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _authService.logout();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (route) => false,
                );
              },
              child: Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Colors.blue[700],
          child: Text(
            product.productCode.isNotEmpty
                ? product.productCode[0].toUpperCase()
                : 'P',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          product.productName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(
              'Code: ${product.productCode}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Price: LKR ${product.price.toStringAsFixed(2)}',
              style: TextStyle(
                color: Colors.green[700],
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.edit, color: Colors.blue[700]),
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditProductScreen(product: product),
              ),
            );
            if (result == true) {
              _loadProducts();
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Management'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by product code or name...',
                prefixIcon: Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterProducts('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              onChanged: _filterProducts,
            ),
          ),

          // Products List
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading products...'),
                      ],
                    ),
                  )
                : _filteredProducts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'No products found.\nAdd your first product!'
                                  : 'No products match your search.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            if (_searchQuery.isEmpty) ...[
                              SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddProductScreen(),
                                    ),
                                  );
                                  if (result == true) {
                                    _loadProducts();
                                  }
                                },
                                icon: Icon(Icons.add),
                                label: Text('Add Product'),
                              ),
                            ],
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadProducts,
                        child: ListView.builder(
                          itemCount: _filteredProducts.length,
                          itemBuilder: (context, index) {
                            return _buildProductCard(_filteredProducts[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddProductScreen(),
            ),
          );
          if (result == true) {
            _loadProducts();
          }
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue[700],
        tooltip: 'Add Product',
      ),
    );
  }
}
