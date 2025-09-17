import 'package:equatable/equatable.dart';

// Entity sederhana untuk ditampilkan di daftar riwayat
class OrderItem extends Equatable {
  final String id;
  final String status;
  final String type; // 'thrifting', 'donation', 'rental'
  final int totalAmount;
  final DateTime createdAt;
  final String itemName;
  final String? itemImageUrl;

  const OrderItem({
    required this.id,
    required this.status,
    required this.type,
    required this.totalAmount,
    required this.createdAt,
    required this.itemName,
    this.itemImageUrl,
  });

  @override
  List<Object?> get props => [id, status];
}
