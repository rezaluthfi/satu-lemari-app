import 'package:dartz/dartz.dart';
import 'package:satulemari/core/errors/failures.dart';
import 'package:satulemari/features/profile/domain/entities/dashboard_stats.dart';
import 'package:satulemari/features/profile/domain/entities/profile.dart';
import 'package:satulemari/features/profile/data/models/update_profile_request.dart';

abstract class ProfileRepository {
  Future<Either<Failure, Profile>> getProfile();
  Future<Either<Failure, DashboardStats>> getDashboardStats();
  Future<Either<Failure, Profile>> updateProfile(UpdateProfileRequest request);
  Future<Either<Failure, void>> deleteAccount();
}
