import 'package:equatable/equatable.dart';

enum ItemType { donation, rental, thrifting, unknown }

class Recommendation extends Equatable {
  final String itemId;
  final String title;
  final String description;
  final String? imageUrl;
  final String category;
  final ItemType type;
  final List<String> tags;
  final String? size;
  final String? condition;
  final double? price;

  const Recommendation({
    required this.itemId,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.category,
    required this.type,
    required this.tags,
    this.size,
    this.condition,
    this.price,
  });

  @override
  List<Object?> get props => [
        itemId,
        title,
        description,
        imageUrl,
        category,
        type,
        tags,
        size,
        condition,
        price,
      ];
}
