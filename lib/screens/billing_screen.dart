import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/electronics_item.dart';
import '../models/bill.dart';
import '../providers/electronics_provider.dart';
import '../services/pdf_service.dart';
import 'package:intl/intl.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final List<BillItem> _selectedItems = [];
  final _quantityController = TextEditingController(text: '1');
  final _productSearchController = TextEditingController();

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _quantityController.dispose();
    _productSearchController.dispose();
    super.dispose();
  }

  void _addItem(ElectronicsItem product) {
    final qty = int.tryParse(_quantityController.text) ?? 1;
    if (qty <= 0) return;

    if (qty > product.quantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Only ${product.quantity} items in stock for ${product.name}')),
      );
      return;
    }

    setState(() {
      // Check if item already exists in bill
      final existingIndex =
          _selectedItems.indexWhere((item) => item.productId == product.id);
      if (existingIndex != -1) {
        final newQty = _selectedItems[existingIndex].quantity + qty;
        if (newQty > product.quantity) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Total quantity exceeds stock for ${product.name}')),
          );
          return;
        }
        _selectedItems[existingIndex] = BillItem(
          productId: product.id!,
          productName: product.name,
          price: product.sellingPrice,
          quantity: newQty,
        );
      } else {
        _selectedItems.add(BillItem(
          productId: product.id!,
          productName: product.name,
          price: product.sellingPrice,
          quantity: qty,
        ));
      }
      _quantityController.text = '1';
    });
  }

  void _updateSelectedItemQuantity(
      int index, int delta, List<ElectronicsItem> products) {
    final item = _selectedItems[index];
    final product = products.firstWhere((p) => p.id == item.productId);
    final newQty = item.quantity + delta;

    if (newQty <= 0) {
      setState(() {
        _selectedItems.removeAt(index);
      });
      return;
    }

    if (newQty > product.quantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Only ${product.quantity} items in stock')),
      );
      return;
    }

    setState(() {
      _selectedItems[index] = BillItem(
        productId: item.productId,
        productName: item.productName,
        price: item.price,
        quantity: newQty,
      );
    });
  }

  double get _totalAmount =>
      _selectedItems.fold(0, (sum, item) => sum + item.total);

  Future<void> _generateBill() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one item')),
      );
      return;
    }

    final bill = Bill(
      customerName: _customerNameController.text,
      customerPhone: _customerPhoneController.text,
      items: _selectedItems,
      date: DateTime.now(),
      totalAmount: _totalAmount,
    );

    try {
      await Provider.of<ElectronicsProvider>(context, listen: false)
          .createBill(bill);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bill generated successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Show PDF
        await PdfService.generateAndPrintBill(bill);

        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString();
        // Clean up common Firebase error prefixes for cleaner UI display
        if (errorMessage.contains(']')) {
          errorMessage = errorMessage.split(']').last.trim();
        }

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Billing Error'),
            content: Text(errorMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ElectronicsProvider>(context);
    final products = provider.items.where((item) => item.quantity > 0).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Bill'),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _customerNameController,
                            decoration: const InputDecoration(
                              labelText: 'Customer Name',
                              prefixIcon: Icon(Icons.person),
                            ),
                            validator: (value) => value == null || value.isEmpty
                                ? 'Required'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _customerPhoneController,
                            decoration: const InputDecoration(
                              labelText: 'Customer Phone',
                              prefixIcon: Icon(Icons.phone),
                            ),
                            keyboardType: TextInputType.phone,
                            validator: (value) => value == null || value.isEmpty
                                ? 'Required'
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text('Search & Add Items',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Autocomplete<ElectronicsItem>(
                            displayStringForOption: (option) => option.name,
                            optionsBuilder:
                                (TextEditingValue textEditingValue) {
                              if (textEditingValue.text == '') {
                                return const Iterable<ElectronicsItem>.empty();
                              }
                              return products.where((product) {
                                return product.name.toLowerCase().contains(
                                    textEditingValue.text.toLowerCase());
                              });
                            },
                            optionsViewBuilder: (context, onSelected, options) {
                              return Align(
                                alignment: Alignment.topLeft,
                                child: Material(
                                  elevation: 4.0,
                                  child: SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.6,
                                    child: ListView.builder(
                                      padding: EdgeInsets.zero,
                                      shrinkWrap: true,
                                      itemCount: options.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        final ElectronicsItem option =
                                            options.elementAt(index);
                                        return ListTile(
                                          title: Text(option.name),
                                          subtitle: Text(
                                              'Stock: ${option.quantity} | Price: ₹${option.sellingPrice}'),
                                          onTap: () => onSelected(option),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                            fieldViewBuilder: (context, controller, focusNode,
                                onFieldSubmitted) {
                              return TextField(
                                controller: controller,
                                focusNode: focusNode,
                                decoration: InputDecoration(
                                  hintText: 'Type to search product...',
                                  prefixIcon: const Icon(Icons.search),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                ),
                              );
                            },
                            onSelected: (ElectronicsItem selection) {
                              _addItem(selection);
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () {
                            int current =
                                int.tryParse(_quantityController.text) ?? 1;
                            if (current > 1) {
                              setState(() {
                                _quantityController.text =
                                    (current - 1).toString();
                              });
                            }
                          },
                        ),
                        SizedBox(
                          width: 50,
                          child: TextFormField(
                            controller: _quantityController,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              labelText: 'Qty',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.zero,
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () {
                            int current =
                                int.tryParse(_quantityController.text) ?? 1;
                            setState(() {
                              _quantityController.text =
                                  (current + 1).toString();
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text('Bill Items',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _selectedItems.length,
                        itemBuilder: (context, index) {
                          final item = _selectedItems[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              title: Text(item.productName),
                              subtitle: Text(
                                  '₹${item.price} x ${item.quantity} = ₹${item.total.toStringAsFixed(2)}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove,
                                        color: Colors.orange),
                                    onPressed: () =>
                                        _updateSelectedItemQuantity(
                                            index, -1, provider.items),
                                  ),
                                  Text('${item.quantity}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  IconButton(
                                    icon: const Icon(Icons.add,
                                        color: Colors.green),
                                    onPressed: () =>
                                        _updateSelectedItemQuantity(
                                            index, 1, provider.items),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline,
                                        color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        _selectedItems.removeAt(index);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const Divider(thickness: 2),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Amount:',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          Text('₹${_totalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _generateBill,
                        icon: const Icon(Icons.picture_as_pdf),
                        label: const Text('GENERATE & PRINT INVOICE',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
