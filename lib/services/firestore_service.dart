import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import '../models/models.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Menu ---
  Future<void> saveMenuItem(MenuItem item) async {
    try {
      final docRef = _db.collection('menu').doc(item.id);
      await docRef.set(item.toMap());
    } catch (e) {
      throw Exception('บันทึกเมนูล้มเหลว: $e');
    }
  }

  Future<void> removeMenuItem(String id) async {
    try {
      await _db.collection('menu').doc(id).delete();
    } catch (e) {
      throw Exception('ลบเมนูล้มเหลว: $e');
    }
  }

  Stream<List<MenuItem>> getMenuStream() {
    return _db.collection('menu').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => MenuItem.fromFirestore(doc)).toList();
    });
  }

  // --- Orders ---
  Stream<List<Order>> getOrdersStream() {
    return FirebaseFirestore.instance
        .collection('orders')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            final itemsData = data['items'] as List<dynamic>? ?? [];

            // คำนวณ totalAmount จาก items
            double totalAmount = itemsData.fold(0.0, (sum, item) {
              final menuItemData =
                  item['menuItem'] as Map<String, dynamic>? ?? {};
              final price =
                  (menuItemData['basePrice'] as num?)?.toDouble() ?? 0.0;
              final quantity = (item['quantity'] as num?)?.toInt() ?? 1;
              return sum + price * quantity;
            });

            return Order(
              id: doc.id,
              tableNumber: data['tableNumber'] ?? '',
              orderTimestamp:
                  (data['orderTimestamp'] as Timestamp?)?.toDate() ??
                  DateTime.now(),
              totalAmount: totalAmount,
              items: itemsData
                  .map((item) => Map<String, dynamic>.from(item))
                  .toList(),
              isCompleted: data['isCompleted'] ?? false,
            );
          }).toList(),
        );
  }

  Future<void> completeOrder(String orderId) async {
    try {
      await _db.collection('orders').doc(orderId).update({'isCompleted': true});
    } catch (e) {
      throw Exception('อัปเดตสถานะคำสั่งซื้อไม่สำเร็จ: $e');
    }
  }

  // --- Cart / Customer ---
  Stream<List<OrderItem>> getCartStream(String tableNumber) {
    return _db
        .collection('carts')
        .doc(tableNumber)
        .collection('items')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => OrderItem.fromFirestore(doc)).toList(),
        );
  }

  Future<void> addToCart(String tableNumber, OrderItem item) async {
    try {
      final docRef = _db
          .collection('carts')
          .doc(tableNumber)
          .collection('items')
          .doc();
      await docRef.set(item.toCartMap());
    } catch (e) {
      throw Exception('เพิ่มสินค้าในตะกร้าล้มเหลว: $e');
    }
  }

  Future<void> removeFromCart(String tableNumber, String itemId) async {
    try {
      await _db
          .collection('carts')
          .doc(tableNumber)
          .collection('items')
          .doc(itemId)
          .delete();
    } catch (e) {
      throw Exception('ลบสินค้าในตะกร้าล้มเหลว: $e');
    }
  }

  Future<void> placeOrder(String tableNumber, List<OrderItem> items) async {
    final total = items.fold<double>(
      0.0,
      (sum, item) => sum + item.price,
    ); // รวมราคาสินค้า
    final order = Order(
      tableNumber: tableNumber,
      orderTimestamp: DateTime.now(),
      totalAmount: total,
      items: items.map((e) => e.toMap()).toList(),
    );
    try {
      await _db.collection('orders').doc(order.id).set(order.toMap());
      // ลบตะกร้า
      final batch = _db.batch();
      final cartCollection = _db
          .collection('carts')
          .doc(tableNumber)
          .collection('items');
      final cartDocs = await cartCollection.get();
      for (var doc in cartDocs.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('สั่งซื้อสินค้าไม่สำเร็จ: $e');
    }
  }
}
