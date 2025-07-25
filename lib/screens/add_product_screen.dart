import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:singer_sl/models/product.dart';
import 'package:singer_sl/services/product_service.dart';

class AddProductScreen extends StatefulWidget {
  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productCodeController = TextEditingController();
  final _productNameController = TextEditingController();
  final _priceController = TextEditingController();
  final ProductService _productService = ProductService();

  bool _isLoading = false;

  @override
  void dispose() {
    _productCodeController.dispose();
    _productNameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final product = Product(
        productCode: _productCodeController.text.trim(),
        productName: _productNameController.text.trim(),
        price: double.parse(_priceController.text.trim()),
      );

      final response = await _productService.createProduct(product);

      if (response.success) {
        _showSnackBar('Product added successfully!', Colors.green);
        Navigator.of(context).pop(true); // Return true to indicate success
      } else {
        String errorMessage = response.message;
        if (response.errors.isNotEmpty) {
          errorMessage += '\n' + response.errors.join('\n');
        }
        _showSnackBar(errorMessage, Colors.red);
      }
    } catch (e) {
      _showSnackBar('Failed to add product: ${e.toString()}', Colors.red);
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

  String? _validateProductCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Product Code is required';
    }
    if (value.trim().length > 50) {
      return 'Product Code cannot exceed 50 characters';
    }
    return null;
  }

  String? _validateProductName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Product Name is required';
    }
    if (value.trim().length > 200) {
      return 'Product Name cannot exceed 200 characters';
    }
    return null;
  }

  String? _validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Price is required';
    }

    final double? price = double.tryParse(value.trim());
    if (price == null) {
      return 'Please enter a valid price';
    }

    if (price <= 0) {
      return 'Price must be greater than 0';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Product'),
        actions: [
          if (_isLoading)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Section
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.add_box,
                      size: 48,
                      color: Colors.blue[700],
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Add New Product',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Enter the product details below',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32),

              // Product Code Field
              TextFormField(
                controller: _productCodeController,
                decoration: InputDecoration(
                  labelText: 'Product Code *',
                  hintText: 'e.g., SING001',
                  prefixIcon: Icon(Icons.qr_code),
                  helperText: 'Unique identifier for the product',
                ),
                textCapitalization: TextCapitalization.characters,
                validator: _validateProductCode,
                enabled: !_isLoading,
              ),

              SizedBox(height: 20),

              // Product Name Field
              TextFormField(
                controller: _productNameController,
                decoration: InputDecoration(
                  labelText: 'Product Name *',
                  hintText: 'e.g., Singer Refrigerator Model A',
                  prefixIcon: Icon(Icons.inventory_2),
                  helperText: 'Full name of the product',
                ),
                textCapitalization: TextCapitalization.words,
                validator: _validateProductName,
                enabled: !_isLoading,
              ),

              SizedBox(height: 20),

              // Price Field
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: 'Price (LKR) *',
                  hintText: 'e.g., 75000.00',
                  prefixIcon: Icon(Icons.attach_money),
                  helperText: 'Price in Sri Lankan Rupees',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                validator: _validatePrice,
                enabled: !_isLoading,
              ),

              SizedBox(height: 32),

              // Save Button
              ElevatedButton(
                onPressed: _isLoading ? null : _saveProduct,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Adding Product...'),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save),
                          SizedBox(width: 8),
                          Text(
                            'Add Product',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),

              SizedBox(height: 16),

              // Cancel Button
              OutlinedButton(
                onPressed:
                    _isLoading ? null : () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Required Fields Note
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: Colors.orange[700], size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'All fields marked with * are required',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
