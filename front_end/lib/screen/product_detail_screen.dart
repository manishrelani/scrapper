import 'package:flutter/material.dart';
import 'package:grocery_scanner/model/product_model.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductDetailScreen extends StatelessWidget {
  final ProductModel product;
  const ProductDetailScreen({required this.product, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ImageSection(product),
            _ProductTitle(product),
            const SizedBox(
              height: 8.0,
            ),
            _ProductPrices(product),
          ],
        ),
      ),
    );
  }
}

class _ImageSection extends StatefulWidget {
  final ProductModel product;
  const _ImageSection(this.product, {Key? key}) : super(key: key);

  @override
  State<_ImageSection> createState() => _ImageSectionState();
}

class _ImageSectionState extends State<_ImageSection> {
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: AlignmentDirectional.bottomCenter,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              child: PageView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.product.websites.length,
                  onPageChanged: (value) {
                    setState(() {
                      currentPage = value;
                    });
                  },
                  itemBuilder: (context, i) {
                    return Image.network(
                      widget.product.websites[i].image,
                      fit: BoxFit.fill,
                    );
                  }),
            ),
          ],
        ),
        const SizedBox(
          height: 4,
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: indicators(widget.product.websites.length, currentPage),
        )
      ],
    );
  }

  List<Widget> indicators(imagesLength, currentIndex) {
    return List<Widget>.generate(imagesLength, (index) {
      return Container(
        margin: const EdgeInsets.all(3),
        width: currentIndex == index ? 8 : 6,
        height: currentIndex == index ? 8 : 6,
        decoration: BoxDecoration(
            color: currentIndex == index ? Colors.black : Colors.grey,
            shape: BoxShape.circle),
      );
    });
  }
}

class _ProductTitle extends StatelessWidget {
  final ProductModel product;
  const _ProductTitle(this.product, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: double.maxFinite,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.commonName,
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}

class _ProductPrices extends StatelessWidget {
  final ProductModel product;
  const _ProductPrices(this.product, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.all(0),
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return Container(
            color: Colors.white,
            width: double.maxFinite,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      "Website : ",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      getWebsiteName(product.websites[index].link),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text(
                      "Price : ",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      product.websites[index].price == null
                          ? 'Sold Out'
                          : "\$ ${product.websites[index].price}",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                    onTap: () {
                      openWebsite(product.websites[index].link);
                    },
                    child: const Text(
                      "Product link",
                      style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.blue),
                    )),
              ],
            ),
          );
        },
        separatorBuilder: (context, index) {
          return const Divider();
        },
        itemCount: product.websites.length);
  }
}

String getWebsiteName(String url) {
  // Remove "http://", "https://", and "www." from the URL
  String cleanedUrl = url.replaceAll(RegExp(r'https?://(www\.)?'), '');

  // Split the cleaned URL by '/' and take the first part as the domain
  List<String> parts = cleanedUrl.split('/');
  return parts[0];
}

Future<void> openWebsite(String url) async {
  try {
    final uri = Uri.parse(url);
    launchUrl(uri);
  } catch (_) {}
}
