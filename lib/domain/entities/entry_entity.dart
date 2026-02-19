class EntryEntity {
  const EntryEntity({
    required this.id,
    required this.userId,
    required this.text,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String text;
  final DateTime createdAt;
}
