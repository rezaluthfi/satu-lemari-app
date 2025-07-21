import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:satulemari/core/services/notification_service.dart';
import 'package:satulemari/core/usecases/usecase.dart';
import 'package:satulemari/features/auth/domain/entities/user.dart';
import 'package:satulemari/features/auth/domain/usecases/delete_fcm_token_usecase.dart';
import 'package:satulemari/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:satulemari/features/auth/domain/usecases/login_usecase.dart';
import 'package:satulemari/features/auth/domain/usecases/login_with_google_usecase.dart';
import 'package:satulemari/features/auth/domain/usecases/logout_usecase.dart';
import 'package:satulemari/features/auth/domain/usecases/register_fcm_token_usecase.dart';
import 'package:satulemari/features/auth/domain/usecases/register_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final RegisterUseCase registerUseCase;
  final LoginWithEmailUseCase loginWithEmailUseCase;
  final LoginWithGoogleUseCase loginWithGoogleUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final NotificationService notificationService;
  final RegisterFCMTokenUseCase registerFCMTokenUseCase;
  final DeleteFCMTokenUseCase deleteFCMTokenUseCase;

  AuthBloc({
    required this.registerUseCase,
    required this.loginWithEmailUseCase,
    required this.loginWithGoogleUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
    required this.notificationService,
    required this.registerFCMTokenUseCase,
    required this.deleteFCMTokenUseCase,
  }) : super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<RegisterButtonPressed>(_onRegisterButtonPressed);
    on<LoginWithEmailButtonPressed>(_onLoginWithEmailButtonPressed);
    on<LoginWithGoogleButtonPressed>(_onLoginWithGoogleButtonPressed);
    on<LogoutButtonPressed>(_onLogoutButtonPressed);

    notificationService.onTokenRefresh().listen((newToken) {
      if (state is Authenticated) {
        print('FCM Token Refreshed, updating in backend: $newToken');
        _registerToken(token: newToken);
      }
    });
  }

  Future<void> _registerToken({String? token}) async {
    try {
      final fcmToken = token ?? await notificationService.getFCMToken();
      if (fcmToken != null) {
        print('Registering FCM Token to backend: $fcmToken');
        await registerFCMTokenUseCase(RegisterFCMTokenParams(token: fcmToken));
      }
    } catch (e) {
      print('Failed to register FCM token: $e');
    }
  }

  Future<void> _deleteToken() async {
    try {
      final fcmToken = await notificationService.getFCMToken();
      if (fcmToken != null) {
        print('Deleting FCM Token from backend: $fcmToken');
        await deleteFCMTokenUseCase(DeleteFCMTokenParams(token: fcmToken));
      }
    } catch (e) {
      print('Failed to delete FCM token: $e');
    }
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    print('AuthBloc - App started');
    emit(AuthLoading());
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
        _registerToken();
      },
    );
  }

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
        emit(RegistrationSuccess(user: user));
      },
    );
  }

  Future<void> _onLoginWithEmailButtonPressed(
      LoginWithEmailButtonPressed event, Emitter<AuthState> emit) async {
    print('AuthBloc - Login button pressed');
    emit(AuthLoading());
    final result = await loginWithEmailUseCase(LoginParams(
      email: event.email,
      password: event.password,
    ));
    await Future.delayed(const Duration(milliseconds: 200));
    result.fold(
      (failure) {
        print('AuthBloc - Login failed: ${failure.message}');
        emit(AuthFailure(message: failure.message));
      },
      (user) {
        print('AuthBloc - Login successful: ${user.username}');
        emit(Authenticated(user: user));
        _registerToken();
      },
    );
  }

  Future<void> _onLoginWithGoogleButtonPressed(
      LoginWithGoogleButtonPressed event, Emitter<AuthState> emit) async {
    print('AuthBloc - Google login button pressed');
    emit(AuthLoading());
    final result = await loginWithGoogleUseCase(NoParams());
    await Future.delayed(const Duration(milliseconds: 200));
    result.fold(
      (failure) {
        print('AuthBloc - Google login failed: ${failure.message}');
        emit(AuthFailure(message: failure.message));
      },
      (user) {
        print('AuthBloc - Google login successful: ${user.username}');
        emit(Authenticated(user: user));
        _registerToken();
      },
    );
  }

  Future<void> _onLogoutButtonPressed(
      LogoutButtonPressed event, Emitter<AuthState> emit) async {
    print('AuthBloc - Logout button pressed');
    emit(AuthLoading());
    try {
      await _deleteToken();
      await logoutUseCase(NoParams());
      print('AuthBloc - Logout successful, emitting Unauthenticated');
      emit(Unauthenticated());
    } catch (e) {
      print('AuthBloc - Logout failed: $e');
      emit(Unauthenticated());
    }
  }
}
