import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/config/get_it_config.dart';
import '../../data/models/user_model.dart';

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

  void _addDebugMessage(String message) {
    setState(() {
      _debugOutput +=
          '${DateTime.now().toIso8601String().substring(11, 19)}: $message\n';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firestore Debug'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Firestore User Profile Debug',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _testUserProfileCreation,
                      child: const Text('Test Current User Profile'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _testCreateNewAccount,
                      child: const Text('Test Create New Account'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Debug Output',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          if (_isLoading)
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: SingleChildScrollView(
                            child: Text(
                              _debugOutput.isEmpty
                                  ? 'Tap a button above to start debugging...'
                                  : _debugOutput,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
