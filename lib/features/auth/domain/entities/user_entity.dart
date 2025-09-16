class UserEntity {
  final String uid;
  final String email;
  final String username;
  final DateTime registeredAt;
  final String? photoUrl;
  final String? displayName;
  final bool isEmailVerified;

  const UserEntity({
    required this.uid,
    required this.email,
    required this.username,
    required this.registeredAt,
    this.photoUrl,
    this.displayName,
    this.isEmailVerified = false,
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
        other.isEmailVerified == isEmailVerified;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        email.hashCode ^
        username.hashCode ^
        registeredAt.hashCode ^
        photoUrl.hashCode ^
        displayName.hashCode ^
        isEmailVerified.hashCode;
  }

  @override
  String toString() {
    return 'UserEntity(uid: $uid, email: $email, username: $username, registeredAt: $registeredAt, photoUrl: $photoUrl, displayName: $displayName, isEmailVerified: $isEmailVerified)';
  }
}
