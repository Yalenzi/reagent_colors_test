import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';

class UserModel {
  final String uid;
  final String email;
  final String username;
  final DateTime registeredAt;
  final String? photoUrl;
  final String? displayName;
  final bool isEmailVerified;

  const UserModel({
    required this.uid,
    required this.email,
    required this.username,
    required this.registeredAt,
    this.photoUrl,
    this.displayName,
    this.isEmailVerified = false,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      username: data['username'] ?? '',
      registeredAt: (data['registeredAt'] as Timestamp).toDate(),
      photoUrl: data['photoUrl'],
      displayName: data['displayName'],
      isEmailVerified: data['isEmailVerified'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'username': username,
      'registeredAt': Timestamp.fromDate(registeredAt),
      'photoUrl': photoUrl,
      'displayName': displayName,
      'isEmailVerified': isEmailVerified,
    };
  }

  UserEntity toEntity() {
    return UserEntity(
      uid: uid,
      email: email,
      username: username,
      registeredAt: registeredAt,
      photoUrl: photoUrl,
      displayName: displayName,
      isEmailVerified: isEmailVerified,
    );
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      uid: entity.uid,
      email: entity.email,
      username: entity.username,
      registeredAt: entity.registeredAt,
      photoUrl: entity.photoUrl,
      displayName: entity.displayName,
      isEmailVerified: entity.isEmailVerified,
    );
  }
}
