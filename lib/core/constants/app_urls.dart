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
  static const String aiSuggestions = '/ai/suggestions';
  static const String trendingRecommendations = '/ai/recommendations/trending';
  static const String personalizedRecommendations =
      '/ai/recommendations/personalized';

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
}
