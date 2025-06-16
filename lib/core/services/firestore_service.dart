import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/auth/data/models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Cache for user profiles to reduce database calls
  final Map<String, UserModel> _userCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiry = Duration(minutes: 5);

  // Collection reference for users
  CollectionReference get _usersCollection => _firestore.collection('users');

  // Generate custom document ID from username
  String generateCustomDocumentId(String username) {
    return '${username}_info';
  }

  // Clear cache for a specific user
  void _clearUserCache(String uid) {
    _userCache.remove(uid);
    _cacheTimestamps.remove(uid);
  }

  // Check if cache is valid for a user
  bool _isCacheValid(String uid) {
    final timestamp = _cacheTimestamps[uid];
    if (timestamp == null) return false;
    return DateTime.now().difference(timestamp) < _cacheExpiry;
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

      // Cache the user profile immediately
      _userCache[user.uid] = user;
      _cacheTimestamps[user.uid] = DateTime.now();

      print(
        '✅ FirestoreService: Profile created successfully with ID: $customDocumentId',
      );
    } catch (e, stackTrace) {
      print('❌ FirestoreService: Error creating profile: $e');
      print('❌ FirestoreService: Stack trace: $stackTrace');
      throw Exception('Failed to create user profile: $e');
    }
  }

  // Get user profile from Firestore by Firebase UID - OPTIMIZED WITH CACHING
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      // Check cache first
      if (_isCacheValid(uid) && _userCache.containsKey(uid)) {
        print('🚀 FirestoreService: Returning cached profile for $uid');
        return _userCache[uid];
      }

      print('🔧 FirestoreService: Fetching profile from database for $uid');

      // Add small delay to ensure authentication state is established
      await Future.delayed(const Duration(milliseconds: 100));

      // Since document ID is now username_info, we need to query by uid field
      final query = await _usersCollection
          .where('uid', isEqualTo: uid)
          .limit(1)
          .get(
            const GetOptions(source: Source.serverAndCache),
          ); // Use cache when possible

      if (query.docs.isNotEmpty) {
        final userModel = UserModel.fromFirestore(query.docs.first);

        // Cache the result
        _userCache[uid] = userModel;
        _cacheTimestamps[uid] = DateTime.now();

        print('✅ FirestoreService: Profile cached for $uid');
        return userModel;
      }

      print('⚠️ FirestoreService: No profile found for uid: $uid');
      return null;
    } catch (e) {
      print('❌ FirestoreService: Error getting profile: $e');

      // If permission denied, it might be an authentication timing issue
      if (e.toString().contains('permission-denied')) {
        print(
          '🔧 FirestoreService: Permission denied - checking authentication state...',
        );

        // Wait a bit longer and retry once
        await Future.delayed(const Duration(milliseconds: 500));

        try {
          final retryQuery = await _usersCollection
              .where('uid', isEqualTo: uid)
              .limit(1)
              .get();

          if (retryQuery.docs.isNotEmpty) {
            final userModel = UserModel.fromFirestore(retryQuery.docs.first);
            _userCache[uid] = userModel;
            _cacheTimestamps[uid] = DateTime.now();
            print('✅ FirestoreService: Profile retrieved on retry for $uid');
            return userModel;
          }
        } catch (retryError) {
          print('❌ FirestoreService: Retry also failed: $retryError');
        }
      }

      // Don't throw for permission errors during Google Sign-In flow
      if (e.toString().contains('permission-denied')) {
        print(
          '⚠️ FirestoreService: Returning null due to permission denied (likely timing issue)',
        );
        return null;
      }

      throw Exception('Failed to get user profile: $e');
    }
  }

  // Get user profile from Firestore by username (using document ID) - OPTIMIZED
  Future<UserModel?> getUserProfileByUsername(String username) async {
    try {
      final customDocumentId = generateCustomDocumentId(username);

      // Direct document access is much faster than querying
      final doc = await _usersCollection
          .doc(customDocumentId)
          .get(const GetOptions(source: Source.serverAndCache));

      if (doc.exists) {
        final userModel = UserModel.fromFirestore(doc);

        // Cache by UID as well
        _userCache[userModel.uid] = userModel;
        _cacheTimestamps[userModel.uid] = DateTime.now();

        return userModel;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user profile by username: $e');
    }
  }

  // Update user profile in Firestore by Firebase UID
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      // Clear cache first
      _clearUserCache(uid);

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
      // Skip timestamp updates - not needed for app functionality
      print('FirestoreService: Skipping lastSignInAt update');
    } catch (e) {
      print('❌ FirestoreService: Error updating last sign-in: $e');
      rethrow;
    }
  }

  // Optional: Batch timestamp updates (cost-efficient)
  Future<void> _updateTimestampsOptimized(String uid) async {
    try {
      // Get cached user first to avoid extra query
      UserModel? cachedUser;
      if (_isCacheValid(uid) && _userCache.containsKey(uid)) {
        cachedUser = _userCache[uid];
      }

      if (cachedUser != null) {
        // Use direct document access with cached username
        final customDocumentId = generateCustomDocumentId(cachedUser.username);
        await _usersCollection.doc(customDocumentId).update({
          'lastSignInAt': Timestamp.now(),
          'lastUpdatedAt': Timestamp.now(),
        });

        // Update cache
        final updatedUser = cachedUser.copyWith();
        _userCache[uid] = updatedUser;
        _cacheTimestamps[uid] = DateTime.now();

        print(
          '💰 FirestoreService: Batch timestamp update completed (1 write saved)',
        );
      }
    } catch (e) {
      print('⚠️ FirestoreService: Batch timestamp update failed: $e');
    }
  }

  // Cache for timestamp update tracking
  final Map<String, DateTime> _timestampUpdateCache = {};

  DateTime? _getLastTimestampUpdate(String uid) {
    return _timestampUpdateCache[uid];
  }

  void _setLastTimestampUpdate(String uid, DateTime timestamp) {
    _timestampUpdateCache[uid] = timestamp;
  }

  // Check if username is available - REVERTED TO WORKING VERSION
  Future<bool> isUsernameAvailable(String username) async {
    try {
      print(
        '🔧 FirestoreService: Checking username availability for: "$username"',
      );

      // Direct document check using custom document ID
      final customDocumentId = generateCustomDocumentId(username);
      print('🔧 FirestoreService: Generated document ID: "$customDocumentId"');

      final doc = await _usersCollection
          .doc(customDocumentId)
          .get(const GetOptions(source: Source.serverAndCache));

      final isAvailable = !doc.exists;
      print(
        '🔧 FirestoreService: Document exists: ${doc.exists}, Username available: $isAvailable',
      );

      if (doc.exists) {
        print('🔧 FirestoreService: Existing document data: ${doc.data()}');
      }

      return isAvailable;
    } catch (e, stackTrace) {
      print('❌ FirestoreService: Username availability check failed: $e');
      print('❌ FirestoreService: Stack trace: $stackTrace');
      throw Exception('Failed to check username availability: $e');
    }
  }

  // Delete user profile by Firebase UID
  Future<void> deleteUserProfile(String uid) async {
    try {
      // Clear cache first
      _clearUserCache(uid);

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
            final userModel = UserModel.fromFirestore(snapshot.docs.first);

            // Update cache when streaming
            _userCache[uid] = userModel;
            _cacheTimestamps[uid] = DateTime.now();

            return userModel;
          }
          return null;
        });
  }

  // Clear all cache (useful for logout)
  void clearAllCache() {
    _userCache.clear();
    _cacheTimestamps.clear();
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

      // Clean up test document
      await _firestore.collection('test').doc('connection_test').delete();
      print('✅ FirestoreService: Test cleanup successful');
    } catch (e) {
      print('❌ FirestoreService: Connection test failed: $e');
      throw Exception('Firestore connection test failed: $e');
    }
  }
}
