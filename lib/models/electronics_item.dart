import '../utils/price_utils.dart';

class ElectronicsItem {
  final String? id;
  final String name;
  final String wholesalerName;
  final double costPrice;
  final double sellingPrice;
  final double markupMultiplier;
  final String location;
  final int quantity;

  ElectronicsItem({
    this.id,
    required this.name,
    required this.wholesalerName,
    required this.costPrice,
    required this.sellingPrice,
    required this.markupMultiplier,
    required this.location,
    this.quantity = 0,
  });

  String get encodedCostPrice => PriceUtils.encode(costPrice);
  String get encodedMarkupMultiplier => PriceUtils.encode(markupMultiplier);

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'wholesalerName': wholesalerName,
      'costPrice': costPrice,
      'sellingPrice': sellingPrice,
      'markupMultiplier': markupMultiplier,
      'location': location,
      'quantity': quantity,
    };
  }

  factory ElectronicsItem.fromMap(Map<String, dynamic> map, String id) {
    return ElectronicsItem(
      id: id,
      name: map['name'] ?? '',
      wholesalerName: map['wholesalerName'] ?? '',
      costPrice: (map['costPrice'] ?? 0).toDouble(),
      sellingPrice: (map['sellingPrice'] ?? 0).toDouble(),
      markupMultiplier: (map['markupMultiplier'] ?? map['markupPrice'] ?? 1.0).toDouble(),
      location: map['location'] ?? '',
      quantity: map['quantity'] ?? 0,
    );
  }

  ElectronicsItem copyWith({
    String? id,
    String? name,
    String? wholesalerName,
    double? costPrice,
    double? sellingPrice,
    double? markupMultiplier,
    String? location,
    int? quantity,
  }) {
    return ElectronicsItem(
      id: id ?? this.id,
      name: name ?? this.name,
      wholesalerName: wholesalerName ?? this.wholesalerName,
      costPrice: costPrice ?? this.costPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      markupMultiplier: markupMultiplier ?? this.markupMultiplier,
      location: location ?? this.location,
      quantity: quantity ?? this.quantity,
    );
  }
}
