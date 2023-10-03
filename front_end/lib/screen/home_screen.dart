import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:grocery_scanner/screen/product_detail_screen.dart';

import '../model/product_model.dart';
import '../repository/product_repo.dart';
import '../widget/product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ProductModel> productList = [];

  bool isLoading = false;

  final _repo =
      ProductRepository(Dio(BaseOptions(baseUrl: ProductRepository.baseUrl)));

  final conttroller = TextEditingController();

  Future<void> getProduct() async {
    if (conttroller.text.isEmpty) {
      return;
    }
    try {
      setState(() {
        isLoading = true;
      });
      final list = await _repo.getProduct(conttroller.text);

      productList = list;
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      productList = [];
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator.adaptive(),
                  SizedBox(
                    height: 4,
                  ),
                  Text(
                    "Hold on, Fetching the data..",
                    style: TextStyle(fontSize: 16),
                  )
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  SearchField(
                    getProduct,
                    conttroller,
                  ),
                  productList.isEmpty && conttroller.text.isEmpty
                      ? const Expanded(
                          child: Center(
                            child: Text(
                              "Start Searching, to compare price between Products",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        )
                      : productList.isEmpty
                          ? const Expanded(
                              child: Center(
                                child: Text(
                                  "No Product Found",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            )
                          : CustomeGridView(
                              productList: productList,
                            )
                ],
              ),
            ),
    );
  }

  AppBar _appBar() {
    return AppBar(
      centerTitle: true,
      title: Text(
        "Product List",
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
    );
  }
}

class SearchField extends StatelessWidget {
  final VoidCallback onSearch;
  final TextEditingController controller;
  const SearchField(this.onSearch, this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Flexible(
            child: Card(
              elevation: 5,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: controller,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(
                  fontSize: 18,
                ),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(16),
                  border: InputBorder.none,
                  hintText: "Search",
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 4.0,
          ),
          MaterialButton(
            elevation: 5,
            color: Theme.of(context).primaryColor,
            minWidth: 56,
            height: 56,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            onPressed: onSearch,
            child: const Icon(
              Icons.search,
              color: Colors.white,
              size: 26,
            ),
          ),
        ],
      ),
    );
  }
}

class CustomeGridView extends StatelessWidget {
  final List<ProductModel> productList;

  const CustomeGridView({Key? key, required this.productList})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 5 / 7,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        physics: const BouncingScrollPhysics(),
        itemCount: productList.length,
        itemBuilder: (BuildContext context, int index) {
          return ProductCard(
            product: productList[index],
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (ctx) =>
                    ProductDetailScreen(product: productList[index]),
              ),
            ),
          );
        },
      ),
    );
  }
}

bool isImage(String value) {
  final result = Uri.parse(value).isAbsolute;

  return result;
}

extension CustomList<T> on List<T> {
  T? get getFirst => isNotEmpty ? first : null;
  T? get getSecond => length >= 2 ? this[1] : null;
}
