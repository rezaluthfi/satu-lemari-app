import 'package:json_annotation/json_annotation.dart';

part 'create_request_response_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class CreateRequestResponseModel {
  final String id;
  CreateRequestResponseModel({required this.id});

  factory CreateRequestResponseModel.fromJson(Map<String, dynamic> json) =>
      _$CreateRequestResponseModelFromJson(json);
}
