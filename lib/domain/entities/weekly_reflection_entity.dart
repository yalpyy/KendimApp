class WeeklyReflectionEntity {
  const WeeklyReflectionEntity({
    required this.id,
    required this.userId,
    required this.weekStartDate,
    required this.content,
    required this.isArchived,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final DateTime weekStartDate;
  final String content;
  final bool isArchived;
  final DateTime createdAt;
}
