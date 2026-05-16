import 'package:firebase_auth/firebase_auth.dart';

abstract class IAuthService {
  Future<User?> signUp(String email, String password, String name);
  Future<User?> signIn(String email, String password);
  Future<void> signOut();
  User? get currentUser;
}

class AuthService implements IAuthService{
  final FirebaseAuth _auth;

  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  @override
  Future<User?> signIn(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return result.user;
  }

  @override
  Future<User?> signUp(String email, String password, String name) async {
    final result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    await result.user?.updateDisplayName(name);
    return result.user;
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  User? get currentUser => _auth.currentUser;
}