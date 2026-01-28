import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthException implements Exception {
  final String message;
  final String? code;

  AuthException(this.message, [this.code]);

  @override
  String toString() => message;
}

class AuthService {
  static final AuthService _instance = AuthService._internal();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  // Get current user
  User? get currentUser => _firebaseAuth.currentUser;

  // Stream for auth changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Sign in with email and password
  /// Throws [AuthException] on failure
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final trimmedEmail = email.trim();
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: trimmedEmail,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getErrorMessage(e), e.code);
    } catch (e) {
      throw AuthException('An unexpected error occurred. Please try again.');
    }
  }

  /// Sign in with Google
  /// Returns null if user cancels the sign-in dialog
  /// Throws [AuthException] on other failures
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // User cancelled the sign-in
      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getErrorMessage(e), e.code);
    } catch (e) {
      if (e.toString().contains('sign_in_canceled')) {
        return null; // User cancelled
      }
      throw AuthException('Google sign-in failed. Please try again.');
    }
  }

  /// Register with email and password
  /// Throws [AuthException] on failure
  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final trimmedEmail = email.trim();
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: trimmedEmail,
        password: password,
      );

      // Update display name
      await userCredential.user?.updateDisplayName(name);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getErrorMessage(e), e.code);
    } catch (e) {
      throw AuthException('Registration failed. Please try again.');
    }
  }

  /// Register with Google
  /// Returns null if user cancels the sign-up dialog
  /// Throws [AuthException] on other failures
  Future<UserCredential?> registerWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // User cancelled the sign-up
      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getErrorMessage(e), e.code);
    } catch (e) {
      if (e.toString().contains('sign_in_canceled')) {
        return null; // User cancelled
      }
      throw AuthException('Google registration failed. Please try again.');
    }
  }

  /// Sign out the current user
  /// Clears Google sign-in cache as well
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
    } catch (e) {
      throw AuthException('Failed to sign out. Please try again.');
    }
  }

  /// Get user-friendly error message from FirebaseAuthException
  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many login attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Password is too weak. Please use a stronger password.';
      case 'invalid-credential':
        return 'Invalid credentials. Please check your email and password.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with this email.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }
}
