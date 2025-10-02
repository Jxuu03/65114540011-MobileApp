import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

class ToppingOption {
  final String name;
  final double price;
  final String category;

  ToppingOption({
    required this.name,
    required this.price,
    required this.category,
  });

  factory ToppingOption.fromMap(Map<String, dynamic> map) {
    return ToppingOption(
      name: map['name'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      category: map['category'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'price': price, 'category': category};
  }
}

// --- 2. Menu Item Model ---
class MenuItem {
  final String id;
  final String name;
  final double basePrice;
  final String type; // 'Food' หรือ 'Drink'
  final List<ToppingOption> customizationOptions;

  MenuItem({
    String? id,
    required this.name,
    required this.basePrice,
    required this.type,
    this.customizationOptions = const [],
  }) : id = id ?? uuid.v4();

  factory MenuItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MenuItem(
      id: doc.id,
      name: data['name'] ?? '',
      basePrice: (data['basePrice'] ?? 0.0).toDouble(),
      type: data['type'] ?? 'Food',
      customizationOptions:
          (data['customizationOptions'] as List<dynamic>?)
              ?.map((e) => ToppingOption.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'basePrice': basePrice,
      'type': type,
      'customizationOptions': customizationOptions
          .map((e) => e.toMap())
          .toList(),
    };
  }
}

// --- 3. Order Item Model ---
class OrderItem {
  final String? id;
  final String name;
  final double price;
  final String summary;
  final Map<String, String> selections;
  final List<String> toppings;
  final DateTime addedAt;

  OrderItem({
    this.id,
    required this.name,
    required this.price,
    this.summary = 'ไม่ระบุตัวเลือก',
    required this.selections,
    required this.toppings,
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      name: map['name'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      summary: map['summary'] ?? 'ไม่ระบุตัวเลือก',
      selections: Map<String, String>.from(map['selections'] ?? {}),
      toppings: List<String>.from(map['toppings'] ?? []),
      addedAt: (map['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory OrderItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderItem(
      id: doc.id,
      name: data['name'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      summary: data['summary'] ?? 'ไม่ระบุตัวเลือก',
      selections: Map<String, String>.from(data['selections'] ?? {}),
      toppings: List<String>.from(data['toppings'] ?? []),
      addedAt: (data['addedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'summary': summary,
      'selections': selections,
      'toppings': toppings,
    };
  }

  Map<String, dynamic> toCartMap() {
    return {
      'name': name,
      'price': price,
      'summary': summary,
      'selections': selections,
      'toppings': toppings,
      'addedAt': Timestamp.now(),
    };
  }
}

// --- 4. Order Model ---
class Order {
  final String id;
  final String tableNumber;
  final DateTime orderTimestamp;
  final double totalAmount;
  final List<Map<String, dynamic>> items;
  final bool isCompleted;

  Order({
    String? id,
    required this.tableNumber,
    required this.orderTimestamp,
    required this.totalAmount,
    required this.items,
    this.isCompleted = false,
  }) : id = id ?? uuid.v4();

  factory Order.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Order(
      id: doc.id,
      tableNumber: data['tableNumber'] ?? 'Unknown',
      orderTimestamp: (data['orderTimestamp'] as Timestamp).toDate(),
      totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
      items: List<Map<String, dynamic>>.from(data['items'] ?? []),
      isCompleted: data['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tableNumber': tableNumber,
      'orderTimestamp': Timestamp.fromDate(orderTimestamp),
      'totalAmount': totalAmount,
      'items': items,
      'isCompleted': isCompleted,
    };
  }
}
