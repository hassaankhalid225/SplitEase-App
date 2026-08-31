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
  final double tipPercent;
  final String? receiptImagePath;
  final String? payerId;
  final DateTime createdAt;

  SessionModel({
    required this.id,
    required this.name,
    required this.currency,
    required this.people,
    required this.items,
    required this.taxPercent,
    required this.serviceChargePercent,
    this.tipPercent = 0.0,
    this.receiptImagePath,
    this.payerId,
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
      'tipPercent': tipPercent,
      'receiptImagePath': receiptImagePath,
      'payerId': payerId,
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
      tipPercent: (json['tipPercent'] as num?)?.toDouble() ?? 0.0,
      receiptImagePath: json['receiptImagePath'],
      payerId: json['payerId'],
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
    double? tipPercent,
    String? receiptImagePath,
    String? payerId,
    bool clearPayerId = false,
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
      tipPercent: tipPercent ?? this.tipPercent,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
      payerId: clearPayerId ? null : (payerId ?? this.payerId),
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
