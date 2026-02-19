class UserEntity {
  const UserEntity({
    required this.id,
    required this.isPremium,
    required this.premiumMissTokens,
    this.email,
    this.isAnonymous = true,
  });

  final String id;
  final bool isPremium;
  final int premiumMissTokens;
  final String? email;
  final bool isAnonymous;

  UserEntity copyWith({
    String? id,
    bool? isPremium,
    int? premiumMissTokens,
    String? email,
    bool? isAnonymous,
  }) {
    return UserEntity(
      id: id ?? this.id,
      isPremium: isPremium ?? this.isPremium,
      premiumMissTokens: premiumMissTokens ?? this.premiumMissTokens,
      email: email ?? this.email,
      isAnonymous: isAnonymous ?? this.isAnonymous,
    );
  }
}
