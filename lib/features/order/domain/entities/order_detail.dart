// Entity utama yang akan digunakan di UI
import 'package:equatable/equatable.dart';

class OrderDetail extends Equatable {
  final String id;
  final String status;
  final String shippingMethod;
  final int itemPrice;
  final int shippingFee;
  final int totalAmount;
  final String? notes;
  final DateTime createdAt;
  final DateTime expiresAt;
  final PaymentDetail payment;

  const OrderDetail({
    required this.id,
    required this.status,
    required this.shippingMethod,
    required this.itemPrice,
    required this.shippingFee,
    required this.totalAmount,
    this.notes,
    required this.createdAt,
    required this.expiresAt,
    required this.payment,
  });

  @override
  List<Object?> get props => [id, status];
}

class PaymentDetail extends Equatable {
  final String id;
  final String status;
  final String method;
  final String? qrisPayload;
  final DateTime? paidAt;

  const PaymentDetail({
    required this.id,
    required this.status,
    required this.method,
    this.qrisPayload,
    this.paidAt,
  });

  @override
  List<Object?> get props => [id, status];
}
