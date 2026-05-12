import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../goals/data/goals_repository.dart';
import '../../profile/data/profile_repository.dart';
import '../../transactions/data/transactions_repository.dart';

enum AuthFlow { login, signup }

class AuthFeedback {
  const AuthFeedback({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
  });

  final String title;
  final String message;
  final IconData icon;
  final Color color;
}

class AuthResult {
  const AuthResult({required this.isSuccess, this.feedback});

  final bool isSuccess;
  final AuthFeedback? feedback;
}

class AuthProvider extends ChangeNotifier {
  AuthProvider(
    this._firebaseAuth,
    this._profileRepository,
    this._transactionsRepository,
    this._goalsRepository,
  ) {
    _authSubscription = _firebaseAuth.authStateChanges().listen((user) {
      _firebaseUser = user;
      notifyListeners();
    });
    _loadOnboardingState();
  }

  final auth.FirebaseAuth _firebaseAuth;
  final ProfileRepository _profileRepository;
  final TransactionsRepository _transactionsRepository;
  final GoalsRepository _goalsRepository;

  StreamSubscription<auth.User?>? _authSubscription;
  auth.User? _firebaseUser;
  bool _isInitialized = false;
  bool _hasSeenOnboarding = false;
  bool _isSubmitting = false;
  bool _isDeletingAccount = false;
  AuthFeedback? _lastFeedback;

  auth.User? get firebaseUser => _firebaseUser;
  bool get isInitialized => _isInitialized;
  bool get hasSeenOnboarding => _hasSeenOnboarding;
  bool get isSubmitting => _isSubmitting;
  bool get isDeletingAccount => _isDeletingAccount;
  AuthFeedback? get lastFeedback => _lastFeedback;
  bool get isAuthenticated => _firebaseUser != null;

  Future<void> _loadOnboardingState() async {
    final preferences = await SharedPreferences.getInstance();
    _hasSeenOnboarding = preferences.getBool('has_seen_onboarding') ?? false;
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool('has_seen_onboarding', true);
    _hasSeenOnboarding = true;
    notifyListeners();
  }

  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    return _runAuthAction(() async {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      final user = credential.user;
      if (user != null) {
        await _profileRepository.ensureProfile(user);
      }
    }, flow: AuthFlow.login);
  }

  Future<AuthResult> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    return _runAuthAction(() async {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      final user = credential.user;
      if (user != null) {
        await user.updateDisplayName(name.trim());
        await _profileRepository.ensureProfile(user, name: name.trim());
      }
    }, flow: AuthFlow.signup);
  }

  Future<void> signOut() async {
    _lastFeedback = null;
    await _firebaseAuth.signOut();
  }

  Future<AuthResult> deleteAccount({
    required Iterable<String> transactionIds,
    required Iterable<String> goalIds,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      return AuthResult(
        isSuccess: false,
        feedback: _failure(
          title: 'No active session',
          message: 'Log in again before deleting the account.',
        ),
      );
    }

    _isDeletingAccount = true;
    _lastFeedback = null;
    notifyListeners();
    try {
      final uid = user.uid;
      await user.delete();
      await _transactionsRepository.deleteAllTransactions(uid, transactionIds);
      await _goalsRepository.deleteAllGoals(uid, goalIds);
      await _profileRepository.deleteProfile(uid);
      return const AuthResult(isSuccess: true);
    } on auth.FirebaseAuthException catch (error) {
      _lastFeedback = _mapDeleteAccountError(error);
      return AuthResult(isSuccess: false, feedback: _lastFeedback);
    } catch (_) {
      _lastFeedback = _failure(
        title: 'Delete failed',
        message: 'Unable to delete the account right now. Please try again.',
      );
      return AuthResult(isSuccess: false, feedback: _lastFeedback);
    } finally {
      _isDeletingAccount = false;
      notifyListeners();
    }
  }

  Future<AuthResult> _runAuthAction(
    Future<void> Function() action, {
    required AuthFlow flow,
  }) async {
    _isSubmitting = true;
    _lastFeedback = null;
    notifyListeners();
    try {
      await action();
      return const AuthResult(isSuccess: true);
    } on auth.FirebaseAuthException catch (error) {
      _lastFeedback = _mapAuthError(error, flow);
      return AuthResult(isSuccess: false, feedback: _lastFeedback);
    } catch (_) {
      _lastFeedback = const AuthFeedback(
        title: 'Something went wrong',
        message: 'Please try again in a moment.',
        icon: Icons.error_outline,
        color: Color(0xFFF06292),
      );
      return AuthResult(isSuccess: false, feedback: _lastFeedback);
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  AuthFeedback _mapAuthError(auth.FirebaseAuthException error, AuthFlow flow) {
    switch (error.code) {
      case 'invalid-email':
        return _failure(
          title: 'Invalid email',
          message: 'Enter a valid email address to continue.',
        );
      case 'user-disabled':
        return _failure(
          title: 'Account disabled',
          message: 'This account has been disabled. Contact support if needed.',
        );
      case 'user-not-found':
        return _failure(
          title: 'Email not found',
          message:
              'No account exists for this email. Create a new one instead.',
        );
      case 'wrong-password':
        return _failure(
          title: 'Incorrect password',
          message: 'The password you entered is incorrect. Try again.',
        );
      case 'invalid-credential':
        return _failure(
          title: 'Credentials did not match',
          message: flow == AuthFlow.login
              ? 'Check the email and password and try again.'
              : 'The credentials are not valid for sign up.',
        );
      case 'email-already-in-use':
        return _failure(
          title: 'Email already registered',
          message: 'Use a different email or log in with this one.',
        );
      case 'weak-password':
        return _failure(
          title: 'Weak password',
          message:
              'Use at least 6 characters with a mix of letters and numbers.',
        );
      case 'operation-not-allowed':
        return _failure(
          title: 'Email auth disabled',
          message: 'Enable Email/Password sign-in in Firebase Authentication.',
        );
      case 'too-many-requests':
        return _failure(
          title: 'Too many attempts',
          message: 'Please wait a bit before trying again.',
        );
      case 'network-request-failed':
        return _failure(
          title: 'Network error',
          message: 'Check your internet connection and try again.',
        );
      default:
        return _failure(
          title: flow == AuthFlow.login ? 'Login failed' : 'Sign up failed',
          message: error.message ?? 'Authentication failed. Please try again.',
        );
    }
  }

  AuthFeedback _mapDeleteAccountError(auth.FirebaseAuthException error) {
    switch (error.code) {
      case 'requires-recent-login':
        return _failure(
          title: 'Recent login required',
          message:
              'For security, log out and sign in again before deleting your account.',
        );
      case 'network-request-failed':
        return _failure(
          title: 'Network error',
          message: 'Check your internet connection and try again.',
        );
      default:
        return _failure(
          title: 'Delete failed',
          message: error.message ?? 'Unable to delete your account right now.',
        );
    }
  }

  AuthFeedback _failure({required String title, required String message}) {
    return const AuthFeedback(
      title: '',
      message: '',
      icon: Icons.error_outline,
      color: Color(0xFFF06292),
    ).copyWith(title: title, message: message);
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

extension on AuthFeedback {
  AuthFeedback copyWith({
    String? title,
    String? message,
    IconData? icon,
    Color? color,
  }) {
    return AuthFeedback(
      title: title ?? this.title,
      message: message ?? this.message,
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }
}
