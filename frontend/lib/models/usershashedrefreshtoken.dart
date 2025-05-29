class UserHashedRefreshToken {
  final String userId;
  final String? hashedRefreshToken;
  final int? expiresAt; // menggunakan BIGINT untuk waktu kedaluwarsa
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? createdBy;
  final String? updatedBy;

  UserHashedRefreshToken({
    required this.userId,
    this.hashedRefreshToken,
    this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.createdBy,
    this.updatedBy,
  });

  factory UserHashedRefreshToken.fromJson(Map<String, dynamic> json) {
    return UserHashedRefreshToken(
      userId: json['user_id'],
      hashedRefreshToken: json['hashed_refresh_token'],
      expiresAt: json['expires_at'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at']) : null,
      createdBy: json['created_by'],
      updatedBy: json['updated_by'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'hashed_refresh_token': hashedRefreshToken,
      'expires_at': expiresAt,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'created_by': createdBy,
      'updated_by': updatedBy,
    };
  }
}
