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
}