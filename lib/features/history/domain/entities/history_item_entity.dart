import 'package:equatable/equatable.dart';

class HistoryItemEntity extends Equatable {
  final String id;
  final String type; // 'text' | 'person' | 'object' | 'navigation'
  final String title;
  final String description;
  final DateTime timestamp;

  const HistoryItemEntity({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, type, title, description, timestamp];
}
