import 'package:kendin/domain/entities/weekly_reflection_entity.dart';

class WeeklyReflectionModel extends WeeklyReflectionEntity {
  const WeeklyReflectionModel({
    required super.id,
    required super.userId,
    required super.weekStartDate,
    required super.content,
    required super.isArchived,
    required super.createdAt,
  });

  factory WeeklyReflectionModel.fromJson(Map<String, dynamic> json) {
    return WeeklyReflectionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      weekStartDate: DateTime.parse(json['week_start_date'] as String),
      content: json['content'] as String,
      isArchived: json['is_archived'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'week_start_date': weekStartDate.toIso8601String().split('T').first,
      'content': content,
      'is_archived': isArchived,
    };
  }
}
