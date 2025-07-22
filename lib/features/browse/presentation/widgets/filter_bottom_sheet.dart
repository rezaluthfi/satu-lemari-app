import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:satulemari/core/constants/app_colors.dart';
import 'package:satulemari/features/home/domain/entities/category.dart';
import 'package:satulemari/shared/widgets/custom_button.dart';

/// Formatter untuk mengubah input angka menjadi format mata uang Rupiah
/// dengan pemisah ribuan (titik).
class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    // Hapus semua karakter non-digit dari teks baru
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // Jika setelah dibersihkan menjadi kosong, kembalikan nilai kosong
    if (newText.isEmpty) {
      return const TextEditingValue();
    }

    // Parse ke double dan format dengan pemisah ribuan
    double value = double.parse(newText);
    final formatter = NumberFormat.decimalPattern('id_ID');
    String newTextFormatted = formatter.format(value);

    // Kembalikan nilai yang sudah diformat dengan kursor di akhir
    return newValue.copyWith(
        text: newTextFormatted,
        selection: TextSelection.collapsed(offset: newTextFormatted.length));
  }
}

// Class untuk data yang dikembalikan saat filter diterapkan
class FilterResult {
  final String? categoryId;
  final String? size;
  final String? sortBy;
  final String? sortOrder;
  final String? city;
  final double? minPrice;
  final double? maxPrice;

  FilterResult({
    this.categoryId,
    this.size,
    this.sortBy,
    this.sortOrder,
    this.city,
    this.minPrice,
    this.maxPrice,
  });
}

class FilterBottomSheet extends StatefulWidget {
  final List<Category> categories;
  final bool isRentalTab;
  final String? activeCategoryId;
  final String? activeSize;
  final String? activeSortBy;
  final String? activeSortOrder;
  final String? activeCity;
  final double? activeMinPrice;
  final double? activeMaxPrice;

  const FilterBottomSheet({
    super.key,
    required this.categories,
    required this.isRentalTab,
    this.activeCategoryId,
    this.activeSize,
    this.activeSortBy,
    this.activeSortOrder,
    this.activeCity,
    this.activeMinPrice,
    this.activeMaxPrice,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  String? _selectedCategoryId;
  String? _selectedSize;
  String? _selectedSortBy;
  String? _selectedSortOrder;

  late TextEditingController _cityController;
  late TextEditingController _minPriceController;
  late TextEditingController _maxPriceController;

  // State untuk menyimpan pesan error validasi harga
  String? _priceValidationError;

  final List<String> _sizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];
  final Map<String, String> _sortByOptions = {
    'created_at': 'Terbaru',
    'price': 'Harga',
    'name': 'Nama',
  };

  late Map<String, String> _filteredSortByOptions;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.activeCategoryId;
    _selectedSize = widget.activeSize;
    _selectedSortBy = widget.activeSortBy;
    _selectedSortOrder = widget.activeSortOrder ?? 'desc';

    _cityController = TextEditingController(text: widget.activeCity ?? '');

    final formatter = NumberFormat.decimalPattern('id_ID');
    _minPriceController = TextEditingController(
        text: widget.activeMinPrice != null
            ? formatter.format(widget.activeMinPrice)
            : '');
    _maxPriceController = TextEditingController(
        text: widget.activeMaxPrice != null
            ? formatter.format(widget.activeMaxPrice)
            : '');

    _filteredSortByOptions = Map.from(_sortByOptions);
    if (!widget.isRentalTab) {
      _filteredSortByOptions.remove('price');
      if (_selectedSortBy == 'price') {
        _selectedSortBy = null;
      }
    }
  }

