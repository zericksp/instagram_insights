// lib/models/auth_response.dart
import 'package:instagram_insights_app/models/user_model.dart';

class AuthResponse {
  final bool success;
  final String? message;
  final UserModel? user;
  final String? accessToken;

  AuthResponse({
    required this.success,
    this.message,
    this.user,
    this.accessToken,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] ?? false,
      message: json['message'],
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      accessToken: json['access_token'],
    );
  }
}
