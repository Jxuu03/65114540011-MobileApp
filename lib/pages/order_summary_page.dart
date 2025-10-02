import 'package:flutter/material.dart';
import '../models/models.dart' as app_models;
import 'package:intl/intl.dart';

class OrderSummaryPage extends StatelessWidget {
  final app_models.Order order;

  const OrderSummaryPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    // ใช้ DateFormat เดิมที่คุณกำหนด
    final timeFormat = DateFormat('dd/MM/yyyy HH:mm');
    final Color primaryColor = Colors.orange.shade700;
    final Color accentColor = Colors.green.shade600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('สรุปคำสั่งซื้อ'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // **UI Improvement: Order Status Header** (ไม่เปลี่ยนแปลง)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: Colors.white,
                  size: 40,
                ),
                const SizedBox(height: 8),
                const Text(
                  'คำสั่งซื้อสำเร็จ!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'โต๊ะ ${order.tableNumber} | เวลา: ${timeFormat.format(order.orderTimestamp)}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'รายการอาหารที่สั่ง',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                ...order.items.map((item) {
                  final itemName = item['name'] ?? '';
                  final itemPrice = (item['price'] as num?)?.toDouble() ?? 0.0;

                  // **การแก้ไข: ดึง item['summary'] มาแสดงผล**
                  // item['summary'] ถูก set ให้เป็นแค่ชื่อท็อปปิ้งทั้งหมดใน dynamic_order_builder
                  final itemSummary =
                      item['summary'] as String? ?? 'ไม่ระบุตัวเลือก';

                  // **UI Improvement: Item Card**
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                itemName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                '฿${itemPrice.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: accentColor,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // **การแสดงผลที่ปรับปรุง: แสดงแค่ summary (ชื่อตัวเลือกทั้งหมด)**
                          if (itemSummary != 'ไม่ระบุตัวเลือก')
                            Text(
                              itemSummary,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                          // NOTE: ลบ Logic การวนลูป selections และ toppings แบบเดิมออก
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),

          // **UI Improvement: Floating Total Summary** (ไม่เปลี่ยนแปลง)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(
                top: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'ยอดรวมทั้งหมด',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  '฿${order.totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: accentColor,
                  ),
                ),
              ],
            ),
          ),

          // ปุ่มกลับสู่หน้าเมนู
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                // Pop back to the first route (CustomerShell)
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'กลับสู่หน้าเมนู',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
