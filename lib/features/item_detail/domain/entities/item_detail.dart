import 'package:equatable/equatable.dart';
import 'package:satulemari/features/history/domain/entities/request_detail.dart';

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
  final double? price;

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
    this.price,
  });

  factory ItemDetail.fromRequestDetail(RequestDetail requestDetail) {
    return ItemDetail(
      id: requestDetail.item.id,
      name: requestDetail.item.name,
      images: requestDetail.item.imageUrl != null
          ? [requestDetail.item.imageUrl!]
          : [],
      type: requestDetail.type,
      // Mengisi properti 'required' lainnya dengan nilai default atau dummy
      description: '',
      availableQuantity: 1, // Asumsikan kuantitas 1 saat membuat order
      condition: '',
      partner: Partner(
        // Buat objek Partner dari PartnerInRequest
        id: requestDetail.partner.id,
        username: requestDetail.partner.name,
        fullName: requestDetail.partner.name,
        address: requestDetail.partner.address,
        phone: requestDetail.partner.phone,
      ),
      category: const CategoryInfo(id: '', name: ''), // Kategori dummy
      // Properti opsional bisa null
      size: null,
      color: null,
      price:
          null, // Harga mungkin tidak relevan saat membuat order dari request
    );
  }

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
        category,
        price,
      ];
}

class Partner extends Equatable {
  final String id;
  final String username;
  final String? fullName;
  final String? photo;
  final String? phone;
  final String? address;
  final double? latitude;
  final double? longitude;

  const Partner({
    required this.id,
    required this.username,
    this.fullName,
    this.photo,
    this.phone,
    this.address,
    this.latitude,
    this.longitude,
  });

  @override
  List<Object?> get props =>
      [id, username, fullName, photo, phone, address, latitude, longitude];
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
