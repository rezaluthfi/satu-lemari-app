import 'package:dartz/dartz.dart';
import 'package:satulemari/core/errors/failures.dart';
import 'package:satulemari/core/usecases/usecase.dart';
import 'package:satulemari/features/home/domain/repositories/home_repository.dart';

class GetPersonalizedRecommendationsUseCase
    implements UseCase<List<String>, NoParams> {
  final HomeRepository repository;
  GetPersonalizedRecommendationsUseCase(this.repository);

  @override
  Future<Either<Failure, List<String>>> call(NoParams params) async {
    return await repository.getPersonalizedRecommendationIds();
  }
}
