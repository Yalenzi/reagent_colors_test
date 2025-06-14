import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/config/get_it_config.dart';
import '../../data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreDebugPage extends ConsumerStatefulWidget {
  const FirestoreDebugPage({super.key});

  @override
  ConsumerState<FirestoreDebugPage> createState() => _FirestoreDebugPageState();
}

class _FirestoreDebugPageState extends ConsumerState<FirestoreDebugPage> {
  final FirestoreService _firestoreService = getIt<FirestoreService>();
  final AuthService _authService = getIt<AuthService>();
  String _debugOutput = '';
  bool _isLoading = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _addDebugMessage(String message) {
    setState(() {
      _debugOutput += '$message\n';
    });
  }

  Future<void> _testUserProfileCreation() async {
    setState(() {
      _isLoading = true;
      _debugOutput = '';
    });

    try {
      _addDebugMessage('🔍 Starting user profile creation test...');

      // Check current user
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        _addDebugMessage('❌ No authenticated user found');
        return;
      }

      _addDebugMessage(
        '✅ Current user: ${currentUser.email} (${currentUser.uid})',
      );

      // Check if user profile already exists
      _addDebugMessage('🔍 Checking if user profile exists...');
      final existingProfile = await _firestoreService.getUserProfile(
        currentUser.uid,
      );

      if (existingProfile != null) {
        _addDebugMessage('✅ User profile already exists:');
        _addDebugMessage('   - Email: ${existingProfile.email}');
        _addDebugMessage('   - Username: ${existingProfile.username}');
        _addDebugMessage('   - Registered: ${existingProfile.registeredAt}');
      } else {
        _addDebugMessage('❌ No user profile found in Firestore');

        // Try to create user profile manually
        _addDebugMessage('🔧 Attempting to create user profile...');

        final userModel = UserModel(
          uid: currentUser.uid,
          email: currentUser.email ?? '',
          username: 'debug_user_${DateTime.now().millisecondsSinceEpoch}',
          registeredAt: DateTime.now(),
          photoUrl: currentUser.photoURL,
          displayName: currentUser.displayName,
          isEmailVerified: currentUser.emailVerified,
        );

        await _firestoreService.createUserProfile(userModel);
        _addDebugMessage('✅ User profile created successfully!');

        // Verify it was created
        final verifyProfile = await _firestoreService.getUserProfile(
          currentUser.uid,
        );
        if (verifyProfile != null) {
          _addDebugMessage('✅ Profile verification successful');
        } else {
          _addDebugMessage('❌ Profile verification failed');
        }
      }
    } catch (e) {
      _addDebugMessage('❌ Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testCreateNewAccount() async {
    setState(() {
      _isLoading = true;
      _debugOutput = '';
    });

    try {
      _addDebugMessage('🔍 Testing new account creation...');

      final testEmail =
          'test_${DateTime.now().millisecondsSinceEpoch}@example.com';
      final testUsername = 'testuser${DateTime.now().millisecondsSinceEpoch}';
      const testPassword = 'password123';

      _addDebugMessage('📧 Creating account: $testEmail');
      _addDebugMessage('👤 Username: $testUsername');

      // Create account using AuthService
      final result = await _authService.createUserWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
        username: testUsername,
      );

      if (result?.user != null) {
        _addDebugMessage(
          '✅ Firebase Auth account created: ${result!.user!.uid}',
        );

        // Wait a moment for Firestore to sync
        await Future.delayed(const Duration(seconds: 2));

        // Check if profile was created in Firestore
        final profile = await _firestoreService.getUserProfile(
          result.user!.uid,
        );
        if (profile != null) {
          _addDebugMessage('✅ Firestore profile created successfully!');
          _addDebugMessage('   - Email: ${profile.email}');
          _addDebugMessage('   - Username: ${profile.username}');
        } else {
          _addDebugMessage('❌ Firestore profile NOT created');
        }
      } else {
        _addDebugMessage('❌ Failed to create Firebase Auth account');
      }
    } catch (e) {
      _addDebugMessage('❌ Error creating account: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final querySnapshot = await _firestore.collection('users').get();
      final users = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['uid'] = doc.id; // Add document ID as uid
        return data;
      }).toList();

      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading users: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createTestUser() async {
    try {
      final testUser = UserModel.fromFirebaseUser(
        uid: 'test_user_${DateTime.now().millisecondsSinceEpoch}',
        email: 'test@example.com',
        username: 'testuser${DateTime.now().millisecondsSinceEpoch}',
        displayName: 'Test User',
        signInMethods: ['password'],
        preferredLanguage: 'en',
        timezone: 'America/New_York',
      );

      print('🔧 Creating test user with data: ${testUser.toFirestore()}');

      await _firestore
          .collection('users')
          .doc(testUser.uid)
          .set(testUser.toFirestore());

      print('✅ Test user created successfully');
      _loadUsers(); // Reload users
    } catch (e) {
      print('❌ Error creating test user: $e');
    }
  }

  Future<void> _testFirestoreConnection() async {
    setState(() {
      _isLoading = true;
      _debugOutput = '';
    });

    _addDebugMessage('🔧 Starting Firestore connection test...');

    try {
      await _firestoreService.testFirestoreConnection();
      _addDebugMessage('✅ Firestore connection test completed successfully');
    } catch (e) {
      _addDebugMessage('❌ Firestore connection test failed: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firestore Debug'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadUsers),
          IconButton(icon: const Icon(Icons.add), onPressed: _createTestUser),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Firestore Users Collection Debug',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _loadUsers,
                  child: const Text('Refresh Users'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _createTestUser,
                  child: const Text('Create Test User'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isLoading ? null : _testFirestoreConnection,
                  child: const Text('Test Firestore'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _users.isEmpty
                  ? const Center(child: Text('No users found in Firestore'))
                  : ListView.builder(
                      itemCount: _users.length,
                      itemBuilder: (context, index) {
                        final user = _users[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8.0),
                          child: ExpansionTile(
                            title: Text(user['email'] ?? 'No email'),
                            subtitle: Text(
                              'Username: ${user['username'] ?? 'No username'}',
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Complete User Data Stored in Firestore:',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: SelectableText(
                                        _formatUserData(user),
                                        style: const TextStyle(
                                          fontFamily: 'monospace',
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Debug Output:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    _debugOutput.isEmpty ? 'No debug output yet' : _debugOutput,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createTestUser,
        child: const Icon(Icons.person_add),
      ),
    );
  }

  String _formatUserData(Map<String, dynamic> user) {
    final buffer = StringBuffer();
    user.forEach((key, value) {
      if (value is Timestamp) {
        buffer.writeln('$key: ${value.toDate()}');
      } else if (value is List) {
        buffer.writeln('$key: ${value.join(', ')}');
      } else {
        buffer.writeln('$key: $value');
      }
    });
    return buffer.toString();
  }
}
