import 'package:equatable/equatable.dart';

class RequestItem extends Equatable {
  final String id;
  final String itemName;
  final String status;
  final String type;
  final String? imageUrl;
  final DateTime createdAt;

  const RequestItem({
    required this.id,
    required this.itemName,
    required this.status,
    required this.type,
    this.imageUrl,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, itemName, status, type, imageUrl, createdAt];
}
