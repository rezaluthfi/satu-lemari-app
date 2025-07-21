// Extension ini menambahkan fungsionalitas baru ke class String yang sudah ada.
extension ConditionFormatter on String {
  /// Mengubah nilai kondisi dari backend (e.g., 'excellent', 'good')
  /// menjadi format yang lebih ramah pengguna dalam Bahasa Indonesia.
  String toFormattedCondition() {
    // Mengubah string ke huruf kecil untuk perbandingan yang konsisten
    switch (toLowerCase()) {
      case 'excellent':
        return 'Sangat Baik';
      case 'good':
        return 'Baik';
      case 'fair':
        return 'Cukup';
      default:
        // Mengembalikan string asli dengan huruf pertama kapital jika tidak ada yang cocok.
        // Ini sebagai fallback yang aman.
        if (isEmpty) return '-';
        return '${this[0].toUpperCase()}${substring(1)}';
    }
  }
}
