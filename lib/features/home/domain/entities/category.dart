import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final String id;
  final String name;
  final String? icon;

  const Category({required this.id, required this.name, this.icon});

  @override
  List<Object?> get props => [id, name, icon];
}
