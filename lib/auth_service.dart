import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'app_user.dart';
import 'firestore_service.dart';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _store = FirestoreService();

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email.trim(), password: password);
      final user = cred.user!;

      // Menggunakan constructor AppUser dengan nilai lalai (default)
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email ?? email.trim(),
        'name': name,
        'isOnline': true,
      });
    } on FirebaseAuthException catch (e) {
      throw AuthException(_authMsg(e));
    } on FirebaseException catch (e) {
      throw AuthException(_dbMsg(e));
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
          email: email.trim(), password: password);
      // Update user's online status directly in Firestore. Use set with merge
      // to avoid depending on FirestoreService having a specific method.
      await FirebaseFirestore.instance
          .collection('users')
          .doc(cred.user!.uid)
          .set({'isOnline': true}, SetOptions(merge: true));
    } on FirebaseAuthException catch (e) {
      throw AuthException(_authMsg(e));
    } on FirebaseException catch (e) {
      throw AuthException(_dbMsg(e));
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final gUser = await GoogleSignIn().signIn();
      if (gUser == null) throw AuthException('Login Google dibatalkan');

      final gAuth = await gUser.authentication;
      final credential = GoogleAuthProvider.credential(
          accessToken: gAuth.accessToken, idToken: gAuth.idToken);

      final cred = await _auth.signInWithCredential(credential);
      final user = cred.user!;

      await _store.createUserIfMissing(AppUser(
        uid: user.uid,
        email: user.email ?? '',
        name: user.displayName ?? '',
        profilePictureUrl: user.photoURL ?? '',
        isOnline: true,
      ));
    } on FirebaseAuthException catch (e) {
      throw AuthException(_authMsg(e));
    } on FirebaseException catch (e) {
      throw AuthException(_dbMsg(e));
    }
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException(_authMsg(e));
    }
  }

  Future<void> signOut() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .set({'isOnline': false}, SetOptions(merge: true));
      } catch (_) {}
    }
    try {
      await GoogleSignIn().signOut();
    } catch (_) {}
    await _auth.signOut();
  }

  String _authMsg(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Format email tidak valid';
      case 'user-disabled':
        return 'Akun ini telah dinonaktifkan';
      case 'user-not-found':
        return 'Akun tidak ditemukan';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email atau password salah';
      case 'email-already-in-use':
        return 'Email ini sudah terdaftar';
      case 'weak-password':
        return 'Password terlalu lemah (min. 6 karakter)';
      case 'network-request-failed':
        return 'Tidak ada koneksi internet';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi nanti';
      default:
        return e.message ?? 'Terjadi kesalahan autentikasi';
    }
  }

  String _dbMsg(FirebaseException e) {
    if (e.code == 'permission-denied') {
      return 'Akses ditolak. Pastikan Firestore rules sudah di-publish.';
    }
    return e.message ?? 'Terjadi kesalahan database';
  }
}
