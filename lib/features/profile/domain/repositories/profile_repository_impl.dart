import 'package:dartz/dartz.dart';
import 'package:satulemari/core/errors/exceptions.dart';
import 'package:satulemari/core/errors/failures.dart';
import 'package:satulemari/core/network/network_info.dart';
import 'package:satulemari/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:satulemari/features/profile/data/models/update_profile_request.dart';
import 'package:satulemari/features/profile/domain/entities/dashboard_stats.dart';
import 'package:satulemari/features/profile/domain/entities/profile.dart';
import 'package:satulemari/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ProfileRepositoryImpl(
      {required this.remoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, Profile>> getProfile() async {
    if (await networkInfo.isConnected) {
      try {
        print("[PROFILE_REPO] Calling remoteDataSource.getProfile()...");
        final model = await remoteDataSource.getProfile();
        print("[PROFILE_REPO] Successfully got profile data");
        return Right(Profile(
          id: model.id,
          email: model.email,
          username: model.username,
          fullName: model.fullName,
          phone: model.phone,
          address: model.address,
          city: model.city,
          photo: model.photo,
          description: model.description,
          latitude: model.latitude, // <-- Tambahkan ini
          longitude: model.longitude, // <-- Tambahkan ini
          weeklyDonationQuota: model.weeklyDonationQuota,
          weeklyDonationUsed: model.weeklyDonationUsed,
          quotaResetDate: model.quotaResetDate,
        ));
      } on ServerException catch (e) {
        print("[PROFILE_REPO] ServerException caught: ${e.message}");
        return Left(ServerFailure(e.message));
      } catch (e) {
        print("[PROFILE_REPO] Unexpected exception: $e");
        return Left(ServerFailure('Gagal memuat profil: $e'));
      }
    } else {
      print("[PROFILE_REPO] No internet connection");
      return Left(ConnectionFailure('No Internet Connection'));
    }
  }

  @override
  Future<Either<Failure, DashboardStats>> getDashboardStats() async {
    if (await networkInfo.isConnected) {
      try {
        final model = await remoteDataSource.getDashboardStats();
        return Right(DashboardStats(
          totalDonations: model.totalDonations,
          totalRentals: model.totalRentals,
          activeItems: model.activeItems,
          pendingRequests: model.pendingRequests,
          completedRequests: model.completedRequests,
          weeklyQuotaUsed: model.weeklyQuotaUsed,
          weeklyQuotaRemaining: model.weeklyQuotaRemaining,
        ));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(ConnectionFailure('No Internet Connection'));
    }
  }

  @override
  Future<Either<Failure, Profile>> updateProfile(
      UpdateProfileRequest request) async {
    if (await networkInfo.isConnected) {
      try {
        final model = await remoteDataSource.updateProfile(request);
        return Right(Profile(
          id: model.id,
          email: model.email,
          username: model.username,
          fullName: model.fullName,
          phone: model.phone,
          address: model.address,
          city: model.city,
          photo: model.photo,
          description: model.description,
          latitude: model.latitude, // <-- Tambahkan ini
          longitude: model.longitude, // <-- Tambahkan ini
          weeklyDonationQuota: model.weeklyDonationQuota,
          weeklyDonationUsed: model.weeklyDonationUsed,
          quotaResetDate: model.quotaResetDate,
        ));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(ConnectionFailure('No Internet Connection'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteAccount();
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(ConnectionFailure('No Internet Connection'));
    }
  }
}
