import 'package:json_annotation/json_annotation.dart';

part 'create_request_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class CreateRequestModel {
  final String itemId;
  final int quantity;
  final String? reason;
  final String? pickupDate;
  final String? returnDate;

  CreateRequestModel({
    required this.itemId,
    required this.quantity,
    this.reason,
    this.pickupDate,
    this.returnDate,
  });

  factory CreateRequestModel.fromJson(Map<String, dynamic> json) =>
      _$CreateRequestModelFromJson(json);
  Map<String, dynamic> toJson() => _$CreateRequestModelToJson(this);
}
