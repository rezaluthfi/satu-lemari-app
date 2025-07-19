import 'package:json_annotation/json_annotation.dart';

part 'request_detail_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class RequestDetailModel {
  final String id;
  final String type;
  final String status;
  final String rejectionReason;
  final DateTime createdAt;
  final ItemInRequestModel item;
  final PartnerInRequestModel partner;

  RequestDetailModel({
    required this.id,
    required this.type,
    required this.status,
    required this.rejectionReason,
    required this.createdAt,
    required this.item,
    required this.partner,
  });

  factory RequestDetailModel.fromJson(Map<String, dynamic> json) =>
      _$RequestDetailModelFromJson(json);
  Map<String, dynamic> toJson() => _$RequestDetailModelToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ItemInRequestModel {
  final String id;
  final String name;
  final List<String> images;

  ItemInRequestModel(
      {required this.id, required this.name, required this.images});

  factory ItemInRequestModel.fromJson(Map<String, dynamic> json) =>
      _$ItemInRequestModelFromJson(json);
  Map<String, dynamic> toJson() => _$ItemInRequestModelToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class PartnerInRequestModel {
  final String id;
  final String? fullName;
  final String username;
  final String? phone;
  final String? address;

  PartnerInRequestModel({
    required this.id,
    this.fullName,
    required this.username,
    this.phone,
    this.address,
  });

  factory PartnerInRequestModel.fromJson(Map<String, dynamic> json) =>
      _$PartnerInRequestModelFromJson(json);
  Map<String, dynamic> toJson() => _$PartnerInRequestModelToJson(this);
}
