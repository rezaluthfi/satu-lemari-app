// lib/core/di/injection.dart

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // <-- MAKE SURE THIS IS IMPORTED

import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/login_with_google_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../network/network_info.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // FEATURES - AUTH
  sl.registerFactory(
    () => AuthBloc(
      registerUseCase: sl(),
      loginWithEmailUseCase: sl(),
      loginWithGoogleUseCase: sl(),
      logoutUseCase: sl(),
      getCurrentUserUseCase: sl(),
    ),
  );

  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LoginWithEmailUseCase(sl()));
  sl.registerLazySingleton(() => LoginWithGoogleUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      dio: sl(),
      firebaseAuth: sl(),
      googleSignIn: sl(),
    ),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // CORE
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  // EXTERNAL DEPENDENCIES
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => GoogleSignIn());
  sl.registerLazySingleton(() => InternetConnectionChecker.createInstance());

  sl.registerLazySingleton(() {
    // Load the base URL from .env file
    final baseUrl = dotenv.env['API_BASE_URL'];
    if (baseUrl == null) {
      throw Exception("API_BASE_URL not found in .env file");
    }

    final options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    return Dio(options);
  });
}
