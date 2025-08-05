class SimilarItemsResponseModel {
  final SimilarItemsDataModel data;

  SimilarItemsResponseModel({required this.data});

  factory SimilarItemsResponseModel.fromJson(Map<String, dynamic> json) {
    return SimilarItemsResponseModel(
      data: SimilarItemsDataModel.fromJson(json['data']),
    );
  }
}

class SimilarItemsDataModel {
  final List<SimilarItemModel> similarItems;

  SimilarItemsDataModel({required this.similarItems});

  factory SimilarItemsDataModel.fromJson(Map<String, dynamic> json) {
    var list = json['similar_items'] as List;
    List<SimilarItemModel> itemsList =
        list.map((i) => SimilarItemModel.fromJson(i)).toList();
    return SimilarItemsDataModel(similarItems: itemsList);
  }
}

class SimilarItemModel {
  final SimilarItemDataModel data;

  SimilarItemModel({required this.data});

  factory SimilarItemModel.fromJson(Map<String, dynamic> json) {
    return SimilarItemModel(
      data: SimilarItemDataModel.fromJson(json['data']),
    );
  }
}

class SimilarItemDataModel {
  final String itemId;
  final String name;
  final List<String> images;
  final String? category;

  SimilarItemDataModel({
    required this.itemId,
    required this.name,
    required this.images,
    this.category,
  });

  factory SimilarItemDataModel.fromJson(Map<String, dynamic> json) {
    return SimilarItemDataModel(
      itemId: json['item_id'],
      name: json['name'],
      images: List<String>.from(json['images']),
      category: json['category'],
    );
  }
}
