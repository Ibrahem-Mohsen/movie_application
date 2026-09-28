import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._service);

  final AuthService _service;
  bool isLoading = false;
  String? errorMessage;

  Stream<User?> get authStateChanges => _service.authStateChanges;
  User? get currentUser => _service.currentUser;

  Future<bool> login(String email, String password) async {
    return _run(() => _service.login(email, password));
  }

  Future<bool> register(String email, String password) async {
    return _run(() => _service.register(email, password));
  }

  Future<void> logout() => _service.logout();

  Future<bool> _run(Future<void> Function() action) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await action();
      return true;
    } on FirebaseAuthException catch (error) {
      errorMessage = _messageFor(error.code);
      return false;
    } catch (_) {
      errorMessage = 'Something went wrong. Please try again.';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  String _messageFor(String code) => switch (code) {
    'email-already-in-use' => 'An account already uses this email.',
    'invalid-email' => 'Enter a valid email address.',
    'weak-password' => 'Use a stronger password (at least 6 characters).',
    'user-not-found' ||
    'wrong-password' ||
    'invalid-credential' => 'Email or password is incorrect.',
    'network-request-failed' => 'Check your internet connection.',
    'too-many-requests' => 'Too many attempts. Please try again later.',
    _ => 'Could not complete the request. Please try again.',
  };
}
