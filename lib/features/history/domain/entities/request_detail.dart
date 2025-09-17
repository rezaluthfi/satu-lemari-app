import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

class RequestDetail extends Equatable {
  final String id;
  final String type;
  final String status;
  final String? rejectionReason;
  final DateTime createdAt;
  final ItemInRequest item;
  final PartnerInRequest partner;

  final String? reason;
  final DateTime? pickupDate;
  final DateTime? returnDate;

  const RequestDetail({
    required this.id,
    required this.type,
    required this.status,
    this.rejectionReason,
    required this.createdAt,
    required this.item,
    required this.partner,
    this.reason,
    this.pickupDate,
    this.returnDate,
  });

  @override
  List<Object?> get props => [
        id,
        type,
        status,
        rejectionReason,
        createdAt,
        item,
        partner,
        reason,
        pickupDate,
        returnDate
      ];
}

@JsonSerializable(createFactory: false, createToJson: false)
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
  final String name;
  final String? phone;
  final String? address;
  final double? latitude;
  final double? longitude;

  const PartnerInRequest({
    required this.id,
    required this.name,
    this.phone,
    this.address,
    this.latitude,
    this.longitude,
  });

  @override
  List<Object?> get props => [id, name, phone, address, latitude, longitude];
}
