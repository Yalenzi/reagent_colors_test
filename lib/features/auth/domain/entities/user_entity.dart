class UserEntity {
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

  const UserEntity({
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserEntity &&
        other.uid == uid &&
        other.email == email &&
        other.username == username &&
        other.registeredAt == registeredAt &&
        other.photoUrl == photoUrl &&
        other.displayName == displayName &&
        other.isEmailVerified == isEmailVerified &&
        other.phoneNumber == phoneNumber &&
        other.lastSignInAt == lastSignInAt &&
        other.signInMethods.length == signInMethods.length &&
        other.preferredLanguage == preferredLanguage &&
        other.isActive == isActive &&
        other.timezone == timezone &&
        other.lastUpdatedAt == lastUpdatedAt;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        email.hashCode ^
        username.hashCode ^
        registeredAt.hashCode ^
        photoUrl.hashCode ^
        displayName.hashCode ^
        isEmailVerified.hashCode ^
        phoneNumber.hashCode ^
        lastSignInAt.hashCode ^
        signInMethods.hashCode ^
        preferredLanguage.hashCode ^
        isActive.hashCode ^
        timezone.hashCode ^
        lastUpdatedAt.hashCode;
  }

  @override
  String toString() {
    return 'UserEntity(uid: $uid, email: $email, username: $username, registeredAt: $registeredAt, photoUrl: $photoUrl, displayName: $displayName, isEmailVerified: $isEmailVerified, phoneNumber: $phoneNumber, lastSignInAt: $lastSignInAt, signInMethods: $signInMethods, preferredLanguage: $preferredLanguage, isActive: $isActive, timezone: $timezone, lastUpdatedAt: $lastUpdatedAt)';
  }

  // Copy method for updates
  UserEntity copyWith({
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
    return UserEntity(
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
