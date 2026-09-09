import 'gas_thresholds.dart';

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String passwordHash;
  final GasThresholds? thresholds;
  final int createdAt;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    required this.createdAt,
    this.thresholds,
  });
  GasThresholds get effectiveThresholds => thresholds ?? GasThresholds.defaults;
 
  UserProfile copyWith({
    String? name,
    String? email,
    String? passwordHash,
    GasThresholds? thresholds,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      thresholds: thresholds ?? this.thresholds,
      createdAt: createdAt,
    );
  }
 
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'passwordHash': passwordHash,
        'thresholds': thresholds?.toJson(),
        'createdAt': createdAt,
      };
 
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      passwordHash: json['passwordHash'] as String,
      thresholds: json['thresholds'] != null
          ? GasThresholds.fromJson(
              json['thresholds'] as Map<String, dynamic>)
          : null,
      createdAt: json['createdAt'] as int,
    );
  }
}