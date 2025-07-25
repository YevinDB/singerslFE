import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:singer_sl/models/product.dart';
import 'package:singer_sl/services/product_service.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;

  const EditProductScreen({Key? key, required this.product}) : super(key: key);

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _productCodeController;
  late TextEditingController _productNameController;
  late TextEditingController _priceController;
  final ProductService _productService = ProductService();

  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _productCodeController =
        TextEditingController(text: widget.product.productCode);
    _productNameController =
        TextEditingController(text: widget.product.productName);
    _priceController =
        TextEditingController(text: widget.product.price.toString());

    _productCodeController.addListener(_onFieldChanged);
    _productNameController.addListener(_onFieldChanged);
    _priceController.addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    _productCodeController.dispose();
    _productNameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    final hasChanges =
        _productCodeController.text != widget.product.productCode ||
            _productNameController.text != widget.product.productName ||
            _priceController.text != widget.product.price.toString();

    if (hasChanges != _hasChanges) {
      setState(() {
        _hasChanges = hasChanges;
      });
    }
  }

  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_hasChanges) {
      _showSnackBar('No changes to save', Colors.orange);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedProduct = Product(
        id: widget.product.id,
        productCode: _productCodeController.text.trim(),
        productName: _productNameController.text.trim(),
        price: double.parse(_priceController.text.trim()),
      );

      final response = await _productService.updateProduct(
          updatedProduct.id!, updatedProduct);

      if (response.success) {
        _showSnackBar('Product updated successfully!', Colors.green);
        Navigator.of(context).pop(true);
      } else {
        String errorMessage = response.message;
        if (response.errors.isNotEmpty) {
          errorMessage += '\n' + response.errors.join('\n');
        }
        _showSnackBar(errorMessage, Colors.red);
      }
    } catch (e) {
      _showSnackBar('Failed to update product: ${e.toString()}', Colors.red);
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
        title: Text('Edit Product'),
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
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.yellow[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.yellow[200]!),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.edit,
                      size: 48,
                      color: Colors.yellow[800],
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Edit Product',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.yellow[800],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Update the product details below',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32),
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
              ElevatedButton(
                onPressed: (_isLoading || !_hasChanges) ? null : _updateProduct,
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
                          Text('Saving Changes...'),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save),
                          SizedBox(width: 8),
                          Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
              SizedBox(height: 16),
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
