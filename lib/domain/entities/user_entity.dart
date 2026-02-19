class UserEntity {
  const UserEntity({
    required this.id,
    required this.isPremium,
    required this.premiumMissTokens,
    this.email,
    this.displayName,
    this.isAnonymous = true,
    this.emailVerified = false,
  });

  final String id;
  final bool isPremium;
  final int premiumMissTokens;
  final String? email;
  final String? displayName;
  final bool isAnonymous;
  final bool emailVerified;

  UserEntity copyWith({
    String? id,
    bool? isPremium,
    int? premiumMissTokens,
    String? email,
    String? displayName,
    bool? isAnonymous,
    bool? emailVerified,
  }) {
    return UserEntity(
      id: id ?? this.id,
      isPremium: isPremium ?? this.isPremium,
      premiumMissTokens: premiumMissTokens ?? this.premiumMissTokens,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      emailVerified: emailVerified ?? this.emailVerified,
    );
  }
}
