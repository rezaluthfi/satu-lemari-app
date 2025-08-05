part of 'auth_bloc.dart';

// Base class for authentication events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

// Event for app startup
class AppStarted extends AuthEvent {}

// Event for registration
class RegisterButtonPressed extends AuthEvent {
  final String username;
  final String email;
  final String password;

  const RegisterButtonPressed({
    required this.username,
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [username, email, password];
}

// Event for email login
class LoginWithEmailButtonPressed extends AuthEvent {
  final String email;
  final String password;

  const LoginWithEmailButtonPressed({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

// Event for Google login
class LoginWithGoogleButtonPressed extends AuthEvent {}

// Event for logout
class LogoutButtonPressed extends AuthEvent {}

// Event for force logout when token refresh fails
class ForceLogoutDueToExpiredToken extends AuthEvent {}

// Event for successful token refresh
class TokenRefreshed extends AuthEvent {}

// --- TAMBAHKAN EVENT INI ---
class UserDataUpdated extends AuthEvent {
  final User updatedUser;

  const UserDataUpdated(this.updatedUser);

  @override
  List<Object> get props => [updatedUser];
}
