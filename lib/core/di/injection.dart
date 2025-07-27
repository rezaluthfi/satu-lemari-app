// Flutter & External Packages
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:satulemari/core/services/category_cache_service.dart';
import 'package:satulemari/features/item_detail/domain/usecases/get_item_by_ids_usecase.dart';
import 'package:satulemari/features/notification/domain/usecases/delete_multiple_notification_usecase.dart';
import 'package:satulemari/features/notification/domain/usecases/mark_multiple_notifications_as_read_usecase.dart';
import 'package:satulemari/features/notification/domain/usecases/mark_notification_as_read.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Core
import 'package:satulemari/core/services/notification_service.dart';
import '../network/auth_interceptor.dart';
import '../network/network_info.dart';

// Auth
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/usecases/delete_fcm_token_usecase.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/login_with_google_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/register_fcm_token_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

// Home
import '../../features/home/data/datasources/home_remote_datasource.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/domain/repositories/home_repository_impl.dart';
import '../../features/home/domain/usecases/get_categories_usecase.dart';
import '../../features/home/domain/usecases/get_trending_items_usecase.dart';
import '../../features/home/domain/usecases/get_personalized_recommendations_usecase.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';

// Browse
import 'package:satulemari/features/browse/data/datasources/browse_remote_datasource.dart';
import 'package:satulemari/features/browse/domain/repositories/browse_repository.dart';
import 'package:satulemari/features/browse/domain/repositories/browse_repository_impl.dart';
import 'package:satulemari/features/browse/domain/usecases/get_ai_suggestions_usecase.dart';
import 'package:satulemari/features/browse/domain/usecases/search_items_usecase.dart';
import 'package:satulemari/features/browse/domain/usecases/analyze_intent_usecase.dart';
import 'package:satulemari/features/browse/presentation/bloc/browse_bloc.dart';

// History
import 'package:satulemari/features/history/data/datasources/history_remote_datasource.dart';
import 'package:satulemari/features/history/domain/repositories/history_repository.dart';
import 'package:satulemari/features/history/domain/repositories/history_repository_impl.dart';
import 'package:satulemari/features/history/domain/usecases/delete_request_usecase.dart';
import 'package:satulemari/features/history/domain/usecases/get_my_requests_usecase.dart';
import 'package:satulemari/features/history/domain/usecases/get_request_detail_usecase.dart';
import 'package:satulemari/features/history/presentation/bloc/history_bloc.dart';
import 'package:satulemari/features/history/presentation/bloc/request_detail_bloc.dart';

// Notification
import 'package:satulemari/features/notification/data/datasources/notification_remote_datasource.dart';
import 'package:satulemari/features/notification/domain/repositories/notification_repository.dart';
import 'package:satulemari/features/notification/domain/repositories/notification_repository_impl.dart';
import 'package:satulemari/features/notification/domain/usecases/delete_notification_usecase.dart';
import 'package:satulemari/features/notification/domain/usecases/get_my_notifications_usecase.dart';
import 'package:satulemari/features/notification/domain/usecases/get_notification_stats_usecase.dart';
import 'package:satulemari/features/notification/domain/usecases/mark_all_notifications_as_read_usecase.dart';
import 'package:satulemari/features/notification/presentation/bloc/notification_bloc.dart';

// Profile
import 'package:satulemari/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:satulemari/features/profile/domain/repositories/profile_repository.dart';
import 'package:satulemari/features/profile/domain/repositories/profile_repository_impl.dart';
import 'package:satulemari/features/profile/domain/usecases/delete_account_usecase.dart';
import 'package:satulemari/features/profile/domain/usecases/get_dashboard_stats_usecase.dart';
import 'package:satulemari/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:satulemari/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:satulemari/features/profile/presentation/bloc/profile_bloc.dart';

// Request
import 'package:satulemari/features/request/data/datasources/request_remote_datasource.dart';
import 'package:satulemari/features/request/domain/repositories/request_repository.dart';
import 'package:satulemari/features/request/domain/repositories/request_repository_impl.dart';
import 'package:satulemari/features/request/domain/usecases/create_request_usecase.dart';
import 'package:satulemari/features/request/presentation/bloc/request_bloc.dart';

