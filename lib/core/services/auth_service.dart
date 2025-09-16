import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../features/auth/data/models/user_model.dart';
import 'firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Explicitly set the Web client ID to avoid DEVELOPER_ERROR (status 10) on release builds
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: '76342007759-80mka1har3blp9agpld84hqmfi4eg79l.apps.googleusercontent.com',
  );
  final FirestoreService _firestoreService = FirestoreService();

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Ensure user profile exists/updated in Firestore
      final user = result.user;
      if (user != null) {
        await _firestoreService.ensureUserProfileExists(
          uid: user.uid,
          email: user.email ?? email,
          displayName: user.displayName,
          photoUrl: user.photoURL,
          isEmailVerified: user.emailVerified,
        );
      }

      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Create user with email and password
  Future<UserCredential?> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      // Check if username is available
      final isUsernameAvailable = await _firestoreService.isUsernameAvailable(
        username,
      );
      if (!isUsernameAvailable) {
        throw Exception('Username is already taken');
      }

      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user profile in Firestore
      if (result.user != null) {
        print('🔧 AuthService: Creating user profile for ${result.user!.uid}');
        final userModel = UserModel(
          uid: result.user!.uid,
          email: email,
          username: username,
          registeredAt: DateTime.now(),
          photoUrl: result.user!.photoURL,
          displayName: result.user!.displayName ?? username,
          isEmailVerified: result.user!.emailVerified,
        );

        print('🔧 AuthService: User model created, calling Firestore...');
        await _firestoreService.createUserProfile(userModel);
        print('✅ AuthService: User profile created successfully in Firestore');
      }

      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to create account: $e');
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential result = await _auth.signInWithCredential(
        credential,
      );

      // Ensure profile exists/updated for Google sign-in
      if (result.user != null) {
        // If new user, try create unique username; otherwise still ensure doc exists
        String baseUsername = _generateUsernameFromEmail(result.user!.email ?? '');
        String username = await _ensureUniqueUsername(baseUsername);

        await _firestoreService.ensureUserProfileExists(
          uid: result.user!.uid,
          email: result.user!.email ?? '',
          username: username,
          displayName: result.user!.displayName,
          photoUrl: result.user!.photoURL,
          isEmailVerified: result.user!.emailVerified,
        );
      }

      return result;
    } catch (e) {
      throw Exception('Failed to sign in with Google: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Get user profile from Firestore
  Future<UserModel?> getUserProfile(String uid) async {
    return await _firestoreService.getUserProfile(uid);
  }

  // Stream user profile
  Stream<UserModel?> streamUserProfile(String uid) {
    return _firestoreService.streamUserProfile(uid);
  }

  // Helper method to generate username from email
  String _generateUsernameFromEmail(String email) {
    final emailParts = email.split('@');
    if (emailParts.isNotEmpty) {
      return emailParts[0].toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    }
    return 'user${DateTime.now().millisecondsSinceEpoch}';
  }

  // Helper method to ensure username is unique
  Future<String> _ensureUniqueUsername(String baseUsername) async {
    String username = baseUsername;
    int counter = 1;

    while (!(await _firestoreService.isUsernameAvailable(username))) {
      username = '$baseUsername$counter';
      counter++;
    }

    return username;
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      default:
        return 'An error occurred: ${e.message}';
    }
  }
}
