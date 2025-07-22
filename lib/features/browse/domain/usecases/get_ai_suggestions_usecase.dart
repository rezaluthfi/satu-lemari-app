import 'package:dartz/dartz.dart';
import 'package:satulemari/core/errors/failures.dart';
import 'package:satulemari/core/usecases/usecase.dart';
import 'package:satulemari/features/browse/domain/entities/ai_suggestions.dart';
import 'package:satulemari/features/browse/domain/repositories/browse_repository.dart';

class GetAiSuggestionsUseCase implements UseCase<AiSuggestions, String> {
  final BrowseRepository repository;

  GetAiSuggestionsUseCase(this.repository);

  @override
  Future<Either<Failure, AiSuggestions>> call(String params) async {
    // Jangan panggil API jika query kosong
    if (params.trim().isEmpty) {
      return const Right(AiSuggestions(query: '', suggestions: []));
    }

    final result = await repository.getAiSuggestions(params);

    // Di sini kita memproses dan memfilter hasilnya jika berhasil
    return result.map((suggestionsEntity) {
      // Daftar kata kunci yang menandakan saran tersebut adalah instruksi, bukan produk
      final filterKeywords = [
        'coba',
        'cari',
        'spesifik',
        'lebih',
        'kata kunci',
        'mungkin maksud anda',
        'dengan'
      ];

      // Filter daftar saran. Hanya simpan saran yang TIDAK mengandung kata kunci di atas.
      final filteredList = suggestionsEntity.suggestions.where((suggestion) {
        final lowerCaseSuggestion = suggestion.toLowerCase();
        // Cek apakah ada kata kunci dari `filterKeywords` yang terkandung di dalam saran
        return !filterKeywords
            .any((keyword) => lowerCaseSuggestion.contains(keyword));
      }).toList();

      // Kembalikan Entitas AiSuggestions baru dengan daftar yang sudah difilter
      return AiSuggestions(
        query: suggestionsEntity.query,
        suggestions: filteredList,
      );
    });
  }
}