// Item Detail
import 'package:satulemari/features/item_detail/data/datasources/item_detail_remote_datasource.dart';
import 'package:satulemari/features/item_detail/domain/repositories/item_detail_repository.dart';
import 'package:satulemari/features/item_detail/domain/repositories/item_detail_repository_impl.dart';
import 'package:satulemari/features/item_detail/domain/usecases/get_item_by_id_usecase.dart';
import 'package:satulemari/features/item_detail/presentation/bloc/item_detail_bloc.dart';

// Category Items
import 'package:satulemari/features/category_items/data/datasources/category_items_remote_datasource.dart';
import 'package:satulemari/features/category_items/domain/repositories/category_items_repository.dart';
import 'package:satulemari/features/category_items/domain/repositories/category_items_repository_impl.dart';
import 'package:satulemari/features/category_items/domain/usecases/get_items_by_category_usecase.dart';
import 'package:satulemari/features/category_items/presentation/bloc/category_items_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // --- FEATURES ---

  // Auth Feature (Singleton is correct)
  sl.registerLazySingleton(() => AuthBloc(
        registerUseCase: sl(),
        loginWithEmailUseCase: sl(),
        loginWithGoogleUseCase: sl(),
        logoutUseCase: sl(),
        getCurrentUserUseCase: sl(),
        notificationService: sl(),
        registerFCMTokenUseCase: sl(),
        deleteFCMTokenUseCase: sl(),
      ));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LoginWithEmailUseCase(sl()));
  sl.registerLazySingleton(() => LoginWithGoogleUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => RegisterFCMTokenUseCase(sl()));
  sl.registerLazySingleton(() => DeleteFCMTokenUseCase(sl()));
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(
        remoteDataSource: sl(),
        localDataSource: sl(),
        networkInfo: sl(),
      ));
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(
      dio: sl(), firebaseAuth: sl(), googleSignIn: sl()));
  sl.registerLazySingleton<AuthLocalDataSource>(
      () => AuthLocalDataSourceImpl(sharedPreferences: sl()));

  // Home Feature -> Singleton
  sl.registerLazySingleton(() => HomeBloc(
        getCategories: sl(),
        getTrendingItems: sl(),
        getPersonalizedRecommendations: sl(),
        getItemsByIds: sl(),
        categoryCache: sl(),
      ));
  sl.registerLazySingleton(() => GetCategoriesUseCase(sl()));
  sl.registerLazySingleton(() => GetTrendingItemsUseCase(sl()));
  sl.registerLazySingleton(() => GetPersonalizedRecommendationsUseCase(sl()));
  sl.registerLazySingleton<HomeRepository>(
      () => HomeRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()));
  sl.registerLazySingleton<HomeRemoteDataSource>(
      () => HomeRemoteDataSourceImpl(dio: sl()));

  // Browse Feature -> Singleton
  sl.registerLazySingleton(() => BrowseBloc(
        searchItems: sl(),
        getAiSuggestions: sl(),
        analyzeIntent: sl(),
      ));
  sl.registerLazySingleton(() => SearchItemsUseCase(sl()));
  sl.registerLazySingleton(() => GetAiSuggestionsUseCase(sl()));
  sl.registerLazySingleton(() => AnalyzeIntentUseCase(sl()));
  sl.registerLazySingleton<BrowseRepository>(() => BrowseRepositoryImpl(
        remoteDataSource: sl(),
        networkInfo: sl(),
        categoryCache: sl(),
      ));
  sl.registerLazySingleton<BrowseRemoteDataSource>(
      () => BrowseRemoteDataSourceImpl(dio: sl()));

  // Category Items Feature -> Factory is acceptable
  sl.registerFactory(() => CategoryItemsBloc(getItemsByCategory: sl()));
  sl.registerLazySingleton(() => GetItemsByCategoryUseCase(sl()));
  sl.registerLazySingleton<CategoryItemsRepository>(() =>
      CategoryItemsRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()));
  sl.registerLazySingleton<CategoryItemsRemoteDataSource>(
      () => CategoryItemsRemoteDataSourceImpl(dio: sl()));

  // Item Detail Feature -> Factory is acceptable
  sl.registerFactory(() => ItemDetailBloc(
        getItemById: sl(),
        getMyRequests: sl(),
        getDashboardStats: sl(),
      ));
  sl.registerLazySingleton(() => GetItemByIdUseCase(sl()));
  sl.registerLazySingleton(() => GetItemsByIdsUseCase(sl()));
  sl.registerLazySingleton<ItemDetailRepository>(() =>
      ItemDetailRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()));
  sl.registerLazySingleton<ItemDetailRemoteDataSource>(
      () => ItemDetailRemoteDataSourceImpl(dio: sl()));

  // Request Feature -> Factory is acceptable
  sl.registerFactory(() => RequestBloc(createRequest: sl()));
  sl.registerLazySingleton(() => CreateRequestUseCase(sl()));
  sl.registerLazySingleton<RequestRepository>(
      () => RequestRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()));
  sl.registerLazySingleton<RequestRemoteDataSource>(
      () => RequestRemoteDataSourceImpl(dio: sl()));

  // History Feature -> Singleton
  sl.registerLazySingleton(() => HistoryBloc(getMyRequests: sl()));
  // RequestDetailBloc is for a specific page, Factory is better here
  sl.registerFactory(
      () => RequestDetailBloc(getRequestDetail: sl(), deleteRequest: sl()));
  sl.registerLazySingleton(() => GetMyRequestsUseCase(sl()));
  sl.registerLazySingleton(() => GetRequestDetailUseCase(sl()));
  sl.registerLazySingleton(() => DeleteRequestUseCase(sl()));
  sl.registerLazySingleton<HistoryRepository>(
      () => HistoryRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()));
  sl.registerLazySingleton<HistoryRemoteDataSource>(
      () => HistoryRemoteDataSourceImpl(dio: sl()));

  // Notification Feature -> Singleton
  sl.registerLazySingleton(() => NotificationBloc(
        getMyNotifications: sl(),
        getNotificationStats: sl(),
        markAllAsRead: sl(),
        markAsRead: sl(),
        deleteNotification: sl(),
        deleteMultipleNotifications: sl(),
        markMultipleAsRead: sl(),
      ));
  sl.registerLazySingleton(() => GetMyNotificationsUseCase(sl()));
  sl.registerLazySingleton(() => GetNotificationStatsUseCase(sl()));
  sl.registerLazySingleton(() => MarkAllNotificationsAsReadUseCase(sl()));
  sl.registerLazySingleton(() => MarkNotificationAsReadUseCase(sl()));
  sl.registerLazySingleton(() => DeleteNotificationUseCase(sl()));
  sl.registerLazySingleton(() => DeleteMultipleNotificationsUseCase(sl()));
  sl.registerLazySingleton(() => MarkMultipleNotificationsAsReadUseCase(sl()));
  sl.registerLazySingleton<NotificationRepository>(() =>
      NotificationRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()));
  sl.registerLazySingleton<NotificationRemoteDataSource>(
      () => NotificationRemoteDataSourceImpl(dio: sl()));

  // Profile Feature -> Singleton (MOST IMPORTANT CHANGE)
  sl.registerLazySingleton(() => ProfileBloc(
        getProfile: sl(),
        getDashboardStats: sl(),
        updateProfile: sl(),
        deleteAccount: sl(),
        authBloc: sl(),
      ));
  sl.registerLazySingleton(() => GetProfileUseCase(sl()));
  sl.registerLazySingleton(() => GetDashboardStatsUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
  sl.registerLazySingleton(() => DeleteAccountUseCase(sl()));
  sl.registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()));
  sl.registerLazySingleton<ProfileRemoteDataSource>(
      () => ProfileRemoteDataSourceImpl(dio: sl()));

  // --- CORE ---
  sl.registerLazySingleton(() => NotificationService());
  sl.registerLazySingleton(() => CategoryCacheService());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton(() => AuthInterceptor(sl()));

  // --- EXTERNAL ---
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => GoogleSignIn());
  sl.registerLazySingleton(() => InternetConnectionChecker.createInstance());

  // Dio
  sl.registerLazySingleton(() {
    final baseUrl = dotenv.env['API_BASE_URL'];
    if (baseUrl == null) {
      throw Exception("API_BASE_URL not found in .env file");
    }
    final options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
    );

    final dio = Dio(options);

    dio.interceptors.add(sl<AuthInterceptor>());
    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));

    return dio;
  });
}
