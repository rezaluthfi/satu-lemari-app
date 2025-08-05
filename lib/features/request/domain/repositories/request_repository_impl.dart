import 'package:dartz/dartz.dart';
import 'package:satulemari/core/errors/exceptions.dart';
import 'package:satulemari/core/errors/failures.dart';
import 'package:satulemari/core/network/network_info.dart';
import 'package:satulemari/features/history/domain/entities/request_detail.dart';
import 'package:satulemari/features/request/data/datasources/request_remote_datasource.dart';
import 'package:satulemari/features/request/data/models/create_request_model.dart';
import 'package:satulemari/features/request/domain/repositories/request_repository.dart';

class RequestRepositoryImpl implements RequestRepository {
  final RequestRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  RequestRepositoryImpl(
      {required this.remoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, RequestDetail>> createRequest(
      CreateRequestModel request) async {
    if (await networkInfo.isConnected) {
      try {
        final model = await remoteDataSource.createRequest(request);
        // Mapping dari model ke entity, copy dari HistoryRepositoryImpl
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