  @override
  void dispose() {
    _cityController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  void _resetFilters() {
    Navigator.of(context).pop(FilterResult());
  }

  void _applyFilters() {
    // Selalu reset pesan error setiap kali tombol ditekan
    setState(() {
      _priceValidationError = null;
    });

    // Ambil nilai dan bersihkan dari format Rupiah (hapus titik)
    final minPriceString = _minPriceController.text.replaceAll('.', '');
    final maxPriceString = _maxPriceController.text.replaceAll('.', '');

    // Konversi ke double, anggap null jika string kosong
    final double? minPrice =
        minPriceString.isNotEmpty ? double.tryParse(minPriceString) : null;
    final double? maxPrice =
        maxPriceString.isNotEmpty ? double.tryParse(maxPriceString) : null;

    // Lakukan validasi
    if (widget.isRentalTab &&
        minPrice != null &&
        maxPrice != null &&
        minPrice > maxPrice) {
      // Set state untuk menampilkan pesan error di UI dan hentikan proses
      setState(() {
        _priceValidationError =
            'Harga minimal tidak boleh lebih besar dari harga maksimal.';
      });
      return;
    }

    // Jika valid, buat objek FilterResult dan kembalikan (pop)
    final result = FilterResult(
      categoryId: _selectedCategoryId,
      size: _selectedSize,
      sortBy: _selectedSortBy,
      sortOrder: _selectedSortOrder,
      city: _cityController.text.trim().isEmpty
          ? null
          : _cityController.text.trim(),
      minPrice: widget.isRentalTab ? minPrice : null,
      maxPrice: widget.isRentalTab ? maxPrice : null,
    );
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: const EdgeInsets.only(top: 20.0),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: _buildHeader(),
          ),
          const Divider(height: 24),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Urutkan Berdasarkan'),
                  const SizedBox(height: 12),
                  _buildSortByChips(),
                  const SizedBox(height: 12),
                  _buildSortOrderToggles(),
                  const SizedBox(height: 24),
                  if (widget.isRentalTab) ...[
                    _buildSectionTitle('Rentang Harga'),
                    const SizedBox(height: 12),
                    _buildPriceRangeFields(),
                    const SizedBox(height: 24),
                  ],
                  _buildSectionTitle('Lokasi (Kota)'),
                  const SizedBox(height: 12),
                  _buildCityField(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Kategori'),
                  const SizedBox(height: 12),
                  _buildCategoryChips(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Ukuran'),
                  const SizedBox(height: 12),
                  _buildSizeChips(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(
                20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                )
              ],
            ),
            child: CustomButton(
              text: 'Terapkan Filter',
              onPressed: _applyFilters,
              width: double.infinity,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Filter',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary)),
        TextButton(
          onPressed: _resetFilters,
          child: const Text('Reset Semua',
              style: TextStyle(
                  color: AppColors.primary, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary));
  }

  Widget _buildSortByChips() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: _filteredSortByOptions.entries.map((entry) {
        final isSelected = _selectedSortBy == entry.key;
        return ChoiceChip(
          label: Text(entry.value),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _selectedSortBy = selected ? entry.key : null;
            });
          },
          selectedColor: AppColors.primary,
          labelStyle: TextStyle(
              color: isSelected ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w500),
          backgroundColor: AppColors.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          side: BorderSide(
              color: isSelected ? AppColors.primary : AppColors.divider),
          showCheckmark: false,
        );
      }).toList(),
    );
  }

  Widget _buildSortOrderToggles() {
    return ToggleButtons(
      isSelected: [_selectedSortOrder == 'desc', _selectedSortOrder == 'asc'],
      onPressed: (index) {
        setState(() {
          _selectedSortOrder = index == 0 ? 'desc' : 'asc';
        });
      },
      borderRadius: BorderRadius.circular(8),
      selectedColor: Colors.white,
      color: AppColors.textPrimary,
      fillColor: AppColors.primary,
      borderColor: AppColors.divider,
      selectedBorderColor: AppColors.primary,
      constraints: BoxConstraints(
          minHeight: 40.0,
          minWidth: (MediaQuery.of(context).size.width - 48) / 2),
      children: const [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.arrow_downward, size: 16),
          SizedBox(width: 8),
          Text('Menurun')
        ]),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.arrow_upward, size: 16),
          SizedBox(width: 8),
          Text('Menaik')
        ]),
      ],
    );
  }

  Widget _buildPriceRangeFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
                child:
                    _buildTextField(_minPriceController, 'Harga Min', "Rp ")),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child:
                  Text('-', style: TextStyle(color: AppColors.textSecondary)),
            ),
            Expanded(
                child:
                    _buildTextField(_maxPriceController, 'Harga Max', "Rp ")),
          ],
        ),
        if (_priceValidationError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 12.0),
            child: Text(
              _priceValidationError!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCityField() {
    return _buildTextField(_cityController, 'Contoh: Jakarta', null);
  }

  Widget _buildTextField(
      TextEditingController controller, String hintText, String? prefixText) {
    final isPriceField = prefixText != null;
    final inputFormatters = isPriceField
        ? [FilteringTextInputFormatter.digitsOnly, CurrencyInputFormatter()]
        : <TextInputFormatter>[];

    return TextField(
      controller: controller,
      keyboardType: isPriceField ? TextInputType.number : TextInputType.text,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        hintText: hintText,
        prefixText: prefixText,
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.error)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error, width: 1.5)),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.divider)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.divider)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        isDense: true,
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: widget.categories.map((category) {
        final isSelected = _selectedCategoryId == category.id;
        return ChoiceChip(
          label: Text(category.name),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _selectedCategoryId = selected ? category.id : null;
            });
          },
          selectedColor: AppColors.primary,
          labelStyle: TextStyle(
              color: isSelected ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w500),
          backgroundColor: AppColors.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          side: BorderSide(
              color: isSelected ? AppColors.primary : AppColors.divider),
          showCheckmark: false,
        );
      }).toList(),
    );
  }

  Widget _buildSizeChips() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: _sizes.map((size) {
        final isSelected = _selectedSize == size;
        return ChoiceChip(
          label: Text(size),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _selectedSize = selected ? size : null;
            });
          },
          selectedColor: AppColors.primary,
          labelStyle: TextStyle(
              color: isSelected ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w500),
          backgroundColor: AppColors.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          side: BorderSide(
              color: isSelected ? AppColors.primary : AppColors.divider),
          showCheckmark: false,
        );
      }).toList(),
    );
  }
}
