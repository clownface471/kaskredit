import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'app_user.freezed.dart'; // Ini akan dibuat otomatis
part 'app_user.g.dart';     // Ini juga

@freezed
class AppUser with _$AppUser {
  const factory AppUser({
    required String id,
    required String email,
    required String shopName,
    String? phoneNumber,
    required DateTime createdAt,
    @Default(true) bool isActive,
  }) = _AppUser;

  // Factory constructor untuk membuat dari Firestore
  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AppUser(
      id: doc.id,
      email: data['email'],
      shopName: data['shopName'],
      phoneNumber: data['phoneNumber'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isActive: data['isActive'],
    );
  }

  // Factory constructor untuk membuat dari JSON (diperlukan oleh .g.dart)
  factory AppUser.fromJson(Map<String, dynamic> json) => _$AppUserFromJson(json);
}