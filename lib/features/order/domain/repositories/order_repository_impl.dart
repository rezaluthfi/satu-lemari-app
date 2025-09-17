import 'package:dartz/dartz.dart';
import 'package:satulemari/core/errors/exceptions.dart';
import 'package:satulemari/core/errors/failures.dart';
import 'package:satulemari/core/network/network_info.dart';
import 'package:satulemari/features/item_detail/data/datasources/item_detail_remote_datasource.dart';
import 'package:satulemari/features/order/data/datasources/order_remote_datasource.dart';
import 'package:satulemari/features/order/data/models/create_order_request_model.dart';
import 'package:satulemari/features/order/domain/entities/order_detail.dart';
import 'package:satulemari/features/order/domain/entities/order_item.dart';
import 'package:satulemari/features/order/domain/repositories/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;
  final ItemDetailRemoteDataSource
      itemDetailRemoteDataSource; // <-- DEPENDENCY BARU
  final NetworkInfo networkInfo;

  OrderRepositoryImpl({
    required this.remoteDataSource,
    required this.itemDetailRemoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, String>> createOrder(
      CreateOrderRequestModel request) async {
    if (await networkInfo.isConnected) {
      try {
        final responseModel = await remoteDataSource.createOrder(request);
        return Right(responseModel.orderId);
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

  @override
  Future<Either<Failure, List<OrderItem>>> getMyOrders() async {
    if (await networkInfo.isConnected) {
      try {
        // 1. Fetch daftar order dasar
        final orderModels = await remoteDataSource.getMyOrders();
        if (orderModels.isEmpty) {
          return const Right([]);
        }

        // 2. Kumpulkan semua item_id yang unik
        final itemIds =
            orderModels.map((order) => order.itemId).toSet().toList();

        // 3. Fetch detail item untuk semua ID tersebut dalam satu panggilan
        final itemDetailModels =
            await itemDetailRemoteDataSource.getItemsByIds(itemIds);

        // Buat map untuk pencarian cepat: 'itemId' -> Item
        final itemDetailsMap = {
          for (var item in itemDetailModels) item.id: item
        };

        // 4. Gabungkan data
        final List<OrderItem> hydratedOrders = [];
        for (final orderModel in orderModels) {
          final matchingItem = itemDetailsMap[orderModel.itemId];
          hydratedOrders.add(OrderItem(
            id: orderModel.id,
            status: orderModel.status,
            type: orderModel.type,
            totalAmount: orderModel.totalAmount,
            createdAt: orderModel.createdAt,
            itemName: matchingItem?.name ?? 'Nama Barang Tidak Ditemukan',
            itemImageUrl: (matchingItem?.images.isNotEmpty ?? false)
                ? matchingItem!.images.first
                : null,
          ));
        }

        // Urutkan berdasarkan tanggal terbaru
        hydratedOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        return Right(hydratedOrders);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(ConnectionFailure('Tidak ada koneksi internet'));
    }
  }

  @override
  Future<Either<Failure, void>> cancelOrder(String orderId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.cancelOrder(orderId);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(ConnectionFailure('Tidak ada koneksi internet'));
    }
  }
}
