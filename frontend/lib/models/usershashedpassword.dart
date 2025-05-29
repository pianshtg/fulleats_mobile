class UserHashedPassword {
  final String userId;
  final String? hashedPassword;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? createdBy;
  final String? updatedBy;

  UserHashedPassword({
    required this.userId,
    this.hashedPassword,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.createdBy,
    this.updatedBy,
  });

  factory UserHashedPassword.fromJson(Map<String, dynamic> json) {
    return UserHashedPassword(
      userId: json['user_id'],
      hashedPassword: json['hashed_password'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      deletedAt:
          json['deleted_at'] != null
              ? DateTime.parse(json['deleted_at'])
              : null,
      createdBy: json['created_by'],
      updatedBy: json['updated_by'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'hashed_password': hashedPassword,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'created_by': createdBy,
      'updated_by': updatedBy,
    };
  }
}
