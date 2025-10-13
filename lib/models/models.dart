import 'package:pocketbase/pocketbase.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

// --- User Model (รวมจาก app_user.dart) ---
class AppUser {
  final String uid;
  final String email;
  final String name;
  final String role;

  AppUser({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
  });

  factory AppUser.fromRecord(RecordModel record) {
    return AppUser(
      uid: record.id,
      email: record.data['email']?.toString() ?? '',
      name: record.data['name'] ?? '',
      role: record.data['role'] ?? 'customer',
    );
  }
}

// --- Topping Option ---
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

// --- Menu Item Model ---
class MenuItem {
  final String? id;
  final String name;
  final double basePrice;
  final String type;
  final List<ToppingOption> customizationOptions;

  MenuItem({
    this.id,
    required this.name,
    required this.basePrice,
    required this.type,
    this.customizationOptions = const [],
  });

  factory MenuItem.fromRecord(RecordModel record) {
    final data = record.toJson();
    return MenuItem(
      id: record.id,
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

// --- Order Item Model ---
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

  factory OrderItem.fromRecord(RecordModel record) {
    final data = record.toJson();
    return OrderItem(
      id: record.id,
      name: data['name'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      summary: data['summary'] ?? 'ไม่ระบุตัวเลือก',
      selections: Map<String, String>.from(data['selections'] ?? {}),
      toppings: List<String>.from(data['toppings'] ?? []),
      addedAt: DateTime.tryParse(record.created) ?? DateTime.now(),
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
    return toMap(); // PocketBase's `created` field will handle timestamp automatically
  }
}

// --- Order Model ---
class Order {
  final String? id;
  final String tableNumber;
  final DateTime orderTimestamp;
  final double totalAmount;
  final List<Map<String, dynamic>> items;
  final bool isCompleted;

  Order({
    this.id,
    required this.tableNumber,
    required this.orderTimestamp,
    required this.totalAmount,
    required this.items,
    this.isCompleted = false,
  });

  factory Order.fromRecord(RecordModel record) {
    final data = record.toJson();
    return Order(
      id: record.id,
      tableNumber: data['tableNumber'] ?? 'Unknown',
      orderTimestamp:
          DateTime.tryParse(data['orderTimestamp'] ?? '') ?? DateTime.now(),
      totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
      items: List<Map<String, dynamic>>.from(data['items'] ?? []),
      isCompleted: data['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tableNumber': tableNumber,
      'orderTimestamp': orderTimestamp.toIso8601String(),
      'totalAmount': totalAmount,
      'items': items,
      'isCompleted': isCompleted,
    };
  }
}
