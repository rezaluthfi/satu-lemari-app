// lib/core/utils/fab_position_manager.dart
class FabPositionManager {
  static final FabPositionManager _instance = FabPositionManager._internal();
  factory FabPositionManager() => _instance;
  FabPositionManager._internal();

  // Posisi FAB untuk halaman yang berbeda
  Map<String, FabPosition> _positions = {};

  // Konstanta untuk key halaman
  static const String homePageKey = 'home_page';
  static const String chatSessionsPageKey = 'chat_sessions_page';

  void savePosition(String pageKey, double x, double y) {
    _positions[pageKey] = FabPosition(x: x, y: y);
  }

  FabPosition? getPosition(String pageKey) {
    return _positions[pageKey];
  }

  FabPosition getDefaultPosition(
      String pageKey, double screenWidth, double screenHeight) {
    const double fabSize = 56.0;
    const double sidePadding = 16.0;
    double bottomSafeZone;

    // Sesuaikan bottom safe zone berdasarkan halaman
    switch (pageKey) {
      case homePageKey:
        bottomSafeZone = 64.0; // Bottom navigation area
        break;
      case chatSessionsPageKey:
        bottomSafeZone = 80.0; // Bottom safe area
        break;
      default:
        bottomSafeZone = 80.0;
    }

    return FabPosition(
      x: screenWidth - fabSize - sidePadding,
      y: screenHeight - bottomSafeZone - fabSize - sidePadding,
    );
  }

  bool hasPosition(String pageKey) {
    return _positions.containsKey(pageKey);
  }
}

class FabPosition {
  final double x;
  final double y;

  FabPosition({required this.x, required this.y});

  @override
  String toString() => 'FabPosition(x: $x, y: $y)';
}
