import 'package:dartz/dartz.dart';
import 'package:satulemari/core/errors/exceptions.dart';
import 'package:satulemari/core/errors/failures.dart';
import 'package:satulemari/core/network/network_info.dart';
import 'package:satulemari/features/history/data/datasources/history_remote_datasource.dart';
import 'package:satulemari/features/history/domain/entities/request_detail.dart';
import 'package:satulemari/features/history/domain/entities/request_item.dart';
import 'package:satulemari/features/history/domain/repositories/history_repository.dart';
import 'package:satulemari/features/history/domain/usecases/get_my_requests_usecase.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  HistoryRepositoryImpl(
      {required this.remoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, List<RequestItem>>> getMyRequests(
      GetMyRequestsParams params) async {
    if (await networkInfo.isConnected) {
      try {
        final models = await remoteDataSource.getMyRequests(
          type: params.type,
          page: params.page,
          limit: params.limit,
        );
        final entities = models
            .map((model) => RequestItem(
                  id: model.id,
                  itemName: model.itemName,
                  status: model.status,
                  type: model.type,
                  imageUrl: model.itemImages.isNotEmpty
                      ? model.itemImages.first
                      : null,
                  createdAt: model.createdAt,
                ))
            .toList();
        return Right(entities);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(ConnectionFailure('Tidak ada koneksi internet'));
    }
  }

  @override
  Future<Either<Failure, RequestDetail>> getRequestDetail(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final model = await remoteDataSource.getRequestDetail(id);
        // Panggil .toEntity() untuk konversi yang aman
        return Right(model.toEntity());
      } on NotFoundException catch (e) {
        return Left(NotFoundFailure(e.message));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(ConnectionFailure('Tidak ada koneksi internet'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteRequest(String id, String status) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteRequest(id, status);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(ConnectionFailure('Tidak ada koneksi internet'));
    }
  }
}
