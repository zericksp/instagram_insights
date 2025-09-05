// lib/models/auth_response.dart
import 'package:instagram_insights_app/models/user_model.dart';

class AuthResponse {
  final bool success;
  final String? message;
  final UserModel? user;
  final String? accessToken;
  final String? userAccessToken;

  AuthResponse({
    required this.success,
    this.message,
    this.user,
    this.accessToken,
    this.userAccessToken,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] ?? false,
      message: json['message'],
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      accessToken: json['access_token'],
      userAccessToken: json['user_access_token'],
    );
  }
}
