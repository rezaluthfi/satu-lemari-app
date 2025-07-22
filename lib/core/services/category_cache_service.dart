// lib/core/services/category_cache_service.dart

import 'package:satulemari/features/home/domain/entities/category.dart';

class CategoryCacheService {
  List<Category> _categories = [];

  List<Category> get categories => _categories;

  void setCategories(List<Category> categories) {
    _categories = categories;
  }

  String? getCategoryNameById(String id) {
    try {
      // Menggunakan firstWhere untuk menemukan kategori yang cocok
      return _categories.firstWhere((cat) => cat.id == id).name;
    } catch (e) {
      // Jika tidak ada kategori yang cocok (error StateError), kembalikan null
      return null;
    }
  }

  // --- TAMBAHKAN METHOD INI ---
  /// Mencari ID kategori berdasarkan namanya.
  /// Pencarian ini tidak peka terhadap huruf besar/kecil (case-insensitive).
  String? getCategoryIdByName(String name) {
    try {
      // Mencari kategori dengan nama yang sama (mengabaikan huruf besar/kecil)
      final category = _categories.firstWhere(
        (cat) => cat.name.toLowerCase() == name.toLowerCase(),
      );
      // Jika ditemukan, kembalikan ID-nya
      return category.id;
    } catch (e) {
      // Jika tidak ada kategori yang cocok (misalnya AI memberikan nama kategori
      // yang tidak ada di database kita), kembalikan null.
      return null;
    }
  }
}
