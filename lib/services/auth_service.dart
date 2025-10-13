import 'dart:async';
import 'package:pocketbase/pocketbase.dart';
import '../models/models.dart';
import '../main.dart';

class AuthService {
  final PocketBase _auth = pb;

  // --- การแก้ไข ---
  // ปรับปรุง Stream ให้ส่งสถานะปัจจุบันออกไปทันที
  Stream<AppUser?> get userProfileStream {
    // 1. สร้าง StreamController เพื่อจัดการ Stream ของเราเอง
    final controller = StreamController<AppUser?>();

    // 2. ตรวจสอบ "สถานะปัจจุบัน" ทันที
    // AuthStore จะเก็บข้อมูลผู้ใช้ที่ล็อกอินไว้ล่าสุด
    final initialUserRecord = _auth.authStore.model;
    if (initialUserRecord != null && initialUserRecord is RecordModel) {
      // ถ้ามีคนล็อกอินค้างอยู่ ให้ส่งข้อมูลนั้นออกไป
      controller.add(AppUser.fromRecord(initialUserRecord));
    } else {
      // ถ้าไม่มี ให้ส่ง null (ยังไม่ล็อกอิน) ออกไป
      controller.add(null);
    }

    // 3. จากนั้น ค่อยเริ่มดักฟัง "การเปลี่ยนแปลงในอนาคต"
    final subscription = _auth.authStore.onChange.listen((event) {
      final userRecord = event.model;
      if (userRecord != null && userRecord is RecordModel) {
        controller.add(AppUser.fromRecord(userRecord));
      } else {
        controller.add(null);
      }
    });

    // 4. จัดการการยกเลิกการดักฟังเมื่อไม่ต้องการใช้แล้ว
    controller.onCancel = () {
      subscription.cancel();
      controller.close();
    };

    // 5. คืนค่า Stream ที่เราสร้างขึ้นเอง
    return controller.stream;
  }

  bool get isSignedIn => _auth.authStore.isValid;

  Future<void> signInOwner(String email, String password) async {
    try {
      await _auth.collection('users').authWithPassword(email, password);
    } on ClientException catch (e) {
      throw Exception('เข้าสู่ระบบล้มเหลว: ${e.response['message']}');
    } catch (e) {
      throw Exception('เกิดข้อผิดพลาดที่ไม่รู้จัก: $e');
    }
  }

  Future<void> signOut() async {
    _auth.authStore.clear();
  }
}
