import 'dart:async';
import 'package:pocketbase/pocketbase.dart';
import '../models/models.dart';
import '../main.dart';

class PocketBaseService {
  final PocketBase _db = pb;

  // --- การแก้ไข: สร้างฟังก์ชันกลางสำหรับสร้าง Stream ---
  // ฟังก์ชันนี้จะใช้แพทเทิร์นเดียวกันสำหรับทุก Stream เพื่อความแน่นอน
  Stream<List<T>> _createCollectionStream<T>({
    required String collectionName,
    required T Function(RecordModel) fromRecord,
    String? filter,
  }) {
    final controller = StreamController<List<T>>.broadcast();

    // ฟังก์ชันสำหรับดึงข้อมูลล่าสุด
    void fetchData() async {
      print('[STREAM] Fetching data for "$collectionName"...');
      try {
        final records = await _db
            .collection(collectionName)
            .getFullList(sort: '-created', filter: filter);
        if (!controller.isClosed) {
          controller.add(records.map(fromRecord).toList());
          print(
            '[STREAM] Success! Fetched ${records.length} items for "$collectionName".',
          );
        }
      } catch (e) {
        print('❌ [STREAM] ERROR fetching "$collectionName": $e');
        if (!controller.isClosed) {
          controller.addError(e);
        }
      }
    }

    // เริ่มดึงข้อมูลครั้งแรก
    fetchData();

    // Subscribe เพื่อรับการเปลี่ยนแปลง
    _db.collection(collectionName).subscribe('*', (e) {
      print(
        '⚡️ [REALTIME] Event received for "$collectionName"! Action: ${e.action}. Record ID: ${e.record?.id}',
      );
      // เมื่อมี event เข้ามา ให้ดึงข้อมูลใหม่ทั้งหมดเพื่อให้แน่ใจว่า UI ถูกต้องเสมอ
      fetchData();
    });

    // เมื่อไม่มีใครฟัง Stream นี้แล้ว ให้ยกเลิกการ Subscribe
    controller.onCancel = () {
      print('[STREAM] Unsubscribing from "$collectionName"');
      _db.collection(collectionName).unsubscribe();
      controller.close();
    };

    return controller.stream;
  }

  // --- Menu ---
  // ส่วนของ Menu ไม่น่ามีปัญหา แต่เราจะใช้ฟังก์ชันกลางเพื่อความสอดคล้องกัน
  Stream<List<MenuItem>> getMenuStream() {
    return _createCollectionStream<MenuItem>(
      collectionName: 'menu',
      fromRecord: MenuItem.fromRecord,
    );
  }

  // --- Orders ---
  // ใช้ฟังก์ชันกลางในการสร้าง Stream ของ Orders
  Stream<List<Order>> getOrdersStream() {
    return _createCollectionStream<Order>(
      collectionName: 'orders',
      fromRecord: Order.fromRecord,
    );
  }

  // --- Cart / Customer ---
  // ใช้ฟังก์ชันกลางในการสร้าง Stream ของ Cart
  Stream<List<OrderItem>> getCartStream(String tableNumber) {
    return _createCollectionStream<OrderItem>(
      collectionName: 'cart_items',
      fromRecord: OrderItem.fromRecord,
      filter: 'tableNumber = "$tableNumber"',
    );
  }

  // ======================================================
  //  ส่วนของฟังก์ชัน Actions (Create, Update, Delete)
  //  โค้ดส่วนนี้ไม่มีการเปลี่ยนแปลง
  // ======================================================

  Future<void> saveMenuItem(MenuItem item) async {
    try {
      if (item.id != null && item.id!.isNotEmpty) {
        await _db.collection('menu').update(item.id!, body: item.toMap());
      } else {
        await _db.collection('menu').create(body: item.toMap());
      }
    } on ClientException catch (e) {
      throw Exception('บันทึกเมนูล้มเหลว: $e');
    }
  }

  Future<void> removeMenuItem(String id) async {
    try {
      await _db.collection('menu').delete(id);
    } on ClientException catch (e) {
      throw Exception('ลบเมนูล้มเหลว: $e');
    }
  }

  Future<void> completeOrder(String orderId) async {
    try {
      await _db
          .collection('orders')
          .update(orderId, body: {'isCompleted': true});
    } on ClientException catch (e) {
      throw Exception('อัปเดตสถานะคำสั่งซื้อไม่สำเร็จ: $e');
    }
  }

  Future<void> addToCart(String tableNumber, OrderItem item) async {
    try {
      final body = item.toCartMap();
      body['tableNumber'] = tableNumber;
      await _db.collection('cart_items').create(body: body);
    } catch (e) {
      throw Exception('เพิ่มสินค้าในตะกร้าล้มเหลว: $e');
    }
  }

  Future<void> removeFromCart(String itemId) async {
    try {
      await _db.collection('cart_items').delete(itemId);
    } catch (e) {
      throw Exception('ลบสินค้าในตะกร้าล้มเหลว: $e');
    }
  }

  Future<void> placeOrder(String tableNumber, List<OrderItem> items) async {
    final total = items.fold<double>(0.0, (sum, item) => sum + item.price);
    final order = Order(
      tableNumber: tableNumber,
      orderTimestamp: DateTime.now(),
      totalAmount: total,
      items: items.map((e) => e.toMap()).toList(),
    );
    try {
      await _db.collection('orders').create(body: order.toMap());
      final cartItems = await _db
          .collection('cart_items')
          .getFullList(filter: 'tableNumber = "$tableNumber"');
      await Future.wait(
        cartItems.map((item) => _db.collection('cart_items').delete(item.id)),
      );
    } catch (e) {
      throw Exception('สั่งซื้อสินค้าไม่สำเร็จ: $e');
    }
  }
}
