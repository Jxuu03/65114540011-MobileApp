import 'dart:math';
import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../services/auth_service.dart';
import '../../models/models.dart';
import 'menu_editor_page.dart';

class OwnerShell extends StatefulWidget {
  const OwnerShell({super.key});

  @override
  State<OwnerShell> createState() => _OwnerShellState();
}

class _OwnerShellState extends State<OwnerShell> {
  int _selectedIndex = 0;
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  void _logout() async {
    await _authService.signOut();
  }

  // กำหนดสีหลักสำหรับแอดมิน
  final Color ownerPrimaryColor = Colors.red.shade700;
  final Color accentColor = Colors.green.shade600;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      // ส่งสีหลักและสีเน้นเข้าไปใน Tab จัดการเมนู
      OwnerMenuManagementTab(
        firestoreService: _firestoreService,
        primaryColor: ownerPrimaryColor, // ส่งสีหลัก
        accentColor: accentColor, // ส่งสีเน้น
      ),
      OwnerOrderViewerTab(
        firestoreService: _firestoreService,
        accentColor: accentColor,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('👨‍💼 ร้านค้า - Food Builder Admin'),
        backgroundColor: ownerPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'ออกจากระบบ',
          ),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'จัดการเมนู',
          ),
          // **Badge: นับเฉพาะออเดอร์ที่รอดำเนินการ**
          BottomNavigationBarItem(
            icon: StreamBuilder<List<Order>>(
              stream: _firestoreService.getOrdersStream(),
              builder: (context, snapshot) {
                final orders = snapshot.data ?? [];
                // กรองเฉพาะรายการที่ isCompleted เป็น false
                final pendingCount = orders
                    .where((order) => !order.isCompleted)
                    .length;

                return Badge(
                  isLabelVisible: pendingCount > 0,
                  label: Text('$pendingCount'),
                  child: const Icon(Icons.view_list),
                );
              },
            ),
            label: 'รายการสั่งซื้อ',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: ownerPrimaryColor,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              backgroundColor: ownerPrimaryColor,
              foregroundColor: Colors.white,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      MenuEditorPage(firestoreService: _firestoreService),
                ),
              ),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

// ----------------------------------------------------
// *** 1. Owner Menu Management Tab (ปรับปรุง Card Style) ***
// ----------------------------------------------------
class OwnerMenuManagementTab extends StatelessWidget {
  final FirestoreService firestoreService;
  final Color primaryColor; // สีหลัก
  final Color accentColor; // สีเน้น

