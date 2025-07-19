import 'package:dartz/dartz.dart';
import 'package:satulemari/core/errors/exceptions.dart';
import 'package:satulemari/core/errors/failures.dart';
import 'package:satulemari/core/network/network_info.dart';
import 'package:satulemari/features/history/data/datasources/history_remote_datasource.dart';
import 'package:satulemari/features/history/domain/entities/request_detail.dart';
import 'package:satulemari/features/history/domain/entities/request_item.dart';
import 'package:satulemari/features/history/domain/repositories/history_repository.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  HistoryRepositoryImpl(
      {required this.remoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, List<RequestItem>>> getMyRequests(String type) async {
    if (await networkInfo.isConnected) {
      try {
        final models = await remoteDataSource.getMyRequests(type: type);
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
      return Left(ConnectionFailure('No Internet Connection'));
    }
  }

  @override
  Future<Either<Failure, RequestDetail>> getRequestDetail(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final model = await remoteDataSource.getRequestDetail(id);
        final entity = RequestDetail(
          id: model.id,
          type: model.type,
          status: model.status,
          rejectionReason: model.rejectionReason,
          createdAt: model.createdAt,
          item: ItemInRequest(
            id: model.item.id,
            name: model.item.name,
            imageUrl:
                model.item.images.isNotEmpty ? model.item.images.first : null,
          ),
          partner: PartnerInRequest(
            id: model.partner.id,
            name: model.partner.fullName ?? model.partner.username,
            phone: model.partner.phone,
            address: model.partner.address,
          ),
        );
        return Right(entity);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(ConnectionFailure('No Internet Connection'));
    }
  }
}
