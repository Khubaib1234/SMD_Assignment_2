abstract class AuthEvent {}

class SignUpRequested extends AuthEvent {
  final String email, password, name;
  SignUpRequested(this.email, this.password, this.name);
}

class SignInRequested extends AuthEvent {
  final String email, password;
  SignInRequested(this.email, this.password);
}

class SignOutRequested extends AuthEvent {}