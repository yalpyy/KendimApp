import 'package:kendin/domain/entities/entry_entity.dart';

class EntryModel extends EntryEntity {
  const EntryModel({
    required super.id,
    required super.userId,
    required super.text,
    required super.createdAt,
  });

  factory EntryModel.fromJson(Map<String, dynamic> json) {
    return EntryModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      text: json['text'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'text': text,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
