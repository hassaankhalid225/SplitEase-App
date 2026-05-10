class ItemModel {
  final String id;
  final String name;
  final double price;
  final Map<String, double> assignedShares; // personId -> shareMultiplier

  ItemModel({
    required this.id,
    required this.name,
    required this.price,
    required this.assignedShares,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'assignedShares': assignedShares,
    };
  }

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'],
      name: json['name'],
      price: (json['price'] as num).toDouble(),
      assignedShares: Map<String, double>.from(json['assignedShares'].map((k, v) => MapEntry(k, (v as num).toDouble()))),
    );
  }

  ItemModel copyWith({
    String? id,
    String? name,
    double? price,
    Map<String, double>? assignedShares,
  }) {
    return ItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      assignedShares: assignedShares ?? Map.from(this.assignedShares),
    );
  }
}
