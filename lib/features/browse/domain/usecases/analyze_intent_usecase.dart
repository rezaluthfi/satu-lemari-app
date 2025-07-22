// lib/features/browse/domain/usecases/analyze_intent_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:satulemari/core/errors/failures.dart';
import 'package:satulemari/core/usecases/usecase.dart';
import 'package:satulemari/features/browse/domain/entities/intent_analysis.dart';
import 'package:satulemari/features/browse/domain/repositories/browse_repository.dart';

class AnalyzeIntentUseCase implements UseCase<IntentAnalysis, String> {
  final BrowseRepository repository;

  AnalyzeIntentUseCase(this.repository);

  @override
  Future<Either<Failure, IntentAnalysis>> call(String params) async {
    return await repository.analyzeIntent(params);
  }
}
