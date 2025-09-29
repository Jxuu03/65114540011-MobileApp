import 'package:pocketbase/pocketbase.dart';

class PocketBaseService {
  final pb = PocketBase('http://127.0.0.1:8090'); // your pocketbase URL

  Future<List<RecordModel>> getProducts() async {
    final result = await pb.collection('products').getFullList();
    return result;
  }

  Future<RecordModel> addProduct(
    String name,
    double price,
    String desc,
    String pictureUrl,
  ) async {
    return await pb
        .collection('products')
        .create(
          body: {
            'name': name,
            'price': price,
            'description': desc,
            'picture': pictureUrl,
          },
        );
  }

  Future<RecordModel> updateProduct(
    String id,
    String name,
    double price,
    String desc,
    String pictureUrl,
  ) async {
    return await pb
        .collection('products')
        .update(
          id,
          body: {
            'name': name,
            'price': price,
            'description': desc,
            'picture': pictureUrl,
          },
        );
  }

  Future<void> deleteProduct(String id) async {
    await pb.collection('products').delete(id);
  }
}
