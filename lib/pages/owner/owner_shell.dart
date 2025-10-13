import 'dart:math';
import 'package:flutter/material.dart';
import '../../services/pocketbase_service.dart';
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
  final PocketBaseService _pocketbaseService = PocketBaseService();

  late final Stream<List<Order>> _ordersStream;
  late final Stream<List<MenuItem>> _menuStream;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _ordersStream = _pocketbaseService.getOrdersStream();
    _menuStream = _pocketbaseService.getMenuStream();

    _pages = <Widget>[
      OwnerMenuManagementTab(
        pocketbaseService: _pocketbaseService,
        menuStream: _menuStream,
        primaryColor: ownerPrimaryColor,
        accentColor: accentColor,
      ),
      // ส่ง Stream เข้าไปใน Tab ตามปกติ
      OwnerOrderViewerTab(
        pocketbaseService: _pocketbaseService,
        ordersStream: _ordersStream,
        accentColor: accentColor,
      ),
    ];
  }

  void _logout() async {
    await _authService.signOut();
  }

  final Color ownerPrimaryColor = Colors.red.shade700;
  final Color accentColor = Colors.green.shade600;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('👨‍💼 ร้านค้า'),
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
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'จัดการเมนู',
          ),
          BottomNavigationBarItem(
            icon: StreamBuilder<List<Order>>(
              stream: _ordersStream,
              builder: (context, snapshot) {
                final orders = snapshot.data ?? [];
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
                      MenuEditorPage(pocketbaseService: _pocketbaseService),
                ),
              ),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

// ----------------------------------------------------
// *** 1. Owner Menu Management Tab ***
// ----------------------------------------------------
class OwnerMenuManagementTab extends StatelessWidget {
  final PocketBaseService pocketbaseService;
  final Stream<List<MenuItem>> menuStream; // <--- รับ Stream
  final Color primaryColor;
  final Color accentColor;

  const OwnerMenuManagementTab({
    super.key,
    required this.pocketbaseService,
    required this.menuStream,
    required this.primaryColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MenuItem>>(
      stream: menuStream, // <--- ใช้ Stream ที่รับเข้ามา
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("โหลดเมนูล้มเหลว: ${snapshot.error}"));
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
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MenuEditorPage(
                                pocketbaseService: pocketbaseService,
                                menuItem: item,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDelete(context, item),
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

  void _confirmDelete(BuildContext context, MenuItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: Text('คุณแน่ใจหรือไม่ที่จะลบเมนู "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () {
              if (item.id != null) {
                pocketbaseService.removeMenuItem(item.id!);
              }
              Navigator.pop(context);
            },
            child: const Text('ลบ', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------
// *** 2. Owner Order Viewer Tab (ใช้ UI ที่คุณต้องการ) ***
// ----------------------------------------------------
class OwnerOrderViewerTab extends StatelessWidget {
  final PocketBaseService pocketbaseService;
  final Stream<List<Order>> ordersStream; // <--- การแก้ไข: เพิ่มพารามิเตอร์นี้
  final Color accentColor;

  const OwnerOrderViewerTab({
    super.key,
    required this.pocketbaseService,
    required this.ordersStream, // <--- การแก้ไข: เพิ่มพารามิเตอร์นี้
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Order>>(
      stream: ordersStream, // <--- การแก้ไข: ใช้ Stream ที่รับเข้ามา
      builder: (context, snapshot) {
        if (snapshot.hasError)
          return Center(
            child: Text("โหลดคำสั่งซื้อล้มเหลว: ${snapshot.error}"),
          );
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        final orders = snapshot.data!;
        orders.sort((a, b) {
          if (a.isCompleted == b.isCompleted)
            return b.orderTimestamp.compareTo(a.orderTimestamp);
          return a.isCompleted ? 1 : -1;
        });

        if (orders.isEmpty)
          return const Center(child: Text('ไม่มีรายการสั่งซื้อ'));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            final localTimestamp = order.orderTimestamp.toLocal();
            final time =
                "${localTimestamp.hour.toString().padLeft(2, '0')}:${localTimestamp.minute.toString().padLeft(2, '0')}";
            final cardColor = order.isCompleted
                ? Colors.grey.shade50
                : Colors.red.shade50;

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
                  'Order: ${order.id?.substring(0, min(8, order.id?.length ?? 0))} (โต๊ะ: ${order.tableNumber})',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: order.isCompleted
                        ? Colors.black54
                        : Colors.red.shade700,
                  ),
                ),
                subtitle: Text(
                  'เวลาสั่ง: $time | สถานะ: ${order.isCompleted ? "เสร็จสิ้น" : "รอดำเนินการ"}',
                ),
                trailing: order.isCompleted
                    ? Icon(Icons.check_circle, color: accentColor, size: 30)
                    : ElevatedButton(
                        onPressed: () async {
                          if (order.id != null) {
                            await pocketbaseService.completeOrder(order.id!);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: Colors.white, // ทำให้ text เป็นสีขาว
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('ทำเสร็จ'),
                      ),
                children: [
                  const Divider(height: 1, thickness: 1),
                  ...order.items.map<Widget>((item) {
                    return ListTile(
                      leading: const Icon(
                        Icons.local_dining,
                        color: Colors.blueGrey,
                      ),
                      title: Text(
                        item['name'] ?? 'Unknown',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle:
                          (item['summary'] != null &&
                              (item['summary'] as String).isNotEmpty &&
                              item['summary'] != 'ไม่ระบุตัวเลือก')
                          ? Text(item['summary'])
                          : null,
                      trailing: Text(
                        '฿${(item['price'] as num? ?? 0.0).toStringAsFixed(2)}',
                      ),
                    );
                  }).toList(),
                  const Divider(height: 1, thickness: 1.5),
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
                          '฿${order.totalAmount.toStringAsFixed(2)}',
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
