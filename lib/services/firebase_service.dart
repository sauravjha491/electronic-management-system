import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/electronics_item.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'electronics_items';

  Future<void> addItem(ElectronicsItem item) async {
    await _firestore.collection(_collection).add(item.toMap());
  }

  Future<List<ElectronicsItem>> getItems() async {
    final snapshot = await _firestore.collection(_collection).get();
    return snapshot.docs.map((doc) => ElectronicsItem.fromMap(doc.data(), doc.id)).toList();
  }

  Future<void> updateItem(ElectronicsItem item) async {
    if (item.id != null) {
      await _firestore.collection(_collection).doc(item.id).update(item.toMap());
    }
  }

  Future<void> deleteItem(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  Future<List<ElectronicsItem>> searchItems(String query) async {
    // Note: Firestore doesn't support full-text search or partial matches natively with 'LIKE'
    // For simplicity, we'll fetch all and filter client-side, or use simple range query if possible.
    // Real-world apps might use Algolia or fetch all for small datasets.
    final snapshot = await _firestore.collection(_collection).get();
    final items = snapshot.docs.map((doc) => ElectronicsItem.fromMap(doc.data(), doc.id)).toList();
    
    if (query.isEmpty) return items;
    
    return items.where((item) => item.name.toLowerCase().contains(query.toLowerCase())).toList();
  }
}
