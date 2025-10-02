import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/firestore_service.dart';

class DynamicOrderBuilder extends StatefulWidget {
  final MenuItem menuItem;
  final String tableNumber;
  final FirestoreService firestoreService;
  // เพิ่ม properties สำหรับสี
  final Color primaryColor;
  final Color addToCartButtonColor;

  const DynamicOrderBuilder({
    super.key,
    required this.menuItem,
    required this.tableNumber,
    required this.firestoreService,
    required this.primaryColor,
    required this.addToCartButtonColor,
  });

  @override
  State<DynamicOrderBuilder> createState() => _DynamicOrderBuilderState();
}

class _DynamicOrderBuilderState extends State<DynamicOrderBuilder> {
  // State: เก็บตัวเลือกที่ถูกเลือก (Category -> ToppingOption)
  final Map<String, ToppingOption> _selectedOptions = {};
  double _currentPrice = 0.0;
  late final Map<String, List<ToppingOption>> _groupedOptions;

  bool get _hasCustomizationOptions => _groupedOptions.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _currentPrice = widget.menuItem.basePrice;

    // จัดกลุ่มตัวเลือกทั้งหมดตาม Category
    _groupedOptions = {};
    for (var opt in widget.menuItem.customizationOptions) {
      if (opt.category.isNotEmpty) {
        _groupedOptions.putIfAbsent(opt.category, () => []).add(opt);
      }
    }
  }

  // Logic: คำนวณราคารวม
  void _calculatePrice() {
    double price = widget.menuItem.basePrice;
    _selectedOptions.values.forEach((opt) {
      price += opt.price;
    });
    setState(() {
      _currentPrice = price;
    });
  }

  // Logic: จัดการการเลือก (บังคับ Single Selection)
  void _handleOptionTap(ToppingOption option) {
    setState(() {
      final category = option.category;
      final isSelected = _selectedOptions[category]?.name == option.name;

      if (isSelected) {
        _selectedOptions.remove(category); // ยกเลิกการเลือก
      } else {
        _selectedOptions[category] = option; // เลือกใหม่
      }
      _calculatePrice();
    });
  }

  // Logic: เพิ่มลงในตะกร้าและปิด Modal
  void _addToCart() async {
    // 1. สร้าง OrderItem: ใช้ Logic ที่ง่ายขึ้นสำหรับ summary
    final selectedNames = _selectedOptions.values.map((e) => e.name).toList();

    // Summary แสดงแค่ชื่อตัวเลือกที่ถูกเลือกทั้งหมด (ตามที่ผู้ใช้ร้องขอ)
    final summary = selectedNames.join(', ');

    // selections: Map<Category, Name> (เผื่อไว้)
    final selectionsMap = _selectedOptions.map(
      (key, value) => MapEntry(key, value.name),
    );

    final orderItem = OrderItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: widget.menuItem.name,
      price: _currentPrice,
      summary: summary.isEmpty ? 'ไม่ระบุตัวเลือก' : summary,
      selections: selectionsMap,
      toppings:
          selectedNames, // ใส่ทั้งหมดใน toppings เพื่อให้ Owner/Summary Page ดึงไปใช้ได้ง่าย
    );

    try {
      await widget.firestoreService.addToCart(widget.tableNumber, orderItem);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เพิ่มลงตะกร้าไม่สำเร็จ: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Modal Header (Item Name) - UI Improvement
        Container(
          padding: const EdgeInsets.only(
            top: 10,
            bottom: 20,
            left: 20,
            right: 20,
          ),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Text(
                'ปรับแต่ง: ${widget.menuItem.name}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: widget.primaryColor,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'ราคาเริ่มต้น: ฿${widget.menuItem.basePrice.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
              ),
            ],
          ),
        ),

        // Options List (ส่วนหลักของการเลือก)
        Expanded(
          child: _hasCustomizationOptions
              ? ListView(
                  // มีตัวเลือก: แสดงรายการตัวเลือก
                  padding: const EdgeInsets.all(16),
                  children: _groupedOptions.entries.map((entry) {
                    final category = entry.key;
                    final options = entry.value;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(height: 1, thickness: 1.5),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            '${category} (เลือก 1 อย่าง)',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        // Radio Button Style List: บังคับเลือก 1 ตัวเลือกต่อ Category
                        ...options.map((option) {
                          final isSelected =
                              _selectedOptions[category]?.name == option.name;
                          return Card(
                            elevation: isSelected ? 4 : 1,
                            margin: const EdgeInsets.only(bottom: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color: isSelected
                                    ? widget.primaryColor
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: ListTile(
                              onTap: () => _handleOptionTap(option),
                              leading: Icon(
                                isSelected
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                                color: isSelected
                                    ? widget.primaryColor
                                    : Colors.grey,
                              ),
                              title: Text(option.name),
                              trailing: Text(
                                option.price > 0
                                    ? '+฿${option.price.toStringAsFixed(2)}'
                                    : 'ฟรี',
                                style: TextStyle(
                                  color: option.price > 0
                                      ? Colors.green.shade600
                                      : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                        const SizedBox(height: 10),
                      ],
                    );
                  }).toList(),
                )
              : const Center(
                  // ไม่มีตัวเลือก: แสดงข้อความแจ้ง
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline, size: 40, color: Colors.grey),
                        SizedBox(height: 10),
                        Text(
                          'เมนูนี้ไม่มีตัวเลือกการปรับแต่งเพิ่มเติม',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
        ),

        // Floating Action Bar (ปุ่ม 'เพิ่มลงในตะกร้า') - Functional
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
              // ราคารวม (อัพเดทอัตโนมัติ)
              Text(
                'ราคารวม: ฿${_currentPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: widget.addToCartButtonColor,
                ),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
                label: const Text(
                  'เพิ่มลงในตะกร้า',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: _addToCart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.addToCartButtonColor,
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
}
