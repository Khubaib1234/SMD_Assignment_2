import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_module/firebase_module.dart';

import 'auth_service_test.mocks.dart';

@GenerateMocks([FirebaseAuth, UserCredential, User])
void main() {
  late MockFirebaseAuth mockAuth;
  late AuthService authService;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    authService = AuthService(auth: mockAuth);
  });

  test('signIn returns user on success', () async {
    final mockCredential = MockUserCredential();
    final mockUser = MockUser();

    when(mockAuth.signInWithEmailAndPassword(
      email: 'test@test.com',
      password: '123456',
    )).thenAnswer((_) async => mockCredential);

    when(mockCredential.user).thenReturn(mockUser);

    final user = await authService.signIn('test@test.com', '123456');

    expect(user, isNotNull);
    verify(mockAuth.signInWithEmailAndPassword(
      email: 'test@test.com',
      password: '123456',
    )).called(1);
  });

  test('signIn throws on wrong password', () async {
    when(mockAuth.signInWithEmailAndPassword(
      email: anyNamed('email'),
      password: anyNamed('password'),
    )).thenThrow(FirebaseAuthException(code: 'wrong-password'));

    expect(
      () => authService.signIn('test@test.com', 'wrongpass'),
      throwsA(isA<FirebaseAuthException>()),
    );
  });
}