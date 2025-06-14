import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/auth/data/models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection reference for users
  CollectionReference get _usersCollection => _firestore.collection('users');

  // Generate custom document ID from username
  String generateCustomDocumentId(String username) {
    return '${username}_info';
  }

  // Create user profile in Firestore with custom document ID
  Future<void> createUserProfile(UserModel user) async {
    try {
      print('🔧 FirestoreService: Starting profile creation for ${user.uid}');
      print('🔧 FirestoreService: Email: ${user.email}');
      print('🔧 FirestoreService: Username: ${user.username}');

      // Generate custom document ID
      final customDocumentId = generateCustomDocumentId(user.username);
      print('🔧 FirestoreService: Custom document ID: $customDocumentId');

      final userData = user.toFirestore();
      print('🔧 FirestoreService: Data to save: $userData');

      // Check if Firestore is properly initialized
      print('🔧 FirestoreService: Firestore instance: $_firestore');
      print('🔧 FirestoreService: Users collection: $_usersCollection');

      // Use custom document ID instead of Firebase UID
      await _usersCollection.doc(customDocumentId).set(userData);
      print(
        '✅ FirestoreService: Profile created successfully with ID: $customDocumentId',
      );

      // Verify the document was created
      final doc = await _usersCollection.doc(customDocumentId).get();
      if (doc.exists) {
        print(
          '✅ FirestoreService: Document verification successful - document exists',
        );
        print('✅ FirestoreService: Document data: ${doc.data()}');
      } else {
        print(
          '❌ FirestoreService: Document verification failed - document does not exist',
        );
      }
    } catch (e, stackTrace) {
      print('❌ FirestoreService: Error creating profile: $e');
      print('❌ FirestoreService: Stack trace: $stackTrace');
      throw Exception('Failed to create user profile: $e');
    }
  }

  // Get user profile from Firestore by Firebase UID
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      // Since document ID is now username_info, we need to query by uid field
      final query = await _usersCollection
          .where('uid', isEqualTo: uid)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return UserModel.fromFirestore(query.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  // Get user profile from Firestore by username (using document ID)
  Future<UserModel?> getUserProfileByUsername(String username) async {
    try {
      final customDocumentId = generateCustomDocumentId(username);
      final doc = await _usersCollection.doc(customDocumentId).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user profile by username: $e');
    }
  }

  // Update user profile in Firestore by Firebase UID
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      // Find the document by uid field first
      final query = await _usersCollection
          .where('uid', isEqualTo: uid)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        await query.docs.first.reference.update(data);
      } else {
        throw Exception('User profile not found for uid: $uid');
      }
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  // Update user's last sign-in time by Firebase UID
  Future<void> updateUserLastSignIn(String uid) async {
    try {
      // Find the document by uid field first
      final query = await _usersCollection
          .where('uid', isEqualTo: uid)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        await query.docs.first.reference.update({
          'lastSignInAt': Timestamp.now(),
          'lastUpdatedAt': Timestamp.now(),
        });
      } else {
        throw Exception('User profile not found for uid: $uid');
      }
    } catch (e) {
      throw Exception('Failed to update last sign-in time: $e');
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

  // Delete user profile by Firebase UID
  Future<void> deleteUserProfile(String uid) async {
    try {
      // Find the document by uid field first
      final query = await _usersCollection
          .where('uid', isEqualTo: uid)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        await query.docs.first.reference.delete();
      } else {
        throw Exception('User profile not found for uid: $uid');
      }
    } catch (e) {
      throw Exception('Failed to delete user profile: $e');
    }
  }

  // Stream user profile changes by Firebase UID
  Stream<UserModel?> streamUserProfile(String uid) {
    return _usersCollection
        .where('uid', isEqualTo: uid)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            return UserModel.fromFirestore(snapshot.docs.first);
          }
          return null;
        });
  }

  // Debug method to test Firestore connectivity
  Future<void> testFirestoreConnection() async {
    try {
      print('🔧 FirestoreService: Testing Firestore connection...');

      // Test write
      final testData = {
        'test': true,
        'timestamp': Timestamp.now(),
        'message': 'Firestore connection test',
      };

      await _firestore.collection('test').doc('connection_test').set(testData);
      print('✅ FirestoreService: Test write successful');

      // Test read
      final doc = await _firestore
          .collection('test')
          .doc('connection_test')
          .get();
      if (doc.exists) {
        print('✅ FirestoreService: Test read successful: ${doc.data()}');
      } else {
        print('❌ FirestoreService: Test read failed - document not found');
      }

      // Clean up
      await _firestore.collection('test').doc('connection_test').delete();
      print('✅ FirestoreService: Test cleanup successful');
    } catch (e, stackTrace) {
      print('❌ FirestoreService: Firestore connection test failed: $e');
      print('❌ FirestoreService: Stack trace: $stackTrace');
    }
  }
}