  const OwnerMenuManagementTab({
    super.key,
    required this.firestoreService,
    required this.primaryColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MenuItem>>(
      stream: firestoreService.getMenuStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("โหลดเมนูล้มเหลว"));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final menuItems = snapshot.data!;
        if (menuItems.isEmpty) {
          return const Center(child: Text('ยังไม่มีรายการเมนู'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: menuItems.length,
          itemBuilder: (context, index) {
            final item = menuItems[index];

            return Card(
              elevation: 6,
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Placeholder Icon Container
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        item.type == 'Drink'
                            ? Icons.local_cafe
                            : Icons.ramen_dining,
                        size: 35,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ราคา: ฿${item.basePrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: accentColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            item.customizationOptions.isNotEmpty
                                ? 'ปรับแต่งได้ (${item.customizationOptions.length} ตัวเลือก)'
                                : 'ไม่มีตัวเลือกปรับแต่ง',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Action Buttons (Edit & Delete)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ปุ่มแก้ไข
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MenuEditorPage(
                                firestoreService: firestoreService,
                                menuItem: item,
                              ),
                            ),
                          ),
                          tooltip: 'แก้ไขเมนู',
                        ),
                        // ปุ่มลบ
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDelete(context, item),
                          tooltip: 'ลบเมนู',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Dialog ยืนยันการลบ
  void _confirmDelete(BuildContext context, MenuItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: Text(
          'คุณแน่ใจหรือไม่ที่จะลบเมนู "${item.name}" ออกจากรายการ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () {
              firestoreService.removeMenuItem(item.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('ลบเมนู "${item.name}" แล้ว')),
              );
            },
            child: const Text('ลบ', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------
// *** 2. Owner Order Viewer Tab (ไม่มีการเปลี่ยนแปลงหลักจากครั้งก่อน) ***
// ----------------------------------------------------
class OwnerOrderViewerTab extends StatelessWidget {
  final FirestoreService firestoreService;
  final Color accentColor;
  const OwnerOrderViewerTab({
    super.key,
    required this.firestoreService,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Order>>(
      stream: firestoreService.getOrdersStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("โหลดคำสั่งซื้อล้มเหลว"));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final orders = snapshot.data!;

        // เรียงลำดับให้ออเดอร์ที่ยังไม่เสร็จอยู่ด้านบน
        orders.sort((a, b) {
          if (a.isCompleted == b.isCompleted) {
            return b.orderTimestamp.compareTo(
              a.orderTimestamp,
            ); // เรียงตามเวลาล่าสุด
          }
          return a.isCompleted
              ? 1
              : -1; // -1: a ขึ้นก่อน (a ยังไม่เสร็จ), 1: b ขึ้นก่อน (a เสร็จแล้ว)
        });

        if (orders.isEmpty) {
          return const Center(
            child: Text(
              'ไม่มีรายการสั่งซื้อ',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            final time =
                "${order.orderTimestamp.hour.toString().padLeft(2, '0')}:${order.orderTimestamp.minute.toString().padLeft(2, '0')}";

            // กำหนดสีของ Card ตามสถานะ
            final cardColor = order.isCompleted
                ? Colors.grey.shade50
                : Colors.red.shade50; // สีแดงอ่อนสำหรับรายการที่ยังไม่เสร็จ

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 4,
              color: cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: order.isCompleted
                      ? Colors.grey.shade300
                      : Colors.red.shade200,
                  width: 1,
                ),
              ),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                title: Text(
                  'Order: ${order.id.substring(0, min(8, order.id.length))} (โต๊ะ: ${order.tableNumber})',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: order.isCompleted
                        ? Colors.black54
                        : Colors
                              .red
                              .shade700, // สีเข้มขึ้นสำหรับรายการที่รอดำเนินการ
                  ),
                ),
                subtitle: Text(
                  'เวลาสั่ง: $time | สถานะ: ${order.isCompleted ? "เสร็จสิ้น" : "รอดำเนินการ"}',
                  style: TextStyle(
                    color: order.isCompleted
                        ? Colors.grey.shade600
                        : Colors.black87,
                  ),
                ),
                // ปุ่มเสร็จสิ้น/สถานะ
                trailing: order.isCompleted
                    ? Icon(Icons.check_circle, color: accentColor, size: 30)
                    : ElevatedButton(
                        onPressed: () async {
                          await firestoreService.completeOrder(order.id);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 3,
                        ),
                        child: const Text(
                          'ทำเสร็จ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                children: [
                  const Divider(height: 1, thickness: 1),
                  ...order.items.map<Widget>((item) {
                    final name = item['name'] ?? 'Unknown';
                    final price = (item['price'] as num?)?.toDouble() ?? 0.0;
                    final toppings = List<String>.from(item['toppings'] ?? []);

                    String subtitleText = toppings.isNotEmpty
                        ? 'ตัวเลือก: ${toppings.join(", ")}'
                        : '';
                    final hasOptions = toppings.isNotEmpty;

                    return ListTile(
                      leading: const Icon(
                        Icons.local_dining,
                        color: Colors.blueGrey,
                      ),
                      title: Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: hasOptions ? Text(subtitleText) : null,
                      trailing: Text(
                        '฿${price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: hasOptions ? 4 : 8,
                      ),
                    );
                  }).toList(),

                  const Divider(height: 1, thickness: 1.5),

                  // --- Total Amount ---
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'รวมทั้งหมด',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          '฿${order.items.fold<double>(0.0, (sum, item) => sum + ((item['price'] as num?)?.toDouble() ?? 0.0)).toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: accentColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
