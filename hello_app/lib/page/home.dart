import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hello_app/page/detail.dart';
import 'package:hello_app/page/playerSelection.dart';
import 'package:hello_app/page/new.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Detail()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 30),

            // ปุ่มไปหน้า TeamPage
            ElevatedButton(
              onPressed: () => Get.to(() => TeamPage()),
              child: const Text("Go to Team Page"),
            ),

            ElevatedButton(
              onPressed: () => Get.to(() => NewPage()),
              child: const Text("Go to New Page"),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Hero(
          tag: 'fab-image',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Image.asset(
              'images/forest.jpg',
              fit: BoxFit.cover,
              width: 56,
              height: 56,
            ),
          ),
        ),
      ),
    );
  }
}
