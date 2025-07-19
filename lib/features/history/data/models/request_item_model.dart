import 'package:json_annotation/json_annotation.dart';

part 'request_item_model.g.dart';

// Asumsi struktur data dari /requests/my adalah seperti ini,
// jika berbeda, sesuaikan field-nya.
@JsonSerializable(fieldRename: FieldRename.snake)
class RequestItemModel {
  final String id;
  final String itemName;
  final String status;
  final String type;
  @JsonKey(defaultValue: [])
  final List<String> itemImages;
  final DateTime createdAt;

  RequestItemModel({
    required this.id,
    required this.itemName,
    required this.status,
    required this.type,
    required this.itemImages,
    required this.createdAt,
  });

  factory RequestItemModel.fromJson(Map<String, dynamic> json) =>
      _$RequestItemModelFromJson(json);
  Map<String, dynamic> toJson() => _$RequestItemModelToJson(this);
}
