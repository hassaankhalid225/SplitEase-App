import 'person_model.dart';
import 'item_model.dart';

class SessionModel {
  final String id;
  final String name;
  final String currency;
  final List<PersonModel> people;
  final List<ItemModel> items;
  final double taxPercent;
  final double serviceChargePercent;
  final String? receiptImagePath;
  final DateTime createdAt;

  SessionModel({
    required this.id,
    required this.name,
    required this.currency,
    required this.people,
    required this.items,
    required this.taxPercent,
    required this.serviceChargePercent,
    this.receiptImagePath,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'currency': currency,
      'people': people.map((p) => p.toJson()).toList(),
      'items': items.map((i) => i.toJson()).toList(),
      'taxPercent': taxPercent,
      'serviceChargePercent': serviceChargePercent,
      'receiptImagePath': receiptImagePath,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'],
      name: json['name'],
      currency: json['currency'],
      people: (json['people'] as List).map((p) => PersonModel.fromJson(p)).toList(),
      items: (json['items'] as List).map((i) => ItemModel.fromJson(i)).toList(),
      taxPercent: (json['taxPercent'] as num).toDouble(),
      serviceChargePercent: (json['serviceChargePercent'] as num).toDouble(),
      receiptImagePath: json['receiptImagePath'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  SessionModel copyWith({
    String? id,
    String? name,
    String? currency,
    List<PersonModel>? people,
    List<ItemModel>? items,
    double? taxPercent,
    double? serviceChargePercent,
    String? receiptImagePath,
    DateTime? createdAt,
  }) {
    return SessionModel(
      id: id ?? this.id,
      name: name ?? this.name,
      currency: currency ?? this.currency,
      people: people ?? this.people,
      items: items ?? this.items,
      taxPercent: taxPercent ?? this.taxPercent,
      serviceChargePercent: serviceChargePercent ?? this.serviceChargePercent,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
