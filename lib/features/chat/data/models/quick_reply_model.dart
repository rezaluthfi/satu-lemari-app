// lib/features/chat/data/models/quick_reply_model.dart
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/quick_reply.dart';

part 'quick_reply_model.g.dart';

@JsonSerializable()
class QuickReplyModel extends QuickReply {
  const QuickReplyModel({
    required String text,
    required String payload,
    String? icon,
  }) : super(text: text, payload: payload, icon: icon);

  factory QuickReplyModel.fromJson(Map<String, dynamic> json) =>
      _$QuickReplyModelFromJson(json);

  Map<String, dynamic> toJson() => _$QuickReplyModelToJson(this);
}
