// ==============================================================================
// ESTRUTURA COMPLETA DO SISTEMA DE LOGIN
// ==============================================================================

// ===== 1. MODELS =====
// lib/models/user_model.dart
class UserModel {
  final String id;
  final String email;
  final String name;
  final String? instagramToken;
  final String? instagramUserId;
  final DateTime? tokenExpiry;
  final bool isActive;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.instagramToken,
    this.instagramUserId,
    this.tokenExpiry,
    this.isActive = true,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      email: json['email'],
      name: json['name'],
      instagramToken: json['instagram_token'],
      instagramUserId: json['instagram_user_id'],
      tokenExpiry: json['token_expiry'] != null 
          ? DateTime.parse(json['token_expiry']) 
          : null,
      isActive: json['is_active'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'instagram_token': instagramToken,
      'instagram_user_id': instagramUserId,
      'token_expiry': tokenExpiry?.toIso8601String(),
      'is_active': isActive ? 1 : 0,
    };
  }
}