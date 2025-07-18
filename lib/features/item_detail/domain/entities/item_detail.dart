import 'package:equatable/equatable.dart';

class ItemDetail extends Equatable {
  final String id;
  final String name;
  final String description;
  final String? size;
  final String? color;
  final String type;
  final int availableQuantity;
  final String condition;
  final List<String> images;
  final Partner partner;
  final CategoryInfo category;

  const ItemDetail({
    required this.id,
    required this.name,
    required this.description,
    this.size,
    this.color,
    required this.type,
    required this.availableQuantity,
    required this.condition,
    required this.images,
    required this.partner,
    required this.category,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        size,
        color,
        type,
        availableQuantity,
        condition,
        images,
        partner,
        category
      ];
}

class Partner extends Equatable {
  final String id;
  final String username;
  final String? fullName;
  final String? photo;

  const Partner({
    required this.id,
    required this.username,
    this.fullName,
    this.photo,
  });

  @override
  List<Object?> get props => [id, username, fullName, photo];
}

class CategoryInfo extends Equatable {
  final String id;
  final String name;

  const CategoryInfo({
    required this.id,
    required this.name,
  });

  @override
  List<Object?> get props => [id, name];
}
