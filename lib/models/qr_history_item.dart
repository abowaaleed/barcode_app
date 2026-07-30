import 'qr_type.dart';

class QrHistoryItem {
  final String id;
  final QrDataType type;
  final Map<String, dynamic> data;
  final String generatedData;
  final DateTime createdAt;

  QrHistoryItem({
    required this.id,
    required this.type,
    required this.data,
    required this.generatedData,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'data': data,
    'generatedData': generatedData,
    'createdAt': createdAt.toIso8601String(),
  };

  factory QrHistoryItem.fromJson(Map<String, dynamic> json) => QrHistoryItem(
    id: json['id'] as String,
    type: QrDataType.values.firstWhere((t) => t.name == json['type']),
    data: Map<String, dynamic>.from(json['data'] as Map),
    generatedData: json['generatedData'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}
