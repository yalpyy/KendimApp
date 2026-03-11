import 'package:kendin/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.isPremium,
    required super.premiumMissTokens,
    super.email,
    super.displayName,
    super.isAnonymous,
    super.emailVerified,
    super.isAdmin,
    super.premiumExpiresAt,
    super.premiumStartedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      isPremium: json['is_premium'] as bool? ?? false,
      premiumMissTokens: json['premium_miss_tokens'] as int? ?? 3,
      email: json['email'] as String?,
      displayName: json['display_name'] as String?,
      isAnonymous: json['is_anonymous'] as bool? ?? true,
      emailVerified: json['email_verified'] as bool? ?? false,
      isAdmin: json['is_admin'] as bool? ?? false,
      premiumExpiresAt: json['premium_expires_at'] != null
          ? DateTime.tryParse(json['premium_expires_at'] as String)
          : null,
      premiumStartedAt: json['premium_started_at'] != null
          ? DateTime.tryParse(json['premium_started_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'is_premium': isPremium,
      'premium_miss_tokens': premiumMissTokens,
      'display_name': displayName,
    };
  }
}
