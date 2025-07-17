part of 'auth_bloc.dart';

// Base class for authentication states
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

// Initial authentication state
class AuthInitial extends AuthState {}

// Loading state during authentication
class AuthLoading extends AuthState {}

// State for successful authentication
class Authenticated extends AuthState {
  final User user;

  const Authenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

// State for successful registration
class RegistrationSuccess extends AuthState {
  final User user;

  const RegistrationSuccess({required this.user});

  @override
  List<Object?> get props => [user];
}

// State for unauthenticated user
class Unauthenticated extends AuthState {}

// State for authentication failure
class AuthFailure extends AuthState {
  final String message;

  const AuthFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
