import 'package:dartz/dartz.dart';
import 'package:satulemari/core/errors/failures.dart';
import 'package:satulemari/features/browse/domain/entities/ai_suggestions.dart';
import 'package:satulemari/features/browse/domain/entities/intent_analysis.dart';
import 'package:satulemari/features/category_items/domain/entities/item_entity.dart';
import 'package:satulemari/features/browse/domain/usecases/search_items_usecase.dart';

abstract class BrowseRepository {
  Future<Either<Failure, List<Item>>> searchItems(SearchItemsParams params);
  Future<Either<Failure, AiSuggestions>> getAiSuggestions(String query);
  Future<Either<Failure, IntentAnalysis>> analyzeIntent(String query);
  Future<Either<Failure, List<Item>>> getSimilarItems(String itemId);
}
