import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/config/get_it_config.dart';
import '../states/auth_state.dart';
import '../../domain/entities/user_entity.dart';

class AuthController extends StateNotifier<AuthState> {
  final AuthService _authService;
  BuildContext? _context;

  AuthController(this._authService) : super(const AuthInitial()) {
    _initializeAuthState();
  }

  // Set context for notifications
  void setContext(BuildContext context) {
    _context = context;
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

  // Sign in with email and password - OPTIMIZED
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
        // Get user profile immediately without artificial delays
        final userProfile = await _authService.getUserProfile(
          result!.user!.uid,
        );
        if (userProfile != null) {
          // Show login success notification
          if (_context != null) {
            NotificationService.showLoginSuccess(
              context: _context!,
              username: userProfile.username,
            );
          }

          state = AuthAuthenticated(userProfile.toEntity());
        } else {
          state = const AuthError('User profile not found');
        }
      }
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  // Create user with email and password - OPTIMIZED
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

        print('🔧 AuthController: Loading user profile from Firestore...');
        // Load user profile immediately without delays
        final userProfile = await _authService.getUserProfile(result.user!.uid);

        if (userProfile != null) {
          print('✅ AuthController: User profile loaded successfully');

          // Show success notification
          if (_context != null) {
            NotificationService.showRegistrationSuccess(
              context: _context!,
              username: userProfile.username,
            );
          }

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

      // Show error notification
      if (_context != null) {
        NotificationService.showError(
          context: _context!,
          title: '❌ Registration Failed',
          message: 'Unable to create account. Please try again.',
        );
      }

      state = AuthError(e.toString());
    }
  }

  // Sign in with Google - OPTIMIZED
  Future<void> signInWithGoogle() async {
    state = const AuthLoading();
    try {
      final result = await _authService.signInWithGoogle();

      if (result?.user != null) {
        // Get user profile immediately without artificial delays
        final userProfile = await _authService.getUserProfile(
          result!.user!.uid,
        );
        if (userProfile != null) {
          // Show Google sign-in success notification
          if (_context != null) {
            NotificationService.showSuccess(
              context: _context!,
              title: '🚀 Google Sign-In Success',
              message:
                  'Welcome back ${userProfile.username}! Ready to continue testing?',
            );
          }

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

  // Show temporary success message then return to authenticated state
  void showSuccessMessage(String message, UserEntity user) async {
    state = AuthSuccess(message);
    // Brief success message display
    await Future.delayed(const Duration(milliseconds: 800));
    state = AuthAuthenticated(user);
  }
}

// Provider for AuthController
final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    return AuthController(getIt<AuthService>());
  },
);
