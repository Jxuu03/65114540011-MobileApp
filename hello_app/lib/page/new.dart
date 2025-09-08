import 'package:flutter/material.dart';

class NewPage extends StatelessWidget {
  const NewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Center Text Page")),
      body: const Center(
        child: Text(
          "New page, to be continued!",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
