import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/electronics_item.dart';
import '../models/bill.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'electronics_items';
  final String _billsCollection = 'bills';

  Future<void> addItem(ElectronicsItem item) async {
    await _firestore.collection(_collection).add(item.toMap());
  }

  Future<List<ElectronicsItem>> getItems() async {
    final snapshot = await _firestore.collection(_collection).get();
    return snapshot.docs
        .map((doc) => ElectronicsItem.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> updateItem(ElectronicsItem item) async {
    if (item.id != null) {
      await _firestore
          .collection(_collection)
          .doc(item.id)
          .update(item.toMap());
    }
  }

  Future<void> deleteItem(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  Future<List<ElectronicsItem>> searchItems(String query) async {
    final snapshot = await _firestore.collection(_collection).get();
    final items = snapshot.docs
        .map((doc) => ElectronicsItem.fromMap(doc.data(), doc.id))
        .toList();

    if (query.isEmpty) return items;

    return items
        .where((item) => item.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  Future<void> createBill(Bill bill) async {
    try {
      await _firestore.runTransaction((transaction) async {
        // 1. ALL READS FIRST (Strictly required for Firestore Web)
        final Map<DocumentReference, int> stockUpdates = {};
        
        for (var item in bill.items) {
          final productRef = _firestore.collection(_collection).doc(item.productId);
          final productSnapshot = await transaction.get(productRef);

          if (!productSnapshot.exists) {
            throw 'Product ${item.productName} not found in inventory';
          }

          final data = productSnapshot.data() as Map<String, dynamic>;
          final currentQuantity = (data['quantity'] ?? 0).toInt();
          final newQuantity = currentQuantity - item.quantity;

          if (newQuantity < 0) {
            throw 'Insufficient stock for ${item.productName}. Current: $currentQuantity, Requested: ${item.quantity}';
          }
          
          stockUpdates[productRef] = newQuantity;
        }

        // 2. ALL WRITES AFTER READS
        // Create the bill record
        final billRef = _firestore.collection(_billsCollection).doc();
        transaction.set(billRef, bill.toMap());

        // Update all stock quantities
        stockUpdates.forEach((ref, newQty) {
          transaction.update(ref, {'quantity': newQty});
        });
      });
    } catch (e) {
      debugPrint('Transaction Failed: $e');
      // On Web, Firestore errors can be wrapped. We extract the message for the UI.
      String message = e.toString();
      if (message.contains(']')) {
        message = message.split(']').last.trim();
      }
      throw message.replaceFirst('Exception: ', '');
    }
  }

  Future<List<Bill>> getBills() async {
    final snapshot = await _firestore
        .collection(_billsCollection)
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => Bill.fromMap(doc.data(), doc.id))
        .toList();
  }
}
