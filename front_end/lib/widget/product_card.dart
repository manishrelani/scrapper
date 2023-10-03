import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:grocery_scanner/screen/home_screen.dart';

import '../model/product_model.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final Function()? onTap;
  const ProductCard({Key? key, required this.product, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTap: onTap,
          child: Card(
            clipBehavior: Clip.hardEdge,
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [_imageView(constraints), _allDetails(constraints)],
            ),
          ),
        );
      },
    );
  }

  Widget _imageView(BoxConstraints constraints) {
    return SizedBox(
      height: constraints.maxHeight * 0.6,
      child: CachedNetworkImage(
        width: double.maxFinite,
        fit: BoxFit.cover,
        imageUrl: isImage(product.websites.first.image)
            ? product.websites.first.image
            : (product.websites.getSecond?.image ?? ""),
        errorWidget: (context, url, error) {
          return const Center(
            child: Text("Error"),
          );
        },
      ),
    );
  }

  Widget _allDetails(BoxConstraints constraints) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [_productTitle(), _priceTag(constraints)],
        ),
      ),
    );
  }

  Widget _productTitle() {
    return Text(
      product.commonName,
      maxLines: 2,
      softWrap: true,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 17,
      ),
    );
  }

  Widget _priceTag(BoxConstraints constraints) {
    return Row(
      children: [
        Expanded(
          child: Text(
            "\$ ${product.websites.first.price ?? 'N/A'}",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
        ),
      ],
    );
  }
}
