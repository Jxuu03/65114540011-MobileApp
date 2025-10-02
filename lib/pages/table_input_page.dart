import 'package:flutter/material.dart';
import 'customer_shell.dart';
import 'owner/owner_login_page.dart';

class TableInputPage extends StatefulWidget {
  const TableInputPage({super.key});

  @override
  State<TableInputPage> createState() => _TableInputPageState();
}

class _TableInputPageState extends State<TableInputPage> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _tableNumber;

  void _submitTableNumber() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _tableNumber = _controller.text.trim();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ถ้า tableNumber มีค่าแล้ว ให้แสดง CustomerShell
    if (_tableNumber != null) {
      return CustomerShell(tableNumber: _tableNumber!);
    }

    // ถ้ายังไม่มีค่า ให้แสดง form input
    return Scaffold(
      appBar: AppBar(
        title: const Text('ยินดีต้อนรับ'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Text(
                  'กรุณาระบุหมายเลขโต๊ะ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _controller,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'หมายเลขโต๊ะ',
                    hintText: 'เช่น 1, 5, A1',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.table_bar),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณาป้อนหมายเลขโต๊ะ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _submitTableNumber,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'เข้าสู่ระบบสั่งอาหาร',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 40),
                // ปุ่ม Owner Login
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const OwnerLoginPage(),
                      ),
                    );
                  },
                  child: Text(
                    'สำหรับเจ้าของ (Owner Login)',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
