// lib/pages/auth_wrapper.dart (เวอร์ชันดีบัก)

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/models.dart';
import 'table_input_page.dart';
import 'owner/owner_shell.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    print("[AuthWrapper] กำลังสร้าง StreamBuilder...");

    return StreamBuilder<AppUser?>(
      stream: authService.userProfileStream,
      builder: (context, snapshot) {
        print("[AuthWrapper] สถานะ Stream: ${snapshot.connectionState}");

        if (snapshot.hasError) {
          print("❌ [AuthWrapper] Stream เกิดข้อผิดพลาด: ${snapshot.error}");
          // แสดงหน้าจอ Error แทนการค้าง
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "เกิดข้อผิดพลาดในการตรวจสอบสิทธิ์: \n${snapshot.error}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          print("[AuthWrapper] ยังคงรอการเชื่อมต่อ...");
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final AppUser? userProfile = snapshot.data;
        print(
          "[AuthWrapper] เชื่อมต่อสำเร็จ. โปรไฟล์ผู้ใช้คือ: ${userProfile?.email ?? 'ยังไม่ได้ล็อกอิน'}",
        );

        if (userProfile != null && userProfile.role == 'owner') {
          print("[AuthWrapper] ผู้ใช้เป็น owner. กำลังไปที่ OwnerShell.");
          return const OwnerShell();
        }

        print(
          "[AuthWrapper] ไม่ใช่ owner หรือยังไม่ได้ล็อกอิน. กำลังไปที่ TableInputPage.",
        );
        return const TableInputPage();
      },
    );
  }
}
