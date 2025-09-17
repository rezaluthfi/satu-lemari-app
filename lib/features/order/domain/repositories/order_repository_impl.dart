import 'package:dartz/dartz.dart';
import 'package:satulemari/core/errors/exceptions.dart';
import 'package:satulemari/core/errors/failures.dart';
import 'package:satulemari/core/network/network_info.dart';
import 'package:satulemari/features/order/data/datasources/order_remote_datasource.dart';
import 'package:satulemari/features/order/data/models/create_order_request_model.dart';
import 'package:satulemari/features/order/domain/entities/order_detail.dart';
import 'package:satulemari/features/order/domain/repositories/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  OrderRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, String>> createOrder(
      CreateOrderRequestModel request) async {
    if (await networkInfo.isConnected) {
      try {
        final responseModel = await remoteDataSource.createOrder(request);
        return Right(responseModel.orderId); // <-- Langsung kembalikan ID
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(ConnectionFailure('Tidak ada koneksi internet'));
    }
  }

  @override
  Future<Either<Failure, OrderDetail>> getOrderDetail(String orderId) async {
    if (await networkInfo.isConnected) {
      try {
        final responseModel = await remoteDataSource.getOrderDetail(orderId);
        return Right(responseModel.toEntity());
      } on NotFoundException catch (e) {
        return Left(NotFoundFailure(e.message));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(ConnectionFailure('Tidak ada koneksi internet'));
    }
  }
}
