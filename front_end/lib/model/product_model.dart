import 'dart:convert';

List<ProductModel> productModelFromMap(String str) => List<ProductModel>.from(
    json.decode(str).map((x) => ProductModel.fromMap(x)));

String productModelToMap(List<ProductModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class ProductModel {
  final List<WebsiteModel> websites;
  final String commonName;

  const ProductModel({
    required this.websites,
    required this.commonName,
  });

  factory ProductModel.fromMap(Map<String, dynamic> json) {
    final list = List<WebsiteModel>.from(
        json["websites"].map((x) => WebsiteModel.fromMap(x)));
    list.sort((a, b) => a.price?.compareTo(b.price ?? 0) ?? 0);
    return ProductModel(
      websites: list,
      commonName: (json["commonName"] as String)
          .replaceAll(RegExp(r"\|"), " ")
          .replaceAll(RegExp(r"\s+"), " "),
    );
  }

  Map<String, dynamic> toMap() => {
        "websites": List<dynamic>.from(websites.map((x) => x.toMap())),
        "commonName": commonName,
      };

  static List<ProductModel> fromList(List list) {
    final List<ProductModel> productList = [];

    for (var i in list) {
      productList.add(ProductModel.fromMap(i));
    }
    return productList;
  }
}

class WebsiteModel {
  final String name;
  final double? price;
  final String link;
  final String image;

  const WebsiteModel({
    required this.name,
    required this.price,
    required this.link,
    required this.image,
  });

  factory WebsiteModel.fromMap(Map<String, dynamic> json) {
    String? value = (json["price"] as String?)?.replaceAll("\$", "");
    if (value != null) {
      final match = _regex.firstMatch(value);
      if (match != null) {
        value = value.substring(0, match.start);
      }
    }

    return WebsiteModel(
      name: json["name"],
      price: value == null ? null : double.parse(value),
      link: json["link"],
      image: json["image"],
    );
  }

  Map<String, dynamic> toMap() => {
        "name": name,
        "price": price,
        "link": link,
        "image": image,
      };
}

RegExp _regex = RegExp(r'[a-zA-Z]');
