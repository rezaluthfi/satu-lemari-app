import 'package:equatable/equatable.dart';
import 'package:satulemari/features/home/domain/entities/recommendation.dart';

class Item extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final ItemType type;
  final String? size;
  final String? condition;
  final int? availableQuantity;
  final double? price;
  final String? categoryName;
  final DateTime createdAt;

  const Item({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    required this.type,
    this.size,
    this.condition,
    this.availableQuantity,
    this.price,
    this.categoryName,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        imageUrl,
        type,
        size,
        condition,
        availableQuantity,
        price,
        categoryName,
        createdAt,
      ];
}
