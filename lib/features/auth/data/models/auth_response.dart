import 'package:json_annotation/json_annotation.dart';
import 'package:satulemari/features/auth/data/models/user_model.dart';

part 'auth_response.g.dart';

// Model for authentication response
@JsonSerializable()
class AuthResponseModel {
  final bool success;
  final AuthDataModel? data;
  final String? message;

  AuthResponseModel({
    required this.success,
    this.data,
    this.message,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseModelToJson(this);
}

// Model for authentication data
@JsonSerializable(fieldRename: FieldRename.snake)
class AuthDataModel {
  final UserModel user;
  final String? accessToken;
  final String? tokenType;
  final int? expiresIn;

  AuthDataModel({
    required this.user,
    this.accessToken,
    this.tokenType,
    this.expiresIn,
  });

  factory AuthDataModel.fromJson(Map<String, dynamic> json) =>
      _$AuthDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthDataModelToJson(this);
}
