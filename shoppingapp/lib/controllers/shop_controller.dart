import 'package:get/get.dart';
import 'package:pocketbase/pocketbase.dart';
import '../services/pocketbase_service.dart';

class ShopController extends GetxController {
  final PocketBaseService service = PocketBaseService();

  var products = <RecordModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    fetchProducts();
    super.onInit();
  }

  Future<void> fetchProducts() async {
    isLoading.value = true;
    products.value = await service.getProducts();
    isLoading.value = false;
  }

  Future<void> addProduct(
    String name,
    double price,
    String desc,
    String pictureUrl,
  ) async {
    await service.addProduct(name, price, desc, pictureUrl);
    fetchProducts();
  }

  Future<void> updateProduct(
    String id,
    String name,
    double price,
    String desc,
    String pictureUrl,
  ) async {
    await service.updateProduct(id, name, price, desc, pictureUrl);
    fetchProducts();
  }

  Future<void> deleteProduct(String id) async {
    await service.deleteProduct(id);
    fetchProducts();
  }
}
