import '../../domain/entities/history_item_entity.dart';

class HistoryItemModel extends HistoryItemEntity {
  const HistoryItemModel({
    required super.id,
    required super.type,
    required super.title,
    required super.description,
    required super.timestamp,
  });

  factory HistoryItemModel.fromEntity(HistoryItemEntity entity) {
    return HistoryItemModel(
      id: entity.id,
      type: entity.type,
      title: entity.title,
      description: entity.description,
      timestamp: entity.timestamp,
    );
  }

  factory HistoryItemModel.fromJson(Map<String, dynamic> json) {
    return HistoryItemModel(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
