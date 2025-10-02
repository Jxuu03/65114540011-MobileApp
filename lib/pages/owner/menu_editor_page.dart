// lib/pages/owner/menu_editor_page.dart
import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../models/models.dart';

class MenuEditorPage extends StatefulWidget {
  final MenuItem? menuItem;
  final FirestoreService firestoreService;

  const MenuEditorPage({
    super.key,
    this.menuItem,
    required this.firestoreService,
  });

  @override
  State<MenuEditorPage> createState() => _MenuEditorPageState();
}

class _MenuEditorPageState extends State<MenuEditorPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  String _itemType = 'Drink';
  List<ToppingOption> _customizationOptions = [];

  // Controllers สำหรับ topping
  final _toppingNameController = TextEditingController();
  final _toppingPriceController = TextEditingController();
  String _toppingCategory = 'Size';

  @override
  void initState() {
    super.initState();
    if (widget.menuItem != null) {
      _nameController.text = widget.menuItem!.name;
      _priceController.text = widget.menuItem!.basePrice.toStringAsFixed(2);
      _itemType = widget.menuItem!.type;
      _customizationOptions = List.from(widget.menuItem!.customizationOptions);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _toppingNameController.dispose();
    _toppingPriceController.dispose();
    super.dispose();
  }

  void _addTopping() {
    final name = _toppingNameController.text.trim();
    final price = double.tryParse(_toppingPriceController.text);
    if (name.isNotEmpty && price != null) {
      setState(() {
        _customizationOptions.add(
          ToppingOption(name: name, price: price, category: _toppingCategory),
        );
        _toppingNameController.clear();
        _toppingPriceController.clear();
      });
    }
  }

  void _removeTopping(int index) {
    setState(() {
      _customizationOptions.removeAt(index);
    });
  }

  void _saveItem() async {
    if (_formKey.currentState!.validate()) {
      final newItem = MenuItem(
        id: widget.menuItem?.id,
        name: _nameController.text,
        basePrice: double.tryParse(_priceController.text) ?? 0.0,
        type: _itemType,
        customizationOptions: _customizationOptions,
      );

      try {
        await widget.firestoreService.saveMenuItem(newItem);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.menuItem == null
                  ? 'เพิ่มเมนูใหม่สำเร็จ!'
                  : 'อัปเดตเมนูสำเร็จ!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาดในการบันทึกเมนู: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.menuItem == null ? 'เพิ่มเมนูใหม่' : 'แก้ไขเมนู'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- ชื่อและราคา (ปรับปรุง UI TextField) ---
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'ชื่อเมนู',
                  // **UI Improvement: OutlineInputBorder**
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  prefixIcon: Icon(Icons.fastfood),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'กรุณาใส่ชื่อเมนู' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'ราคาพื้นฐาน (฿)',
                  // **UI Improvement: OutlineInputBorder**
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => double.tryParse(value ?? '') == null
                    ? 'กรุณาใส่ตัวเลขที่ถูกต้อง'
                    : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _itemType,
                decoration: const InputDecoration(
                  labelText: 'ประเภท',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  prefixIcon: Icon(Icons.category),
                ),
                items: const ['Food', 'Drink']
                    .map(
                      (type) =>
                          DropdownMenuItem(value: type, child: Text(type)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _itemType = value);
                },
              ),
              const Divider(height: 40, thickness: 2),
              // --- ตัวเลือก customization ---
              Text(
                'ตัวเลือกการปรับแต่ง',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              // *** New Topping Input Fields ***
              Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: TextFormField(
                      controller: _toppingNameController,
                      decoration: const InputDecoration(
                        labelText: 'ชื่อตัวเลือก',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _toppingPriceController,
                      decoration: const InputDecoration(
                        labelText: 'ราคาเพิ่ม',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: DropdownButtonFormField<String>(
                      value: _toppingCategory,
                      decoration: const InputDecoration(
                        labelText: 'หมวดหมู่',
                        border: OutlineInputBorder(),
                      ),
                      items: const ['Size', 'Milk', 'Temperature', 'Topping']
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null)
                          setState(() => _toppingCategory = value);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _addTopping,
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        'เพิ่ม',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_customizationOptions.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ตัวเลือกปัจจุบัน (${_customizationOptions.length})',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _customizationOptions.length,
                      itemBuilder: (context, index) {
                        final option = _customizationOptions[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          elevation: 1,
                          child: ListTile(
                            title: Text(
                              '${option.name} (+฿${option.price.toStringAsFixed(2)})',
                            ),
                            subtitle: Text(
                              'หมวดหมู่: ${option.category}',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeTopping(index),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                )
              else
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('ยังไม่มีตัวเลือกการปรับแต่ง'),
                  ),
                ),
              const SizedBox(height: 40),
              Center(
                child: ElevatedButton(
                  onPressed: _saveItem,
                  // **UI Improvement: Change Save Button Color**
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.green.shade600, // เปลี่ยนเป็นสีเขียว
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    widget.menuItem == null ? 'บันทึกเมนูใหม่' : 'อัปเดตเมนู',
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
