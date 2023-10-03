import 'package:dio/dio.dart';

import '../model/product_model.dart';

class ProductRepository {
  static const String baseUrl = "https://eb07-45-248-78-28.ngrok-free.app/";
  final Dio _dio;

  const ProductRepository(this._dio);

  Future<List<ProductModel>> getProduct(String value) async {
    const path = "search_product";
    final param = {"product_name": value};
    final res = await _dio.get(path, queryParameters: param);
    return ProductModel.fromList(res.data);
  }
}

// List<ProductModel> _getFakeData() {
//   return [
//     const ProductModel(
//         discription: "This is Product discription",
//         name: "Apple",
//         thumb:
//             "https://media.istockphoto.com/id/184276818/photo/red-apple.jpg?s=612x612&w=0&k=20&c=NvO-bLsG0DJ_7Ii8SSVoKLurzjmV0Qi4eGfn6nW3l5w=",
//         websitePrice: [
//           WebsitePrice(price: "\$5", website: "www.store1.com"),
//           WebsitePrice(price: "\$7", website: "www.store2.com")
//         ],
//         images: [
//           "https://media.istockphoto.com/id/184276818/photo/red-apple.jpg?s=612x612&w=0&k=20&c=NvO-bLsG0DJ_7Ii8SSVoKLurzjmV0Qi4eGfn6nW3l5w=",
//           "https://media.istockphoto.com/id/184276818/photo/red-apple.jpg?s=612x612&w=0&k=20&c=NvO-bLsG0DJ_7Ii8SSVoKLurzjmV0Qi4eGfn6nW3l5w="
//         ]),
//     const ProductModel(
//         discription: "This is Product discription",
//         name: "Apple Gala",
//         thumb:
//             "https://thumbs.dreamstime.com/b/red-apple-isolated-clipping-path-19130134.jpg",
//         websitePrice: [
//           WebsitePrice(price: "\$10", website: "www.store2.com"),
//           WebsitePrice(price: "\$13", website: "www.store1.com")
//         ],
//         images: [
//           "https://thumbs.dreamstime.com/b/red-apple-isolated-clipping-path-19130134.jpg",
//           "https://thumbs.dreamstime.com/b/red-apple-isolated-clipping-path-19130134.jpg",
//         ]),
//   ];
// }
