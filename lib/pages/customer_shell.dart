import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
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
  final FirestoreService firestore = FirestoreService();
  final AuthService authService = AuthService();

  // กำหนดสีหลักที่ใช้ทั่วทั้ง Shell
  final Color primaryColor = Colors.orange.shade700; // สีหลัก
  final Color accentColor = Colors.green.shade600; // สีเน้น (เช่น ราคา)
  final Color addToCartButtonColor = Colors.blue.shade600; // สีปุ่ม Add to Cart

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<app_models.MenuItem>>(
      stream: firestore.getMenuStream(),
      builder: (context, snapshot) {
        final menuItems = snapshot.data ?? [];

        return StreamBuilder<List<app_models.OrderItem>>(
          stream: firestore.getCartStream(widget.tableNumber),
          builder: (context, cartSnapshot) {
            final cartItems = cartSnapshot.data ?? [];

            final List<Widget> _pages = <Widget>[
              _buildMenuTab(context, menuItems),
              _buildCartTab(context, cartItems),
            ];

            return Scaffold(
              appBar: AppBar(
                title: Text('โต๊ะ ${widget.tableNumber} - Food Builder'),
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 4,
              ),
              body: IndexedStack(index: _selectedIndex, children: _pages),
              bottomNavigationBar: BottomNavigationBar(
                items: [
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.restaurant_menu),
                    label: 'เมนู',
                  ),
                  BottomNavigationBarItem(
                    // Notification Badge
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
  // --- 1. Menu Tab (ใช้ Card Style) ---
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
            onTap: () async {
              await _showBuilderDialog(context, item);
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Placeholder Image / Icon Container
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
                            color: Colors.black87,
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
                  // Add Button
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
  // --- 2. Cart Tab (ปรับปรุง Card Style) ---
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
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
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
                          'ตะกร้าว่างเปล่า! กรุณาเลือกเมนูที่ต้องการ',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    // item.summary คือชื่อท็อปปิ้งทั้งหมดที่ถูกเลือก
                    final subtitleText = item.summary;

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 4,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(color: Colors.grey.shade200, width: 1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            // Placeholder Icon
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

                            // Item Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 17,
                                      color: Colors.black87,
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

                            // Price and Delete Button
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
                                  onPressed: () async {
                                    if (item.id != null) {
                                      await firestore.removeFromCart(
                                        widget.tableNumber,
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

        // Floating Action Bar (Total & Place Order)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey.shade200)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ราคารวม
              Text(
                'ยอดรวม: ฿${total.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: primaryColor,
                ),
              ),
              // ปุ่มยืนยันคำสั่งซื้อ
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
                          final now = DateTime.now();
                          final order = app_models.Order(
                            tableNumber: widget.tableNumber,
                            orderTimestamp: now,
                            totalAmount: total,
                            items: cartItems.map((e) => e.toMap()).toList(),
                          );
                          await firestore.placeOrder(
                            widget.tableNumber,
                            cartItems,
                          );
                          if (!mounted) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  OrderSummaryPage(order: order),
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
                  elevation: 5,
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
      firestoreService: firestore,
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
