import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/teamController.dart';

class NewPage extends StatelessWidget {
  final TeamController teamCtrl = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Team Preview")),
      body: Obx(() => Column(
        children: [
          Text("Your Pokémon Team:"),
          ...teamCtrl.team.map((p) => ListTile(title: Text(p))).toList(),
        ],
      )),
    );
  }
}