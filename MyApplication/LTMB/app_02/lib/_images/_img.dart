import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Display',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ImageDisplayScreen(),
    );
  }
}

class ImageDisplayScreen extends StatelessWidget {
  const ImageDisplayScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Display'),
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Image.asset('assets/images/1.jpg'),
            ),
            Expanded(
              child: Image.asset('assets/images/2.png'),
            ),
            Expanded(
              child: Image.asset('assets/images/3.jpg'),
            ),
          ],
        ),
      ),
    );
  }
}