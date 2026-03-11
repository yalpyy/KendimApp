/// Membership status derived from is_premium + premium_expires_at.
enum MembershipStatus {
  /// No premium subscription.
  free,

  /// Active premium subscription.
  premium,

  /// Premium subscription has expired.
  expired,
}

class UserEntity {
  const UserEntity({
    required this.id,
    required this.isPremium,
    required this.premiumMissTokens,
    this.email,
    this.displayName,
    this.isAnonymous = true,
    this.emailVerified = false,
    this.isAdmin = false,
    this.premiumExpiresAt,
    this.premiumStartedAt,
  });

  final String id;
  final bool isPremium;
  final int premiumMissTokens;
  final String? email;
  final String? displayName;
  final bool isAnonymous;
  final bool emailVerified;
  final bool isAdmin;
  final DateTime? premiumExpiresAt;
  final DateTime? premiumStartedAt;

  /// Computed membership status based on is_premium + expiry date.
  MembershipStatus get membershipStatus {
    if (!isPremium) return MembershipStatus.free;
    if (premiumExpiresAt == null) return MembershipStatus.premium; // lifetime
    if (premiumExpiresAt!.isAfter(DateTime.now())) {
      return MembershipStatus.premium;
    }
    return MembershipStatus.expired;
  }

  /// Whether premium features should be accessible right now.
  bool get hasPremiumAccess => membershipStatus == MembershipStatus.premium;

  UserEntity copyWith({
    String? id,
    bool? isPremium,
    int? premiumMissTokens,
    String? email,
    String? displayName,
    bool? isAnonymous,
    bool? emailVerified,
    bool? isAdmin,
    DateTime? premiumExpiresAt,
    DateTime? premiumStartedAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      isPremium: isPremium ?? this.isPremium,
      premiumMissTokens: premiumMissTokens ?? this.premiumMissTokens,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      emailVerified: emailVerified ?? this.emailVerified,
      isAdmin: isAdmin ?? this.isAdmin,
      premiumExpiresAt: premiumExpiresAt ?? this.premiumExpiresAt,
      premiumStartedAt: premiumStartedAt ?? this.premiumStartedAt,
    );
  }
}
