import 'package:flutter/material.dart';
import '../models/electronics_item.dart';
import '../models/bill.dart';
import '../services/firebase_service.dart';

class ElectronicsProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  List<ElectronicsItem> _items = [];
  List<Bill> _bills = [];
  bool _isLoading = false;

  List<ElectronicsItem> get items => _items;
  List<Bill> get bills => _bills;
  bool get isLoading => _isLoading;

  Future<void> fetchItems() async {
    _isLoading = true;
    notifyListeners();
    try {
      _items = await _firebaseService.getItems();
    } catch (e) {
      debugPrint('Error fetching items: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addItem(ElectronicsItem item) async {
    try {
      await _firebaseService.addItem(item);
      await fetchItems();
    } catch (e) {
      debugPrint('Error adding item: $e');
    }
  }

  Future<void> updateItem(ElectronicsItem item) async {
    try {
      await _firebaseService.updateItem(item);
      await fetchItems();
    } catch (e) {
      debugPrint('Error updating item: $e');
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      await _firebaseService.deleteItem(id);
      await fetchItems();
    } catch (e) {
      debugPrint('Error deleting item: $e');
    }
  }

  Future<void> searchItems(String query) async {
    _isLoading = true;
    notifyListeners();
    try {
      _items = await _firebaseService.searchItems(query);
    } catch (e) {
      debugPrint('Error searching items: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> createBill(Bill bill) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _firebaseService.createBill(bill);
      await fetchItems(); // Refresh stock
      await fetchBills();
    } catch (e) {
      debugPrint('Error creating bill: $e');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchBills() async {
    try {
      _bills = await _firebaseService.getBills();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching bills: $e');
    }
  }
}
