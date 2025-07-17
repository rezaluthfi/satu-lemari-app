import 'package:json_annotation/json_annotation.dart';

part 'auth_request.g.dart';

// Model for authentication request
@JsonSerializable(includeIfNull: false)
class AuthRequestModel {
  final String token;
  final String type;
  final String platform;
  final String? username;

  AuthRequestModel({
    required this.token,
    required this.type,
    this.platform = 'mobile',
    this.username,
  });

  factory AuthRequestModel.fromJson(Map<String, dynamic> json) =>
      _$AuthRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthRequestModelToJson(this);
}
