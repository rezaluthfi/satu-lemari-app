class AppUrls {
  // Auth
  static const String authVerify = '/auth/verify';
  static const String authRefresh = '/auth/refresh';

  // Home & Items
  static const String categories = '/categories';
  static const String items = '/items';
  static const String myItems = '/my-items';
  static const String searchItems = '/items/search';

  // AI
  static const String aiIntent = '/ai/intent';
  static const String aiSuggestions = '/ai/suggestions';
  static const String trendingRecommendations = '/ai/recommendations/trending';
  static const String personalizedRecommendations =
      '/ai/recommendations/personalized';
  static const String aiSimilarItems = '/ai/recommendations/similar';

  // --- TAMBAHKAN URL INI ---
  // User Profile & Dashboard
  static const String userProfile = '/users/me';
  static const String userDashboard = '/users/dashboard';
  // Untuk public profile, ID akan ditambahkan secara dinamis
  static const String publicUserProfileBase = '/users/';
  // ---

  // History
  static const String myRequests = '/requests/my';
  static const String requests = '/requests';

  // Notifications
  static const String fcmToken = '/notifications/fcm-token';
  static const String notifications = '/notifications';
  static const String notificationStats = '/notifications/stats';
  static const String markNotificationsRead =
      '/notifications/mark-read'; // Untuk multiple
  static const String markAllNotificationsRead =
      '/notifications/read-all'; // Untuk semua
  static const String deleteNotificationsBulk = '/notifications/delete-bulk';
}
