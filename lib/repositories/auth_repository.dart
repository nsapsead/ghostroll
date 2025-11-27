import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;

// Provider for the auth repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository();
});

abstract class AuthRepository {
  Stream<User?> get authStateChanges;
  User? get currentUser;
  Future<User?> signInWithEmailAndPassword(String email, String password);
  Future<User?> createUserWithEmailAndPassword(String email, String password);
  Future<void> sendPasswordResetEmail(String email);
  Future<User?> signInWithGoogle();
  Future<void> signOut();
}

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  User? get currentUser => _firebaseAuth.currentUser;

  @override
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<User?> createUserWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<User?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // Web-specific Google Sign-In
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        final UserCredential userCredential = await _firebaseAuth.signInWithPopup(googleProvider);
        return userCredential.user;
      } else {
        // Mobile Google Sign-In
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) return null; // User canceled

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
        return userCredential.user;
      }
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }
}
