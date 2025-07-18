import 'package:dartz/dartz.dart';
import 'package:satulemari/core/errors/failures.dart';
import 'package:satulemari/core/usecases/usecase.dart';
import 'package:satulemari/features/profile/domain/entities/dashboard_stats.dart';
import 'package:satulemari/features/profile/domain/repositories/profile_repository.dart';

class GetDashboardStatsUseCase implements UseCase<DashboardStats, NoParams> {
  final ProfileRepository repository;
  GetDashboardStatsUseCase(this.repository);

  @override
  Future<Either<Failure, DashboardStats>> call(NoParams params) async {
    return await repository.getDashboardStats();
  }
}
