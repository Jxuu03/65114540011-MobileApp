import 'package:flutter/material.dart';
import '../services/pocketbase_service.dart';
import '../builders/dynamic_order_builder.dart';
import '../models/models.dart' as app_models;
import 'order_summary_page.dart';

class CustomerShell extends StatefulWidget {
  final String tableNumber;
  const CustomerShell({super.key, required this.tableNumber});

  @override
  State<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends State<CustomerShell> {
  int _selectedIndex = 0;
  // สร้าง Service instance ตามปกติ
  final PocketBaseService _pocketbaseService = PocketBaseService();

  // --- การแก้ไข: สร้างตัวแปรสำหรับเก็บ Stream ---
  late final Stream<List<app_models.MenuItem>> _menuStream;
  late final Stream<List<app_models.OrderItem>> _cartStream;

  @override
  void initState() {
    super.initState();
    // --- การแก้ไข: เรียกฟังก์ชันสร้าง Stream แค่ครั้งเดียวใน initState ---
    _menuStream = _pocketbaseService.getMenuStream();
    _cartStream = _pocketbaseService.getCartStream(widget.tableNumber);
  }

  final Color primaryColor = Colors.orange.shade700;
  final Color accentColor = Colors.green.shade600;
  final Color addToCartButtonColor = Colors.blue.shade600;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<app_models.MenuItem>>(
      stream: _menuStream, // <--- การแก้ไข: ใช้ Stream จาก State
      builder: (context, menuSnapshot) {
        final menuItems = menuSnapshot.data ?? [];

        return StreamBuilder<List<app_models.OrderItem>>(
          stream: _cartStream, // <--- การแก้ไข: ใช้ Stream จาก State
          builder: (context, cartSnapshot) {
            final cartItems = cartSnapshot.data ?? [];

            final List<Widget> pages = <Widget>[
              _buildMenuTab(context, menuItems),
              _buildCartTab(context, cartItems),
            ];

            return Scaffold(
              appBar: AppBar(
                title: Text('โต๊ะ ${widget.tableNumber} - สั่งอาหาร'),
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 4,
              ),
              body: IndexedStack(index: _selectedIndex, children: pages),
              bottomNavigationBar: BottomNavigationBar(
                items: [
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.restaurant_menu),
                    label: 'เมนู',
                  ),
                  BottomNavigationBarItem(
                    icon: Badge(
                      isLabelVisible: cartItems.isNotEmpty,
                      label: Text('${cartItems.length}'),
                      child: const Icon(Icons.shopping_cart),
                    ),
                    label: 'ตะกร้า',
                  ),
                ],
                currentIndex: _selectedIndex,
                selectedItemColor: primaryColor,
                unselectedItemColor: Colors.grey,
                onTap: (index) => setState(() => _selectedIndex = index),
              ),
            );
          },
        );
      },
    );
  }

  // ------------------------------------
  // --- 1. Menu Tab ---
  // ------------------------------------
  Widget _buildMenuTab(
    BuildContext context,
    List<app_models.MenuItem> menuItems,
  ) {
    if (menuItems.isEmpty) {
      return const Center(child: CircularProgressIndicator());
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
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: () => _showBuilderDialog(context, item),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      item.type == 'Drink'
                          ? Icons.local_cafe
                          : Icons.ramen_dining,
                      size: 40,
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
                          'ราคาเริ่มต้น: ฿${item.basePrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: accentColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        if (item.customizationOptions.isNotEmpty)
                          Text(
                            'ปรับแต่งได้ (${item.customizationOptions.length} ตัวเลือก)',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Icon(Icons.add_circle_sharp, color: primaryColor, size: 35),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------
  // --- 2. Cart Tab ---
  // ---------------------------------------
  Widget _buildCartTab(
    BuildContext context,
    List<app_models.OrderItem> cartItems,
  ) {
    final total = cartItems.fold<double>(0.0, (sum, item) => sum + item.price);

    return Column(
      children: [
        Expanded(
          child: cartItems.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.remove_shopping_cart,
                        size: 50,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'ตะกร้าว่างเปล่า!',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    final subtitleText = item.summary;
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 4,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.food_bank,
                                size: 30,
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
                                      fontSize: 17,
                                    ),
                                  ),
                                  if (subtitleText.isNotEmpty &&
                                      subtitleText != 'ไม่ระบุตัวเลือก')
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        'ตัวเลือก: $subtitleText',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '฿${item.price.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: accentColor,
                                    fontSize: 16,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    if (item.id != null) {
                                      _pocketbaseService.removeFromCart(
                                        item.id!,
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
            border: Border(top: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ยอดรวม: ฿${total.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: primaryColor,
                ),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.send, color: Colors.white),
                label: const Text(
                  'ยืนยันคำสั่งซื้อ',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                onPressed: cartItems.isEmpty
                    ? null
                    : () async {
                        try {
                          final summaryOrder = app_models.Order(
                            tableNumber: widget.tableNumber,
                            orderTimestamp: DateTime.now(),
                            totalAmount: total,
                            items: cartItems.map((e) => e.toMap()).toList(),
                          );
                          await _pocketbaseService.placeOrder(
                            widget.tableNumber,
                            cartItems,
                          );
                          if (!mounted) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  OrderSummaryPage(order: summaryOrder),
                            ),
                          );
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Show DynamicOrderBuilder Modal ---
  Future<void> _showBuilderDialog(
    BuildContext context,
    app_models.MenuItem item,
  ) async {
    final builder = DynamicOrderBuilder(
      menuItem: item,
      tableNumber: widget.tableNumber,
      pocketbaseService: _pocketbaseService, // ส่ง service ที่มีอยู่แล้วเข้าไป
      primaryColor: primaryColor,
      addToCartButtonColor: addToCartButtonColor,
    );

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: builder,
      ),
    );
  }
}
