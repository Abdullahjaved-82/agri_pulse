import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth,
        _firestore = firestore;

  FirebaseAuth? _auth;
  FirebaseFirestore? _firestore;

  FirebaseAuth get _authClient => _auth ??= FirebaseAuth.instance;
  FirebaseFirestore get _firestoreClient =>
      _firestore ??= FirebaseFirestore.instance;

  Stream<User?> authStateChanges() => _authClient.authStateChanges();

  User? get currentUser => _authClient.currentUser;

  Future<User> signIn({
    required String email,
    required String password,
  }) async {
    final UserCredential credential = await _authClient.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final User? user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'No user found for that email.',
      );
    }
    return user;
  }

  Future<User> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String role,
  }) async {
    final UserCredential credential = await _authClient.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final User? user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'Unable to create user.',
      );
    }

    await user.updateDisplayName(fullName);
    await _firestoreClient.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'email': email,
      'fullName': fullName,
      'phone': phone,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return user;
  }

  Future<void> sendPasswordReset({required String email}) async {
    await _authClient.sendPasswordResetEmail(email: email);
  }

  Future<bool> checkIfUserExists(String email) async {
    final QuerySnapshot result = await _firestoreClient
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    return result.docs.isNotEmpty;
  }

  Future<void> signOut() async {
    await _authClient.signOut();
  }

  String readableError(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          return 'Please enter a valid email.';
        case 'user-not-found':
          return 'Account does not exist.';
        case 'wrong-password':
          return 'Incorrect password.';
        case 'invalid-credential':
          return 'Incorrect email or password.';
        case 'email-already-in-use':
          return 'This email is already registered.';
        case 'weak-password':
          return 'Password should be at least 6 characters.';
        case 'network-request-failed':
          return 'Network error. Check your connection.';
        default:
          return error.message ?? 'Authentication failed.';
      }
    }
    return 'Something went wrong. Please try again.';
  }
}
