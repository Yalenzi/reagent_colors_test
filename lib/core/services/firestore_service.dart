import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/auth/data/models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection reference for users
  CollectionReference get _usersCollection => _firestore.collection('users');

  // Create user profile in Firestore
  Future<void> createUserProfile(UserModel user) async {
    try {
      print('🔧 FirestoreService: Creating profile for ${user.uid}');
      print('🔧 FirestoreService: Data: ${user.toFirestore()}');
      await _usersCollection.doc(user.uid).set(user.toFirestore());
      print('✅ FirestoreService: Profile created successfully');
    } catch (e) {
      print('❌ FirestoreService: Error creating profile: $e');
      throw Exception('Failed to create user profile: $e');
    }
  }

  // Get user profile from Firestore
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _usersCollection.doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  // Update user profile in Firestore
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      await _usersCollection.doc(uid).update(data);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  // Ensure user profile exists (create minimal doc if missing)
  Future<void> ensureUserProfileExists({
    required String uid,
    required String email,
    String? username,
    String? displayName,
    String? photoUrl,
    bool? isEmailVerified,
  }) async {
    try {
      final docRef = _usersCollection.doc(uid);
      final doc = await docRef.get();
      if (!doc.exists) {
        await docRef.set({
          'email': email,
          'username': (username ?? email.split('@').first).toString(),
          'registeredAt': Timestamp.now(),
          'photoUrl': photoUrl,
          'displayName': displayName,
          'isEmailVerified': isEmailVerified ?? false,
        });
      } else {
        // Merge a few fields that can change over time
        await docRef.set({
          'email': email,
          'photoUrl': photoUrl,
          'displayName': displayName,
          'isEmailVerified': isEmailVerified,
        }, SetOptions(merge: true));
      }
    } catch (e) {
      throw Exception('Failed to ensure user profile: $e');
    }
  }

  // Check if username is available
  Future<bool> isUsernameAvailable(String username) async {
    try {
      final query = await _usersCollection
          .where('username', isEqualTo: username)
          .limit(1)
          .get();
      return query.docs.isEmpty;
    } catch (e) {
      throw Exception('Failed to check username availability: $e');
    }
  }

  // Delete user profile
  Future<void> deleteUserProfile(String uid) async {
    try {
      await _usersCollection.doc(uid).delete();
    } catch (e) {
      throw Exception('Failed to delete user profile: $e');
    }
  }

  // Stream user profile changes
  Stream<UserModel?> streamUserProfile(String uid) {
    return _usersCollection.doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    });
  }
}
