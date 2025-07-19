import 'package:flutter/material.dart';
import 'package:satulemari/core/constants/app_colors.dart';
import 'package:satulemari/features/home/domain/entities/category.dart';
import 'package:satulemari/shared/widgets/custom_button.dart';

// Class untuk data yang dikembalikan saat filter diterapkan
class FilterResult {
  final String? categoryId;
  final String? size;

  FilterResult({this.categoryId, this.size});
}

class FilterBottomSheet extends StatefulWidget {
  final List<Category> categories;
  // Menerima filter yang aktif saat ini
  final String? activeCategoryId;
  final String? activeSize;

  const FilterBottomSheet({
    super.key,
    required this.categories,
    this.activeCategoryId,
    this.activeSize,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  String? _selectedCategoryId;
  String? _selectedSize;

  // Daftar ukuran hardcoded untuk contoh
  final List<String> _sizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];

  @override
  void initState() {
    super.initState();
    // Inisialisasi state dengan filter yang aktif
    _selectedCategoryId = widget.activeCategoryId;
    _selectedSize = widget.activeSize;
  }

  void _resetFilters() {
    setState(() {
      _selectedCategoryId = null;
      _selectedSize = null;
    });
    // Langsung kembalikan FilterResult untuk mereset filter
    Navigator.of(context).pop(FilterResult(categoryId: null, size: null));
  }

  void _applyFilters() {
    final result = FilterResult(
      categoryId: _selectedCategoryId,
      size: _selectedSize,
    );
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0)
          .copyWith(bottom: MediaQuery.of(context).padding.bottom + 20),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildSectionTitle('Kategori'),
          const SizedBox(height: 12),
          _buildCategoryChips(),
          const SizedBox(height: 24),
          _buildSectionTitle('Ukuran'),
          const SizedBox(height: 12),
          _buildSizeChips(),
          const SizedBox(height: 32),
          CustomButton(
            text: 'Terapkan Filter',
            onPressed: _applyFilters,
            width: double.infinity,
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
          child: const Text('Reset',
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
