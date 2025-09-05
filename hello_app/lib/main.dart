import 'package:flutter/material.dart';
import 'package:hello_app/myapp.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'controller/apiService.dart';

void main() async {
  await GetStorage.init();
  Get.put(ApiService());
  runApp(const MyApp());
}
