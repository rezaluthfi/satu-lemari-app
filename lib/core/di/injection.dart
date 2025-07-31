// lib/core/di/injection.dart

// Flutter & External Packages
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:satulemari/features/chat/domain/repositories/chat_repository_impl.dart';
import 'package:satulemari/features/chat/domain/usecases/delete_all_message_in_session.dart';
import 'package:satulemari/features/chat/domain/usecases/delete_specific_message.dart';
import 'package:satulemari/features/chat/presentation/bloc/sessions_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Core
import 'package:satulemari/core/network/auth_interceptor.dart';
import 'package:satulemari/core/network/network_info.dart';
import 'package:satulemari/core/services/category_cache_service.dart';
import 'package:satulemari/core/services/notification_service.dart';

// Auth
import 'package:satulemari/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:satulemari/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:satulemari/features/auth/domain/repositories/auth_repository.dart';
import 'package:satulemari/features/auth/domain/repositories/auth_repository_impl.dart';
import 'package:satulemari/features/auth/domain/usecases/delete_fcm_token_usecase.dart';
import 'package:satulemari/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:satulemari/features/auth/domain/usecases/login_usecase.dart';
import 'package:satulemari/features/auth/domain/usecases/login_with_google_usecase.dart';
import 'package:satulemari/features/auth/domain/usecases/logout_usecase.dart';
import 'package:satulemari/features/auth/domain/usecases/register_fcm_token_usecase.dart';
import 'package:satulemari/features/auth/domain/usecases/register_usecase.dart';
import 'package:satulemari/features/auth/presentation/bloc/auth_bloc.dart';

// Home
import 'package:satulemari/features/home/data/datasources/home_remote_datasource.dart';
import 'package:satulemari/features/home/domain/repositories/home_repository.dart';
import 'package:satulemari/features/home/domain/repositories/home_repository_impl.dart';
import 'package:satulemari/features/home/domain/usecases/get_categories_usecase.dart';
import 'package:satulemari/features/home/domain/usecases/get_personalized_recommendations_usecase.dart';
import 'package:satulemari/features/home/domain/usecases/get_trending_items_usecase.dart';
import 'package:satulemari/features/home/presentation/bloc/home_bloc.dart';

// Browse
import 'package:satulemari/features/browse/data/datasources/browse_remote_datasource.dart';
import 'package:satulemari/features/browse/domain/repositories/browse_repository.dart';
import 'package:satulemari/features/browse/domain/repositories/browse_repository_impl.dart';
import 'package:satulemari/features/browse/domain/usecases/analyze_intent_usecase.dart';
import 'package:satulemari/features/browse/domain/usecases/get_ai_suggestions_usecase.dart';
import 'package:satulemari/features/browse/domain/usecases/get_similar_items_usecase.dart';
import 'package:satulemari/features/browse/domain/usecases/search_items_usecase.dart';
import 'package:satulemari/features/browse/presentation/bloc/browse_bloc.dart';

// Category Items
import 'package:satulemari/features/category_items/data/datasources/category_items_remote_datasource.dart';
import 'package:satulemari/features/category_items/domain/repositories/category_items_repository.dart';
import 'package:satulemari/features/category_items/domain/repositories/category_items_repository_impl.dart';
import 'package:satulemari/features/category_items/domain/usecases/get_items_by_category_usecase.dart';
import 'package:satulemari/features/category_items/presentation/bloc/category_items_bloc.dart';

// Item Detail
import 'package:satulemari/features/item_detail/data/datasources/item_detail_remote_datasource.dart';
import 'package:satulemari/features/item_detail/domain/repositories/item_detail_repository.dart';
import 'package:satulemari/features/item_detail/domain/repositories/item_detail_repository_impl.dart';
import 'package:satulemari/features/item_detail/domain/usecases/get_item_by_id_usecase.dart';
import 'package:satulemari/features/item_detail/domain/usecases/get_item_by_ids_usecase.dart';
import 'package:satulemari/features/item_detail/presentation/bloc/item_detail_bloc.dart';

// Request
import 'package:satulemari/features/request/data/datasources/request_remote_datasource.dart';
import 'package:satulemari/features/request/domain/repositories/request_repository.dart';
import 'package:satulemari/features/request/domain/repositories/request_repository_impl.dart';
import 'package:satulemari/features/request/domain/usecases/create_request_usecase.dart';
import 'package:satulemari/features/request/presentation/bloc/request_bloc.dart';

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
import 'package:satulemari/features/notification/domain/usecases/delete_multiple_notification_usecase.dart';
import 'package:satulemari/features/notification/domain/usecases/delete_notification_usecase.dart';
import 'package:satulemari/features/notification/domain/usecases/get_my_notifications_usecase.dart';
import 'package:satulemari/features/notification/domain/usecases/get_notification_stats_usecase.dart';
import 'package:satulemari/features/notification/domain/usecases/mark_all_notifications_as_read_usecase.dart';
import 'package:satulemari/features/notification/domain/usecases/mark_multiple_notifications_as_read_usecase.dart';
import 'package:satulemari/features/notification/domain/usecases/mark_notification_as_read.dart';
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

