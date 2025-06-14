import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/config/get_it_config.dart';
import '../states/auth_state.dart';
import '../../domain/entities/user_entity.dart';

class AuthController extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthController(this._authService) : super(const AuthInitial()) {
    _initializeAuthState();
  }

  // Initialize auth state by listening to auth changes
  void _initializeAuthState() {
    _authService.authStateChanges.listen((User? user) async {
      if (user != null) {
        try {
          final userProfile = await _authService.getUserProfile(user.uid);
          if (userProfile != null) {
            state = AuthAuthenticated(userProfile.toEntity());
          } else {
            state = const AuthUnauthenticated();
          }
        } catch (e) {
          state = AuthError('Failed to load user profile: $e');
        }
      } else {
        state = const AuthUnauthenticated();
      }
    });
  }

  // Sign in with email and password
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    state = const AuthLoading();
    try {
      final result = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result?.user != null) {
        // Show success message first
        state = const AuthSuccess('✅ Welcome back! Signed in successfully!');

        // Wait a moment for user to see the success message
        await Future.delayed(const Duration(seconds: 1));

        final userProfile = await _authService.getUserProfile(
          result!.user!.uid,
        );
        if (userProfile != null) {
          state = AuthAuthenticated(userProfile.toEntity());
        } else {
          state = const AuthError('User profile not found');
        }
      }
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  // Create user with email and password
  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
  }) async {
    state = const AuthLoading();
    try {
      print('🔧 AuthController: Starting user registration');
      print('🔧 AuthController: Email: $email');
      print('🔧 AuthController: Username: $username');

      print(
        '🔧 AuthController: Calling AuthService.createUserWithEmailAndPassword...',
      );
      final result = await _authService.createUserWithEmailAndPassword(
        email: email,
        password: password,
        username: username,
      );
      print('🔧 AuthController: AuthService call completed');

      if (result?.user != null) {
        print(
          '✅ AuthController: Firebase Auth user created: ${result!.user!.uid}',
        );

        // Show success message first
        state = const AuthSuccess(
          '🎉 Account created successfully! Welcome aboard!',
        );

        // Wait a moment for user to see the success message
        await Future.delayed(const Duration(seconds: 2));

        print('🔧 AuthController: Loading user profile from Firestore...');
        // Then load user profile and set authenticated state
        final userProfile = await _authService.getUserProfile(result.user!.uid);

        if (userProfile != null) {
          print('✅ AuthController: User profile loaded successfully');
          state = AuthAuthenticated(userProfile.toEntity());
        } else {
          print('❌ AuthController: User profile NOT found in Firestore');
          state = const AuthError('Failed to create user profile');
        }
      } else {
        print('❌ AuthController: Firebase Auth user creation returned null');
      }
    } catch (e, stackTrace) {
      print('❌ AuthController: Error during registration: $e');
      print('❌ AuthController: Stack trace: $stackTrace');
      state = AuthError(e.toString());
    }
  }

  // Sign in with Google
  Future<void> signInWithGoogle() async {
    state = const AuthLoading();
    try {
      final result = await _authService.signInWithGoogle();

      if (result?.user != null) {
        // Show success message first
        state = const AuthSuccess('🚀 Google Sign-In successful! Welcome!');

        // Wait a moment for user to see the success message
        await Future.delayed(const Duration(seconds: 1));

        final userProfile = await _authService.getUserProfile(
          result!.user!.uid,
        );
        if (userProfile != null) {
          state = AuthAuthenticated(userProfile.toEntity());
        } else {
          state = const AuthError('Failed to load user profile');
        }
      } else {
        // User canceled sign-in
        state = const AuthUnauthenticated();
      }
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  // Sign out
  Future<void> signOut() async {
    state = const AuthLoading();
    try {
      await _authService.signOut();
      state = const AuthUnauthenticated();
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    state = const AuthLoading();
    try {
      await _authService.sendPasswordResetEmail(email);
      state = const AuthSuccess(
        '📧 Password reset email sent! Check your inbox.',
      );
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  // Clear error state
  void clearError() {
    if (state is AuthError || state is AuthSuccess) {
      state = const AuthUnauthenticated();
    }
  }
}

// Provider for AuthController
final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    return AuthController(getIt<AuthService>());
  },
);
