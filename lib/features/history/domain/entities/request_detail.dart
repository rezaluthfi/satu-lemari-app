import 'package:equatable/equatable.dart';

class RequestDetail extends Equatable {
  final String id;
  final String type;
  final String status;
  final String rejectionReason;
  final DateTime createdAt;
  final ItemInRequest item;
  final PartnerInRequest partner;

  const RequestDetail({
    required this.id,
    required this.type,
    required this.status,
    required this.rejectionReason,
    required this.createdAt,
    required this.item,
    required this.partner,
  });

  @override
  List<Object?> get props =>
      [id, type, status, rejectionReason, createdAt, item, partner];
}

class ItemInRequest extends Equatable {
  final String id;
  final String name;
  final String? imageUrl;

  const ItemInRequest({required this.id, required this.name, this.imageUrl});

  @override
  List<Object?> get props => [id, name, imageUrl];
}

class PartnerInRequest extends Equatable {
  final String id;
  final String name; // Kombinasi fullName atau username
  final String? phone;
  final String? address;

  const PartnerInRequest({
    required this.id,
    required this.name,
    this.phone,
    this.address,
  });

  @override
  List<Object?> get props => [id, name, phone, address];
}
