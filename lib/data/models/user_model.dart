import 'package:kendin/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.isPremium,
    required super.premiumMissTokens,
    super.email,
    super.isAnonymous,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      isPremium: json['is_premium'] as bool? ?? false,
      premiumMissTokens: json['premium_miss_tokens'] as int? ?? 3,
      email: json['email'] as String?,
      isAnonymous: json['is_anonymous'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'is_premium': isPremium,
      'premium_miss_tokens': premiumMissTokens,
    };
  }
}
