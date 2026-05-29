import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/electronics_item.dart';
import '../providers/electronics_provider.dart';
import '../utils/price_utils.dart';

class AddEditScreen extends StatefulWidget {
  final ElectronicsItem? item;

  const AddEditScreen({super.key, this.item});

  @override
  State<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _wholesalerController;
  late TextEditingController _costPriceController;
  late TextEditingController _markupMultiplierController;
  late TextEditingController _sellingPriceController;
  late TextEditingController _locationController;
  late TextEditingController _quantityController;
  double _decodedCost = 0;
  double _decodedMarkup = 1.0;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _wholesalerController =
        TextEditingController(text: widget.item?.wholesalerName ?? '');

    // Set controllers with alphabets instead of numbers
    _costPriceController = TextEditingController(
        text: widget.item != null
            ? PriceUtils.encode(widget.item!.costPrice)
            : '');
    _markupMultiplierController = TextEditingController(
        text: widget.item != null
            ? PriceUtils.encode(widget.item!.markupMultiplier)
            : 'L.B'); // 'L.B' is '1.0'

    _sellingPriceController =
        TextEditingController(text: widget.item?.sellingPrice.toString() ?? '');
    _locationController =
        TextEditingController(text: widget.item?.location ?? '');
    _quantityController =
        TextEditingController(text: widget.item?.quantity.toString() ?? '0');

    if (widget.item != null) {
      _decodedCost = widget.item!.costPrice;
      _decodedMarkup = widget.item!.markupMultiplier;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _wholesalerController.dispose();
    _costPriceController.dispose();
    _markupMultiplierController.dispose();
    _sellingPriceController.dispose();
    _locationController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _onPriceChanged() {
    final costInput = _costPriceController.text;
    final markupInput = _markupMultiplierController.text;

    setState(() {
      _decodedCost = PriceUtils.decode(costInput);
      _decodedMarkup = PriceUtils.decode(markupInput);
      final selling =
          PriceUtils.calculateSellingPrice(_decodedCost, _decodedMarkup);
      _sellingPriceController.text = selling.toStringAsFixed(2);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.item != null;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(isEditing ? 'Update Product' : 'New Product'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Basic Information'),
              _buildTextField(_nameController, 'Electronics Name',
                  Icons.inventory_2_rounded),
              const SizedBox(height: 16),
              _buildTextField(_wholesalerController, 'Wholesaler Name',
                  Icons.business_rounded),
              const SizedBox(height: 32),
              _buildSectionTitle('Pricing & Inventory'),
              Row(
                children: [
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(_costPriceController, 'Cost Code',
                          Icons.payments_rounded,
                          isNumber:
                              false, // Changed to false to allow alphabets
                          onChanged: (_) => _onPriceChanged()),
                      Padding(
                        padding: const EdgeInsets.only(left: 12, top: 4),
                        child: Text(
                            'Value: ₹${_decodedCost.toStringAsFixed(0)}',
                            style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                      ),
                    ],
                  )),
                  const SizedBox(width: 16),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(_markupMultiplierController,
                          'Markup Code', Icons.trending_up_rounded,
                          isNumber:
                              false, // Changed to false to allow alphabets
                          onChanged: (_) => _onPriceChanged()),
                      Padding(
                        padding: const EdgeInsets.only(left: 12, top: 4),
                        child: Text(
                            'Value: x${_decodedMarkup.toStringAsFixed(2)}',
                            style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                      ),
                    ],
                  )),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(_sellingPriceController, 'Selling Price (Auto)',
                  Icons.sell_rounded,
                  isNumber: true, isReadOnly: true),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                      child: _buildTextField(_quantityController, 'Stock Qty',
                          Icons.numbers_rounded,
                          isNumber: true)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildTextField(_locationController, 'Storage',
                          Icons.location_on_rounded)),
                ],
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final item = ElectronicsItem(
                        id: widget.item?.id,
                        name: _nameController.text,
                        wholesalerName: _wholesalerController.text,
                        costPrice: PriceUtils.decode(_costPriceController.text),
                        markupMultiplier:
                            PriceUtils.decode(_markupMultiplierController.text),
                        sellingPrice:
                            double.parse(_sellingPriceController.text),
                        location: _locationController.text,
                        quantity: int.parse(_quantityController.text),
                      );

                      if (isEditing) {
                        context.read<ElectronicsProvider>().updateItem(item);
                      } else {
                        context.read<ElectronicsProvider>().addItem(item);
                      }
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(isEditing ? 'Update Product' : 'Create Product',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 16),
      child: Text(title,
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey)),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {bool isNumber = false,
      bool isReadOnly = false,
      Function(String)? onChanged}) {
    return TextFormField(
      controller: controller,
      readOnly: isReadOnly,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        filled: true,
        fillColor: isReadOnly ? Colors.grey[100] : Colors.white,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.blue, width: 1)),
      ),
      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
    );
  }
}
