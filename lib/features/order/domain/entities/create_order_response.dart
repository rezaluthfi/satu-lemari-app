import 'package:equatable/equatable.dart';

class CreateOrderResponseEntity extends Equatable {
  final String orderId;
  final DateTime expiresAt;
  final int itemPrice;
  final int shippingFee;
  final String status;
  final int totalAmount;
  final String? qrisPayload;

  const CreateOrderResponseEntity({
    required this.orderId,
    required this.expiresAt,
    required this.itemPrice,
    required this.shippingFee,
    required this.status,
    required this.totalAmount,
    this.qrisPayload,
  });

  @override
  List<Object?> get props =>
      [orderId, expiresAt, totalAmount, qrisPayload, status];
}
