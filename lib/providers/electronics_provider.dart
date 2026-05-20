import 'package:flutter/material.dart';
import '../models/electronics_item.dart';
import '../services/firebase_service.dart';

class ElectronicsProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  List<ElectronicsItem> _items = [];
  bool _isLoading = false;

  List<ElectronicsItem> get items => _items;
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
}