// =================== CHATBOT IMPORTS ===================
import 'package:satulemari/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:satulemari/features/chat/domain/repositories/chat_repository.dart';
import 'package:satulemari/features/chat/domain/usecases/delete_all_user_history.dart';
import 'package:satulemari/features/chat/domain/usecases/delete_chat_session.dart';
import 'package:satulemari/features/chat/domain/usecases/get_chat_history.dart';
import 'package:satulemari/features/chat/domain/usecases/get_chat_suggestions.dart';
import 'package:satulemari/features/chat/domain/usecases/get_user_sessions.dart';
import 'package:satulemari/features/chat/domain/usecases/send_chat_message.dart';
import 'package:satulemari/features/chat/domain/usecases/start_chat_session.dart';
import 'package:satulemari/features/chat/presentation/bloc/chat_bloc.dart';
// =======================================================

final sl = GetIt.instance;

Future<void> init() async {
  // --- FEATURES ---

  // Auth
  sl.registerLazySingleton(() => AuthBloc(
      registerUseCase: sl(),
      loginWithEmailUseCase: sl(),
      loginWithGoogleUseCase: sl(),
      logoutUseCase: sl(),
      getCurrentUserUseCase: sl(),
      notificationService: sl(),
      registerFCMTokenUseCase: sl(),
      deleteFCMTokenUseCase: sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LoginWithEmailUseCase(sl()));
  sl.registerLazySingleton(() => LoginWithGoogleUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => RegisterFCMTokenUseCase(sl()));
  sl.registerLazySingleton(() => DeleteFCMTokenUseCase(sl()));
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(
      remoteDataSource: sl(), localDataSource: sl(), networkInfo: sl()));
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(
      dio: sl(), firebaseAuth: sl(), googleSignIn: sl()));
  sl.registerLazySingleton<AuthLocalDataSource>(
      () => AuthLocalDataSourceImpl(sharedPreferences: sl()));

  // Home
  sl.registerLazySingleton(() => HomeBloc(
      getCategories: sl(),
      getTrendingItems: sl(),
      getPersonalizedRecommendations: sl(),
      getItemsByIds: sl(),
      categoryCache: sl()));
  sl.registerLazySingleton(() => GetCategoriesUseCase(sl()));
  sl.registerLazySingleton(() => GetTrendingItemsUseCase(sl()));
  sl.registerLazySingleton(() => GetPersonalizedRecommendationsUseCase(sl()));
  sl.registerLazySingleton<HomeRepository>(
      () => HomeRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()));
  sl.registerLazySingleton<HomeRemoteDataSource>(
      () => HomeRemoteDataSourceImpl(dio: sl()));

  // Browse
  sl.registerLazySingleton(
    () => BrowseBloc(
      searchItems: sl(),
      getAiSuggestions: sl(),
      analyzeIntent: sl(),
    ),
  );
  sl.registerLazySingleton(() => SearchItemsUseCase(sl()));
  sl.registerLazySingleton(() => GetAiSuggestionsUseCase(sl()));
  sl.registerLazySingleton(() => AnalyzeIntentUseCase(sl()));
  sl.registerLazySingleton(() => GetSimilarItemsUseCase(sl()));
  sl.registerLazySingleton<BrowseRepository>(() => BrowseRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
      categoryCache: sl(),
      itemDetailRemoteDataSource: sl()));
  sl.registerLazySingleton<BrowseRemoteDataSource>(
      () => BrowseRemoteDataSourceImpl(dio: sl()));

  // Category Items
  sl.registerFactory(() => CategoryItemsBloc(getItemsByCategory: sl()));
  sl.registerLazySingleton(() => GetItemsByCategoryUseCase(sl()));
  sl.registerLazySingleton<CategoryItemsRepository>(() =>
      CategoryItemsRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()));
  sl.registerLazySingleton<CategoryItemsRemoteDataSource>(
      () => CategoryItemsRemoteDataSourceImpl(dio: sl()));

  // Item Detail
  sl.registerFactory(() => ItemDetailBloc(
        getItemById: sl(),
        getMyRequests: sl(),
        getDashboardStats: sl(),
        getSimilarItems: sl(),
      ));
  sl.registerLazySingleton(() => GetItemByIdUseCase(sl()));
  sl.registerLazySingleton(() => GetItemsByIdsUseCase(sl()));
  sl.registerLazySingleton<ItemDetailRepository>(() =>
      ItemDetailRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()));
  sl.registerLazySingleton<ItemDetailRemoteDataSource>(
      () => ItemDetailRemoteDataSourceImpl(dio: sl()));

  // Request
  sl.registerFactory(() => RequestBloc(createRequest: sl()));
  sl.registerLazySingleton(() => CreateRequestUseCase(sl()));
  sl.registerLazySingleton<RequestRepository>(
      () => RequestRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()));
  sl.registerLazySingleton<RequestRemoteDataSource>(
      () => RequestRemoteDataSourceImpl(dio: sl()));

  // History
  sl.registerLazySingleton(() => HistoryBloc(getMyRequests: sl()));
  sl.registerFactory(
      () => RequestDetailBloc(getRequestDetail: sl(), deleteRequest: sl()));
  sl.registerLazySingleton(() => GetMyRequestsUseCase(sl()));
  sl.registerLazySingleton(() => GetRequestDetailUseCase(sl()));
  sl.registerLazySingleton(() => DeleteRequestUseCase(sl()));
  sl.registerLazySingleton<HistoryRepository>(
      () => HistoryRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()));
  sl.registerLazySingleton<HistoryRemoteDataSource>(
      () => HistoryRemoteDataSourceImpl(dio: sl()));

  // Notification
  sl.registerLazySingleton(() => NotificationBloc(
      getMyNotifications: sl(),
      getNotificationStats: sl(),
      markAllAsRead: sl(),
      markAsRead: sl(),
      deleteNotification: sl(),
      deleteMultipleNotifications: sl(),
      markMultipleAsRead: sl()));
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

  // Profile
  sl.registerLazySingleton(() => ProfileBloc(
      getProfile: sl(),
      getDashboardStats: sl(),
      updateProfile: sl(),
      deleteAccount: sl(),
      authBloc: sl()));
  sl.registerLazySingleton(() => GetProfileUseCase(sl()));
  sl.registerLazySingleton(() => GetDashboardStatsUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
  sl.registerLazySingleton(() => DeleteAccountUseCase(sl()));
  sl.registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()));
  sl.registerLazySingleton<ProfileRemoteDataSource>(
      () => ProfileRemoteDataSourceImpl(dio: sl()));

  // =================== CHATBOT REGISTRATIONS ===================
  // BLoC
  sl.registerFactory(() => ChatBloc(
        startChatSession: sl(),
        sendChatMessage: sl(),
        getChatHistory: sl(),
        getChatSuggestions: sl(),
        deleteSpecificMessages: sl(),
        deleteAllMessagesInSession: sl(),
      ));
  sl.registerLazySingleton(() => SessionsBloc(
        getUserSessions: sl(),
        deleteAllUserHistory: sl(),
        deleteChatSession: sl(),
      ));

  // Usecases
  sl.registerLazySingleton(() => StartChatSession(sl()));
  sl.registerLazySingleton(() => SendChatMessage(sl()));
  sl.registerLazySingleton(() => GetChatHistory(sl()));
  sl.registerLazySingleton(() => GetUserSessions(sl()));
  sl.registerLazySingleton(() => GetChatSuggestions(sl()));
  sl.registerLazySingleton(() => DeleteSpecificMessages(sl()));
  sl.registerLazySingleton(() => DeleteAllMessagesInSession(sl()));
  sl.registerLazySingleton(() => DeleteChatSession(sl()));
  sl.registerLazySingleton(() => DeleteAllUserHistory(sl()));

  // Repository
  sl.registerLazySingleton<ChatRepository>(
      () => ChatRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()));

  // DataSource
  sl.registerLazySingleton<ChatRemoteDataSource>(
      () => ChatRemoteDataSourceImpl(dio: sl()));
  // ===========================================================

  // --- CORE & EXTERNAL ---
  sl.registerLazySingleton(() => NotificationService());
  sl.registerLazySingleton(() => CategoryCacheService());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton(() => AuthInterceptor(sl()));
  sl.registerLazySingleton(() => CookieJar());
  sl.registerLazySingleton(() => CookieManager(sl<CookieJar>()));
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => GoogleSignIn());
  sl.registerLazySingleton(() => InternetConnectionChecker.createInstance());
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
        });
    final dio = Dio(options);
    dio.interceptors.add(sl<CookieManager>());
    dio.interceptors.add(sl<AuthInterceptor>());
    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
    return dio;
  });
}
