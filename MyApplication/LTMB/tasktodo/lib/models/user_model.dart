import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String username;
  final String password;
  final String email;
  final String? avatar;
  final DateTime createdAt;
  final DateTime lastActive;

  UserModel({
    required this.id,
    required this.username,
    required this.password,
    required this.email,
    this.avatar,
    required this.createdAt,
    required this.lastActive,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      id: documentId,
      username: map['name'] ?? '', // đổi từ 'username' sang 'name'
      password: map['password'] ?? '',
      email: map['email'] ?? '',
      avatar: map['avatar']?.toString(),
      createdAt: map['createdAt'] != null ? (map['createdAt'] as Timestamp).toDate() : DateTime.now(),
      lastActive: map['lastActive'] != null ? (map['lastActive'] as Timestamp).toDate() : DateTime.now(),
    );
  }
}
