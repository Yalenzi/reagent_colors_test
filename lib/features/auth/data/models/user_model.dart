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

  // Additional recommended fields based on Firebase best practices
  final String? phoneNumber; // From Firebase Auth
  final DateTime? lastSignInAt; // User activity tracking
  final List<String>
  signInMethods; // Track how user signed in (email, google, etc.)
  final String? preferredLanguage; // For localization
  final Map<String, dynamic>? customClaims; // For role-based access
  final bool isActive; // Account status
  final String? timezone; // User timezone
  final Map<String, dynamic>? preferences; // User app preferences
  final DateTime? lastUpdatedAt; // Profile update tracking

  const UserModel({
    required this.uid,
    required this.email,
    required this.username,
    required this.registeredAt,
    this.photoUrl,
    this.displayName,
    this.isEmailVerified = false,
    this.phoneNumber,
    this.lastSignInAt,
    this.signInMethods = const [],
    this.preferredLanguage,
    this.customClaims,
    this.isActive = true,
    this.timezone,
    this.preferences,
    this.lastUpdatedAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      username: data['username'] ?? '',
      registeredAt: (data['registeredAt'] as Timestamp).toDate(),
      photoUrl: data['photoUrl'],
      displayName: data['displayName'],
      isEmailVerified: data['isEmailVerified'] ?? false,
      phoneNumber: data['phoneNumber'],
      lastSignInAt: data['lastSignInAt'] != null
          ? (data['lastSignInAt'] as Timestamp).toDate()
          : null,
      signInMethods: List<String>.from(data['signInMethods'] ?? []),
      preferredLanguage: data['preferredLanguage'],
      customClaims: data['customClaims'],
      isActive: data['isActive'] ?? true,
      timezone: data['timezone'],
      preferences: data['preferences'],
      lastUpdatedAt: data['lastUpdatedAt'] != null
          ? (data['lastUpdatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'registeredAt': Timestamp.fromDate(registeredAt),
      'photoUrl': photoUrl,
      'displayName': displayName,
      'isEmailVerified': isEmailVerified,
      'phoneNumber': phoneNumber,
      'lastSignInAt': lastSignInAt != null
          ? Timestamp.fromDate(lastSignInAt!)
          : null,
      'signInMethods': signInMethods,
      'preferredLanguage': preferredLanguage,
      'customClaims': customClaims,
      'isActive': isActive,
      'timezone': timezone,
      'preferences': preferences,
      'lastUpdatedAt': lastUpdatedAt != null
          ? Timestamp.fromDate(lastUpdatedAt!)
          : null,
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
      phoneNumber: phoneNumber,
      lastSignInAt: lastSignInAt,
      signInMethods: signInMethods,
      preferredLanguage: preferredLanguage,
      customClaims: customClaims,
      isActive: isActive,
      timezone: timezone,
      preferences: preferences,
      lastUpdatedAt: lastUpdatedAt,
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
      phoneNumber: entity.phoneNumber,
      lastSignInAt: entity.lastSignInAt,
      signInMethods: entity.signInMethods,
      preferredLanguage: entity.preferredLanguage,
      customClaims: entity.customClaims,
      isActive: entity.isActive,
      timezone: entity.timezone,
      preferences: entity.preferences,
      lastUpdatedAt: entity.lastUpdatedAt,
    );
  }

  // Helper method to create from Firebase User
  factory UserModel.fromFirebaseUser({
    required String uid,
    required String email,
    required String username,
    String? photoUrl,
    String? displayName,
    bool isEmailVerified = false,
    String? phoneNumber,
    List<String> signInMethods = const [],
    String? preferredLanguage,
    String? timezone,
  }) {
    final now = DateTime.now();
    return UserModel(
      uid: uid,
      email: email,
      username: username,
      registeredAt: now,
      photoUrl: photoUrl,
      displayName: displayName,
      isEmailVerified: isEmailVerified,
      phoneNumber: phoneNumber,
      lastSignInAt: now,
      signInMethods: signInMethods,
      preferredLanguage: preferredLanguage,
      isActive: true,
      timezone: timezone,
      lastUpdatedAt: now,
    );
  }

  // Copy method for updates
  UserModel copyWith({
    String? uid,
    String? email,
    String? username,
    DateTime? registeredAt,
    String? photoUrl,
    String? displayName,
    bool? isEmailVerified,
    String? phoneNumber,
    DateTime? lastSignInAt,
    List<String>? signInMethods,
    String? preferredLanguage,
    Map<String, dynamic>? customClaims,
    bool? isActive,
    String? timezone,
    Map<String, dynamic>? preferences,
    DateTime? lastUpdatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      username: username ?? this.username,
      registeredAt: registeredAt ?? this.registeredAt,
      photoUrl: photoUrl ?? this.photoUrl,
      displayName: displayName ?? this.displayName,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      lastSignInAt: lastSignInAt ?? this.lastSignInAt,
      signInMethods: signInMethods ?? this.signInMethods,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      customClaims: customClaims ?? this.customClaims,
      isActive: isActive ?? this.isActive,
      timezone: timezone ?? this.timezone,
      preferences: preferences ?? this.preferences,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    );
  }
}
