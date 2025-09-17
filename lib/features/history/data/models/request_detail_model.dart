import 'package:json_annotation/json_annotation.dart';
import 'package:satulemari/features/history/domain/entities/request_detail.dart';

part 'request_detail_model.g.dart';

@JsonSerializable(
    fieldRename: FieldRename.snake, createToJson: false, explicitToJson: true)
class RequestDetailModel {
  final String id;
  final String type;
  final String status;
  final String? rejectionReason;
  final DateTime createdAt;
  final ItemInRequestModel item;
  final PartnerInRequestModel partner;
  final String? reason;
  final DateTime? pickupDate;
  final DateTime? returnDate;

  RequestDetailModel({
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

  factory RequestDetailModel.fromJson(Map<String, dynamic> json) {
    // Periksa apakah 'item' ada dan merupakan Map
    if (json.containsKey('item') && json['item'] is Map<String, dynamic>) {
      // Jika 'partner' ada di dalam 'item', pindahkan ke level atas agar bisa di-parse
      if (json['item'].containsKey('partner')) {
        json['partner'] = json['item']['partner'];
      }
    }
    return _$RequestDetailModelFromJson(json);
  }

  // Method untuk konversi dari Model ke Entity
  RequestDetail toEntity() {
    return RequestDetail(
      id: id,
      type: type,
      status: status,
      rejectionReason: rejectionReason,
      createdAt: createdAt,
      item: item.toEntity(),
      partner: partner.toEntity(),
      reason: reason,
      pickupDate: pickupDate,
      returnDate: returnDate,
    );
  }
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class ItemInRequestModel {
  final String id;
  final String name;
  final List<String> images;

  ItemInRequestModel(
      {required this.id, required this.name, required this.images});

  factory ItemInRequestModel.fromJson(Map<String, dynamic> json) =>
      _$ItemInRequestModelFromJson(json);

  ItemInRequest toEntity() {
    return ItemInRequest(
      id: id,
      name: name,
      imageUrl: images.isNotEmpty ? images.first : null,
    );
  }
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class PartnerInRequestModel {
  final String id;
  final String? fullName;
  final String username;
  final String? phone;
  final String? address;
  final double? latitude;
  final double? longitude;

  PartnerInRequestModel({
    required this.id,
    this.fullName,
    required this.username,
    this.phone,
    this.address,
    this.latitude,
    this.longitude,
  });

  factory PartnerInRequestModel.fromJson(Map<String, dynamic> json) =>
      _$PartnerInRequestModelFromJson(json);

  PartnerInRequest toEntity() {
    return PartnerInRequest(
      id: id,
      name: fullName ?? username,
      phone: phone,
      address: address,
      latitude: latitude,
      longitude: longitude,
    );
  }
}
