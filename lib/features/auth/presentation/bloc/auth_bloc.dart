import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/login_with_google_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

// BLoC for handling authentication-related events and states
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final RegisterUseCase registerUseCase;
  final LoginWithEmailUseCase loginWithEmailUseCase;
  final LoginWithGoogleUseCase loginWithGoogleUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;

  AuthBloc({
    required this.registerUseCase,
    required this.loginWithEmailUseCase,
    required this.loginWithGoogleUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
  }) : super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<RegisterButtonPressed>(_onRegisterButtonPressed);
    on<LoginWithEmailButtonPressed>(_onLoginWithEmailButtonPressed);
    on<LoginWithGoogleButtonPressed>(_onLoginWithGoogleButtonPressed);
    on<LogoutButtonPressed>(_onLogoutButtonPressed);
  }

  // Handle app startup to check for existing user
  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    print('AuthBloc - App started');
    emit(AuthLoading());

    // PERBAIKAN: Kurangi delay untuk pengalaman yang lebih responsif
    await Future.delayed(const Duration(milliseconds: 300));

    final result = await getCurrentUserUseCase(NoParams());
    result.fold(
      (failure) {
        print('AuthBloc - No current user found: ${failure.message}');
        emit(Unauthenticated());
      },
      (user) {
        print('AuthBloc - Current user found: ${user.username}');
        emit(Authenticated(user: user));
      },
    );
  }

  // Handle registration event
  Future<void> _onRegisterButtonPressed(
      RegisterButtonPressed event, Emitter<AuthState> emit) async {
    print('AuthBloc - Register button pressed');
    emit(AuthLoading());

    final result = await registerUseCase(RegisterParams(
      username: event.username,
      email: event.email,
      password: event.password,
    ));

    result.fold(
      (failure) {
        print('AuthBloc - Registration failed: ${failure.message}');
        emit(AuthFailure(message: failure.message));
      },
      (user) {
        print('AuthBloc - Registration successful: ${user.username}');
        // PERBAIKAN: Emisi state RegistrationSuccess untuk menunjukkan bahwa registrasi berhasil
        // tapi belum authenticated (user perlu login manual)
        emit(RegistrationSuccess(user: user));
      },
    );
  }

  // Handle email login event
  Future<void> _onLoginWithEmailButtonPressed(
      LoginWithEmailButtonPressed event, Emitter<AuthState> emit) async {
    print('AuthBloc - Login button pressed');
    emit(AuthLoading());

    final result = await loginWithEmailUseCase(LoginParams(
      email: event.email,
      password: event.password,
    ));

    // PERBAIKAN: Kurangi delay untuk pengalaman yang lebih responsif
    await Future.delayed(const Duration(milliseconds: 200));

    result.fold(
      (failure) {
        print('AuthBloc - Login failed: ${failure.message}');
        emit(AuthFailure(message: failure.message));
      },
      (user) {
        print('AuthBloc - Login successful: ${user.username}');
        // PERBAIKAN: Pastikan emit Authenticated state dengan benar
        emit(Authenticated(user: user));
      },
    );
  }

  // Handle Google login event
  Future<void> _onLoginWithGoogleButtonPressed(
      LoginWithGoogleButtonPressed event, Emitter<AuthState> emit) async {
    print('AuthBloc - Google login button pressed');
    emit(AuthLoading());

    final result = await loginWithGoogleUseCase(NoParams());

    // PERBAIKAN: Kurangi delay untuk pengalaman yang lebih responsif
    await Future.delayed(const Duration(milliseconds: 200));

    result.fold(
      (failure) {
        print('AuthBloc - Google login failed: ${failure.message}');
        emit(AuthFailure(message: failure.message));
      },
      (user) {
        print('AuthBloc - Google login successful: ${user.username}');
        // PERBAIKAN: Pastikan emit Authenticated state dengan benar
        emit(Authenticated(user: user));
      },
    );
  }

  // Handle logout event
  Future<void> _onLogoutButtonPressed(
      LogoutButtonPressed event, Emitter<AuthState> emit) async {
    print('AuthBloc - Logout button pressed');

    try {
      emit(AuthLoading());

      await logoutUseCase(NoParams());

      print('AuthBloc - Logout successful, emitting Unauthenticated');
      emit(Unauthenticated());
    } catch (e) {
      print('AuthBloc - Logout failed: $e');

      emit(Unauthenticated());
    }
  }
}
