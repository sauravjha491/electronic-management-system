class BillItem {
  final String productId;
  final String productName;
  final double price;
  final int quantity;

  BillItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'price': price,
      'quantity': quantity,
    };
  }

  factory BillItem.fromMap(Map<String, dynamic> map) {
    return BillItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 0,
    );
  }

  double get total => price * quantity;
}

class Bill {
  final String? id;
  final String customerName;
  final String customerPhone;
  final List<BillItem> items;
  final DateTime date;
  final double totalAmount;

  Bill({
    this.id,
    required this.customerName,
    required this.customerPhone,
    required this.items,
    required this.date,
    required this.totalAmount,
  });

  Map<String, dynamic> toMap() {
    return {
      'customerName': customerName,
      'customerPhone': customerPhone,
      'items': items.map((item) => item.toMap()).toList(),
      'date': date.toIso8601String(),
      'totalAmount': totalAmount,
    };
  }

  factory Bill.fromMap(Map<String, dynamic> map, String id) {
    return Bill(
      id: id,
      customerName: map['customerName'] ?? '',
      customerPhone: map['customerPhone'] ?? '',
      items: (map['items'] as List<dynamic>?)
              ?.map((item) => BillItem.fromMap(item))
              .toList() ??
          [],
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
    );
  }
}
